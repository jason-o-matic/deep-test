require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "start_all delegates to worker implementation" do
    options = DeepTest::Options.new(:libs => [], :requires => [])
    server = DeepTest::Distributed::RemoteWorkerServer.new("", implementation = mock, options)
    implementation.expects(:start_all)
    server.start_all
  end

  test "stop_all delegates to worker implementation" do
    options = DeepTest::Options.new(:libs => [], :requires => [])
    server = DeepTest::Distributed::RemoteWorkerServer.new("", implementation = mock, options)
    implementation.expects(:stop_all)
    server.stop_all
  end

  test "stop_all returns without waiting for stops" do
    implementation = Object.new.instance_eval do
      def done?
        @done == true
      end

      def stop_all
        sleep 0.01
        @done = true
      end
      self
    end
    options = DeepTest::Options.new(:libs => [], :requires => [])

    server = DeepTest::Distributed::RemoteWorkerServer.new("", implementation, options)
    server.stop_all
    assert_equal false, implementation.done?

    until implementation.done?
      sleep 0.01
    end
  end
  
  test "load_files loads each file in list, resolving each filename with resolver" do
    options = DeepTest::Options.new(:libs => [], :requires => [])
    DeepTest::Distributed::FilenameResolver.expects(:new).times(2).with("/mirror/dir").
      returns(resolver = mock)

    server = DeepTest::Distributed::RemoteWorkerServer.new("/mirror/dir", stub_everything, options)

    resolver.expects(:resolve).with("/source/path/my/file.rb").
      returns("/mirror/dir/my/file.rb")
    server.expects(:load).with("/mirror/dir/my/file.rb")
    Dir.expects(:chdir).with("/mirror/dir")

    server.load_files(["/source/path/my/file.rb"])
  end

  test "service is removed after grace period if workers haven't been started" do
    options = DeepTest::Options.new(:libs => [], :requires => [])
    log_level = DeepTest.logger.level
    begin
      DeepTest.logger.level = Logger::ERROR
      DeepTest::Distributed::RemoteWorkerServer.start(
        "localhost",                                              
        "base_path",
        stub_everything,
        options,
        0.25
      )
      # Have to sleep long enough to warlock to reap dead process
      sleep 1.0
      assert_equal 0, DeepTest::Distributed::RemoteWorkerServer.running_server_count
    ensure
      begin
        DeepTest::Distributed::RemoteWorkerServer.stop_all
      ensure
        DeepTest.logger.level = log_level
      end
    end
  end

  test "service is not removed after grace period if workers have been started" do
    options = DeepTest::Options.new(:libs => [], :requires => [])
    log_level = DeepTest.logger.level
    begin
      DeepTest.logger.level = Logger::ERROR
      server = nil
      capture_stdout do
        server = DeepTest::Distributed::RemoteWorkerServer.start(
          Socket.gethostname,
          "", 
          stub_everything,
          options,
          0.25
        )
      end
      server.start_all
      # Have to sleep long enough to warlock to reap dead process
      sleep 1.0
      assert_equal 1, DeepTest::Distributed::RemoteWorkerServer.running_server_count
    ensure
      begin
        DeepTest::Distributed::RemoteWorkerServer.stop_all
      ensure
        DeepTest.logger.level = log_level
      end
    end
  end
end
