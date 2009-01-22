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
          @slaves.each do |slave|
            DeepTest.logger.debug "sync to: #{slave.inspect}"
            RSync.sync(Struct.new(:address).new(URI::parse(slave.__drburi).host), options, options.mirror_path(slave.config[:work_dir]))
          end
        else
          DeepTest.logger.debug "dispatch sync for #{options.origin_hostname}"
          @slave_controller.dispatch(:sync, options)
        end
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

        def start_all(drbserver)
          DeepTest.logger.debug "dispatch start_all"
          @slave_controller.dispatch(:start_all, drbserver)
        end

        def stop_all
          DeepTest.logger.debug "dispatch stop_all"
          @slave_controller.dispatch_with_options(:stop_all, :ignore_connection_error => true)
        end
      end
    end
  end
end
