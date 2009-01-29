# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{deep_test}
  s.version = "1.2.2.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["anonymous z, Dan Manges, David Vollbracht"]
  s.date = %q{2008-10-11}
  s.default_executable = %q{deep_test}
  s.description = %q{DeepTest runs tests in multiple processes.}
  s.email = %q{daniel.manges@gmail.com}
  s.executables = ["deep_test"]
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG"]
  s.files = ["lib/deep_test/test/collector/rails_ordered_object_space.rb", "lib/deep_test/drbfire.rb", "lib/deep_test/database/mysql_setup_listener.rb", "lib/deep_test/database/setup_listener.rb", "lib/deep_test/deadlock_detector.rb", "lib/deep_test/distributed/dispatch_controller.rb", "lib/deep_test/distributed/drb_client_connection_info.rb", "lib/deep_test/distributed/filename_resolver.rb", "lib/deep_test/distributed/master_test_server.rb", "lib/deep_test/distributed/multi_test_server_proxy.rb", "lib/deep_test/distributed/null_work_unit.rb", "lib/deep_test/distributed/remote_worker_client.rb", "lib/deep_test/distributed/remote_worker_server.rb", "lib/deep_test/distributed/rsync.rb", "lib/deep_test/distributed/test_server.rb", "lib/deep_test/distributed/test_server_status.rb", "lib/deep_test/distributed/test_server_workers.rb", "lib/deep_test/distributed/throughput_runner.rb", "lib/deep_test/distributed/throughput_statistics.rb", "lib/deep_test/distributed/throughput_worker_client.rb", "lib/deep_test/extensions/drb_extension.rb", "lib/deep_test/extensions/object_extension.rb", "lib/deep_test/listener_list.rb", "lib/deep_test/local_workers.rb", "lib/deep_test/logger.rb", "lib/deep_test/marshallable_exception_wrapper.rb", "lib/deep_test/metrics/gatherer.rb", "lib/deep_test/metrics/queue_lock_wait_time_measurement.rb", "lib/deep_test/null_worker_listener.rb", "lib/deep_test/option.rb", "lib/deep_test/options.rb", "lib/deep_test/process_orchestrator.rb", "lib/deep_test/rake_tasks.rb", "lib/deep_test/result_reader.rb", "lib/deep_test/rspec_detector.rb", "lib/deep_test/server.rb", "lib/deep_test/spec/extensions/example_group_methods.rb", "lib/deep_test/spec/extensions/example_methods.rb", "lib/deep_test/spec/extensions/options.rb", "lib/deep_test/spec/extensions/reporter.rb", "lib/deep_test/spec/extensions/spec_task.rb", "lib/deep_test/spec/runner.rb", "lib/deep_test/spec/work_result.rb", "lib/deep_test/spec/work_unit.rb", "lib/deep_test/spec.rb", "lib/deep_test/test/extensions/error.rb", "lib/deep_test/test/runner.rb", "lib/deep_test/test/supervised_test_suite.rb", "lib/deep_test/test/work_result.rb", "lib/deep_test/test/work_unit.rb", "lib/deep_test/test.rb", "lib/deep_test/test_task.rb", "lib/deep_test/ui/console.rb", "lib/deep_test/ui/null.rb", "lib/deep_test/warlock.rb", "lib/deep_test/worker.rb", "lib/deep_test.rb", "lib/deep_test/distributed/show_status.rhtml", "script/internal/run_test_suite.rb", "script/public/master_test_server.rb", "script/public/test_server.rb", "script/public/test_throughput.rb", "test/deep_test/database/mysql_setup_listener_test.rb", "test/deep_test/distributed/dispatch_controller_test.rb", "test/deep_test/distributed/drb_client_connection_info_test.rb", "test/deep_test/distributed/filename_resolver_test.rb", "test/deep_test/distributed/master_test_server_test.rb", "test/deep_test/distributed/multi_test_server_proxy_test.rb", "test/deep_test/distributed/remote_worker_client_test.rb", "test/deep_test/distributed/remote_worker_server_test.rb", "test/deep_test/distributed/rsync_test.rb", "test/deep_test/distributed/test_server_test.rb", "test/deep_test/distributed/test_server_workers_test.rb", "test/deep_test/distributed/throughput_runner_test.rb", "test/deep_test/distributed/throughput_worker_client_test.rb", "test/deep_test/extensions/object_extension_test.rb", "test/deep_test/listener_list_test.rb", "test/deep_test/local_workers_test.rb", "test/deep_test/logger_test.rb", "test/deep_test/marshallable_exception_wrapper_test.rb", "test/deep_test/metrics/gatherer_test.rb", "test/deep_test/process_orchestrator_test.rb", "test/deep_test/result_reader_test.rb", "test/deep_test/server_test.rb", "test/deep_test/test/extensions/error_test.rb", "test/deep_test/test/runner_test.rb", "test/deep_test/test/supervised_test_suite_test.rb", "test/deep_test/test/work_result_test.rb", "test/deep_test/test/work_unit_test.rb", "test/deep_test/test_task_test.rb", "test/deep_test/ui/console_test.rb", "test/deep_test/warlock_test.rb", "test/deep_test/worker_test.rb", "test/failing.rb", "test/fake_deadlock_error.rb", "test/simple_test_blackboard.rb", "test/simple_test_blackboard_test.rb", "test/test_factory.rb", "test/test_helper.rb", "test/test_task_test.rb", "test/failing.rake", "README.rdoc", "CHANGELOG", "Rakefile", "bin/deep_test"]
  s.has_rdoc = true
  s.homepage = %q{http://deep-test.rubyforge.org}
  s.rdoc_options = ["--title", "DeepTest", "--main", "README.rdoc", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{deep-test}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{DeepTest runs tests in multiple processes.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
