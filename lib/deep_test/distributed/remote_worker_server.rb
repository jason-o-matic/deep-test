require 'pp'
module DeepTest
  module Distributed
    class RemoteWorkerServer
      include DRb::DRbUndumped

      MERCY_KILLING_GRACE_PERIOD = 10 * 60 unless defined?(MERCY_KILLING_GRACE_PERIOD)
      
      attr_accessor :uri

      def initialize(base_path, workers, options)
        @base_path = base_path
        @workers = workers
        @options = options
        
        @resolver = FilenameResolver.new(@base_path)
        @options.libs.each { |l| $: << @resolver.resolve(l) }
        @options.requires.each { |r| require r }
      end

      def launch_mercy_killer(grace_period)
        Thread.new do
          sleep grace_period
          exit(0) unless workers_started?
        end
      end

      def load_files(files)
        @options.new_listener_list.before_remote_load_files
        
        Dir.chdir @base_path
        resolver = FilenameResolver.new(@base_path)
        
        files.each do |file|
          load resolver.resolve(file)
        end
      rescue Exception => e
        puts e.message
        pp e.backtrace
        raise
      end

      def start_all
        @workers_started = true
        @workers.start_all(self)
      end

      def stop_all
        Thread.new do
          @workers.stop_all
        end
      end

      def workers_started?
        @workers_started
      end

      def self.warlock
        @warlock ||= DeepTest::Warlock.new
      end

      def self.running_server_count
        @warlock.demon_count if @warlock
      end

      def self.stop_all
        @warlock.stop_all if @warlock
      end

      def self.start(address, base_path, workers, options, grace_period = MERCY_KILLING_GRACE_PERIOD)
        innie, outie = IO.pipe

        warlock.start("RemoteWorkerServer") do
          innie.close

          server = new(base_path, workers, options)
          
          # this is half the magic that lets us work through the NAT
          DRb.start_service("drbfire://#{address}:0", server, DRbFire::ROLE => DRbFire::SERVER, DRbFire::DELEGATE => DRbBindAllTCPSocket)
          DeepTest.logger.info "RemoteWorkerServer started at #{DRb.uri}"

          server.uri = DRb.uri
          
          outie.write DRb.uri
          outie.close

          server.launch_mercy_killer(grace_period)

          DRb.thread.join
        end

        outie.close
        uri = innie.gets
        innie.close
        DRbObject.new_with_uri(uri)
      end
      
      ######################################################################################
      # These methods allow us to proxy the Server through the NAT
      ######################################################################################
      def drbserver=(drbserver)
        DeepTest.logger.debug "Setting the Server remote reference to: #{drbserver.inspect}"
        @drbserver = drbserver
      end
      def take_work
        DeepTest.logger.debug "Remote worker server proxying 'take_work' back to Server"
        @drbserver.take_work
      end
      def write_result(res)
        @drbserver.write_result res
      end

    end
  end
end
