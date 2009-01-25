module DeepTest
  module Test
    class SupervisedTestSuite
      def initialize(suite, blackboard)
        @suite = suite
        @blackboard = blackboard
      end

      def run(result, &progress_block)
        yield ::Test::Unit::TestSuite::STARTED, @suite.name
        tests_by_name = {}
        add_tests @suite, tests_by_name
        read_results result, tests_by_name, &progress_block
        yield ::Test::Unit::TestSuite::FINISHED, @suite.name
      end

      def size
        @suite.size
      end

      def add_tests(test_suite, tests_by_name)
        if test_suite.respond_to? :tests
          test_suite.tests.each do |test| 
            add_tests(test, tests_by_name)
          end
        else
          tests_by_name[test_suite.name] = test_suite
          @blackboard.write_work Test::WorkUnit.new(test_suite)
        end
      end

      def read_results(result, tests_by_name)
        DeepTest.logger.debug("SupervisedTestSuite: going to read #{tests_by_name.size} results")

        result_times = {}
        
        missing_tests = 
          ResultReader.new(@blackboard).read(tests_by_name) do |test, remote_result|
            result_times["#{test.method_name}(#{test.class.name})"] = remote_result.time
            remote_result.add_to result
            yield ::Test::Unit::TestCase::FINISHED, test.name if block_given?
          end
        
        longest_test_name_size = result_times.keys.map(&:size).sort.last
        if File.exist? "tmp"
          File.open(File.join("tmp", "test_times.txt"), "w") do |file|
            file.write result_times.sort_by {|n, t| t}.reverse.map {|n, t| n.ljust(longest_test_name_size + 1) + t.to_s.sub(/^(.*\.\d)\d.*/, '\1').rjust(9) + "\n"}.join
          end
        end

        missing_tests.each do |name, test_case|
          result.add_error ::Test::Unit::Error.new(name, WorkUnitNeverReceivedError.new)
        end
      ensure
        DeepTest.logger.debug("SupervisedTestSuite: exiting with #{missing_tests.size} results left")
      end
    end
  end
end
