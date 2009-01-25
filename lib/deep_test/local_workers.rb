module DeepTest
  class LocalWorkers
    
    MUTEX = Mutex.new
    
    def initialize(options)
      @options = options
      @warlock = Warlock.new
    end

    def load_files(files)
      files.each {|f| load f}
    end

    def server
      @options.server
    end
    
    def take_work
      MUTEX.synchronize do
      r = @drbserver.take_work
#         sleep 0.5
        r
        end
    end
    
    def write_result(res)
      MUTEX.synchronize do
      r = @drbserver.write_result res
#         sleep 0.5
        r
        end
    end
    
    def start_all(drbserver)
      @drbserver = drbserver
      
#       DRb.start_service("druby://127.0.0.1:34523", self)
      
      each_worker do |worker_num|
        start_worker(worker_num) do
          reseed_random_numbers
          reconnect_to_database
#           serv = drbserver.server
#           puts "WORKER FOO: #{serv.inspect} #{serv.foo.inspect}"
          DRb.stop_service
          DRb.start_service(drbserver.uri, nil, DRbFire::ROLE => DRbFire::CLIENT) # , DRbFire::DELEGATE => DRbBindAllTCPSocket, "delegate_scheme" => "drubyall"
#           DRb.start_service
          puts "LW DRB SERVER URI: #{drbserver.uri.inspect} #{drbserver.inspect}"
          bb = DRbObject.new_with_uri(drbserver.uri)
#           bb = DRbObject.new_with_uri("druby://127.0.0.1:34523")
#           puts "WORKER FOO: #{bb.inspect} #{bb.foo.inspect}"
          worker = DeepTest::Worker.new(worker_num,
#                                         server, 
#                                         drbserver[worker_num.to_i], 
#                                         drbserver.server, 
#                                         drbserver, 
#                                         self,
                                        bb,
#                                         serv, 
                                        @options.new_listener_list)
          worker.run
        end
      end        
    end

    def stop_all
      @warlock.stop_all
    end

    def number_of_workers
      @options.number_of_workers
    end

    private

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def start_worker(worker_num, &blk)
      @warlock.start("worker #{worker_num}", &blk)
    end

    def reseed_random_numbers
      srand
    end

    def each_worker
      number_of_workers.to_i.times { |worker_num| yield worker_num }
    end
  end
end
