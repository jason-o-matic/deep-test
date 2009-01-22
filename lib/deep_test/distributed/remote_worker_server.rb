require 'pp'
module DeepTest
  module Distributed
    class RemoteWorkerServer
      include DRb::DRbUndumped

      MERCY_KILLING_GRACE_PERIOD = 10 * 60 unless defined?(MERCY_KILLING_GRACE_PERIOD)

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
# # puts "LOAD FILES: #{files.inspect}"
        @options.new_listener_list.before_remote_load_files
# # $: << "#{@base_path}/lib"
# # puts "RWS LOAD FILES workers: #{@workers.instance_variable_get("@options").new_listener_list.before_remote_load_files.inspect}"
        Dir.chdir @base_path
        resolver = FilenameResolver.new(@base_path)
# # # # require File.expand_path("#{@base_path}/config/environment")
# $: << "#{@base_path}/vendor/rails/activerecord/lib"
# # # # require File.expand_path("#{@base_path}/vendor/rails/activerecord/lib/active_record")
# require "active_record"
# # # # require 'vendor/rails/railties/lib/initializer'
# require File.expand_path("#{@base_path}/lib/my_mysql_setup_listener")
# # # # DeepTest::Database::MysqlSetupListener.new.starting(Struct.new(:number).new(123))
# w = MyMysqlSetupListener.new
# w.starting(Struct.new(:number).new(123))
# ENV["DEEP_TEST_DB"] = w.worker_database        
        
        
#         Dir.chdir @base_path
#         resolver = FilenameResolver.new(@base_path)
        files.each do |file|
#           puts file
          load resolver.resolve(file)
        end
      rescue Exception => e
        puts e.message
        pp e.backtrace
        raise
      end

      def drbserver=(drbserver)
        puts "REMOTE WORKER SERVER drbserver= #{drbserver.inspect}"
#         puts "FOO: #{drbserver.map {|s| s.foo}.inspect}"
        puts "FOO: #{drbserver.foo.inspect}"
        @drbserver = drbserver
      end
      
      def start_all(drbserver)
        @workers_started = true
        @workers.start_all(@drbserver)
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

#           DRb.start_service("drubyall://#{address}:0", server)
#           DRb.start_service("drbfire://#{address}:34567", server, DRbFire::ROLE => DRbFire::SERVER)
#           DRb.start_service("drbfire://#{address}:0", server, DRbFire::ROLE => DRbFire::SERVER, DRbFire::DELEGATE => DRbBindAllTCPSocket, "delegate_scheme" => "drubyall")
          DRb.start_service("drbfire://#{address}:0", server, DRbFire::ROLE => DRbFire::SERVER, DRbFire::DELEGATE => DRbBindAllTCPSocket)
          DeepTest.logger.info "RemoteWorkerServer started at #{DRb.uri}"

          outie.write DRb.uri
          outie.close

          server.launch_mercy_killer(grace_period)

          DRb.thread.join
        end

        outie.close
        uri = innie.gets
        innie.close
  puts "RWS START URI: #{uri.inspect}"
        DRbObject.new_with_uri(uri)
      end

    end
  end
end
