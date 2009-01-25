module DeepTest
  module Distributed
    class TestServerWorkers < LocalWorkers
      def initialize(options, test_server_config, connection_info)
        super(options)
        @test_server_config = test_server_config
        @connection_info = connection_info
      end
      
      def number_of_workers
        @test_server_config[:number_of_workers]
      end

      # Here we use DRb to communicate with the RemoteWorkerServer to avoid multiple processes
      # trying to use the same drbfire connection.  We have the RemoteWorkerServer proxy the
      # interaction with Server since the RemoteServerWorker can connect back to the Server trough a NAT.
      def server
        # we're in a new process (one of the workers on the test_server),
        # so stop the old server from RemoteWorkerServer
        DRb.stop_service
        
        # since RemoteWorkerServer now uses drbfire, we use it here to communicate with it
        DRb.start_service(@server_proxy.uri, nil, DRbFire::ROLE => DRbFire::CLIENT)
        
        DeepTest.logger.debug "LocalWorkers start_all worker starting with with blackboard: #{@server_proxy.uri.inspect} #{@server_proxy.inspect}"
        
        # finally, return a remote reference to the RemoteWorkerServer
        DRbObject.new_with_uri(@server_proxy.uri)
      end

      def start_all(server_proxy)
        @server_proxy = server_proxy
        super
        @warlock.exit_when_none_running
      end
    end
  end
end
