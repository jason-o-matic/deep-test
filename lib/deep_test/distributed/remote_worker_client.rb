module DeepTest
  module Distributed
    class RemoteWorkerClient
      
      attr_reader :worker_server
      
      def initialize(options, test_server, failover_workers)
        @failover_workers = failover_workers
        @options = options
        @test_server = test_server
      end

      def load_files(filelist)
        @options.new_listener_list.before_sync

        t = Thread.new do
          @test_server.sync(@options)
          @worker_server = @test_server.spawn_worker_server(@options)
          
        @worker_server.slaves.each do |s|
          puts "REMOTE WORKER CLIENT CONNECT: #{s.inspect}"
          DRb.start_service(s.__drburi, nil, DRbFire::ROLE => DRbFire::CLIENT) # , DRbFire::DELEGATE => DRbBindAllTCPSocket, "delegate_scheme" => "drubyall"
        end
        puts "ABOUT TO LOAD FILES #{__FILE__}:#{__LINE__} #{@worker_server.inspect}"
          @worker_server.load_files filelist
        end

        filelist.each {|f| load f}

        begin
          t.join
        rescue => e
          # The failover here doesn't invoke load_files on the failover_workers
          # because they will be LocalWorkers, which fork from the current 
          # process.  The fact that we depend in this here is damp...
          #
          fail_over("load_files", e)
        end
      end

      def start_all(drbserver)
        
        @worker_server.slaves.each do |s|
          puts "REMOTE WORKER CLIENT START ALL CONNECT: #{drbserver}\n#{s.inspect}"
#           DRb.start_service(s.__drburi, nil, DRbFire::ROLE => DRbFire::CLIENT)
#           s.drbserver = [Server.server, Server.server]
          s.drbserver = Server.server
        end
        
        @worker_server.start_all(drbserver)
      rescue => e
        raise if failed_over?
        fail_over("start_all", e)
        retry
      end

      def stop_all
        @worker_server.stop_all
      end

      def fail_over(method, exception)
        @options.ui_instance.distributed_failover_to_local(method, exception)
        @worker_server = @failover_workers
      end

      def failed_over?
        @worker_server == @failover_workers
      end
    end
  end
end
