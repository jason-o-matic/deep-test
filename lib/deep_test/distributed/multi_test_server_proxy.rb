module DeepTest
  module Distributed
    class MultiTestServerProxy
      
      def initialize(options, slaves)
        DeepTest.logger.debug "MultiTestServerProxy#initialize #{slaves.length} slaves"
        @slave_controller = DispatchController.new(options, slaves)
        @slaves = slaves
      end

      def spawn_worker_server(options)
        DeepTest.logger.debug "dispatch spawn_worker_server for #{options.origin_hostname}"
        WorkerServerProxy.new options,
                              @slave_controller.dispatch(:spawn_worker_server, 
                                                         options)
      end

      def sync(options)
        if options.sync_options[:push_code]
          multi_push_sync(options)
        else
          DeepTest.logger.debug "dispatch sync for #{options.origin_hostname}"
          @slave_controller.dispatch(:sync, options)
        end
      end
      
      def multi_push_sync(options)
        puts "Syncing..."
        sync_start = Time.now
        
        threads = @slaves.map do |slave|
          Thread.new do
            Thread.current[:receiver] = slave
            Timeout.timeout(options.timeout_in_seconds) do
              RSync.sync(Struct.new(:address).new(URI::parse(slave.__drburi).host), options, options.mirror_path(slave.config[:work_dir]))
            end
          end
        end

        results = []
        threads.each do |t|
          begin
            results << t.value
          rescue Timeout::Error
            DeepTest.logger.error "Timeout syncing to #{t[:receiver].__drburi}"
            raise
          end
        end
        
        puts "Sync took #{Time.now - sync_start} seconds"
      end

      class WorkerServerProxy
        
        attr_reader :slaves
        
        def initialize(options, slaves)
          @slaves = slaves
          DeepTest.logger.debug "WorkerServerProxy#initialize #{slaves.inspect}"
          @slave_controller = DispatchController.new(options, slaves)
        end

        def load_files(files)
          DeepTest.logger.debug "dispatch load_files"
          @slave_controller.dispatch(:load_files, files)
        end

        def start_all
          DeepTest.logger.debug "dispatch start_all"
          @slave_controller.dispatch(:start_all)
        end

        def stop_all
          DeepTest.logger.debug "dispatch stop_all"
          @slave_controller.dispatch_with_options(:stop_all, :ignore_connection_error => true)
        end
      end
    end
  end
end
