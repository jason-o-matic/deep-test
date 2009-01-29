module DeepTest
  module Test
    class WorkResult < ::Test::Unit::TestResult
      attr_reader :identifier
      attr_accessor :output, :time, :host

      def initialize(identifier)
        super()
        @identifier = identifier
      end

      def add_to(result)
        @failures.each {|e| result.add_failure(e)}

        @errors.each do |e| 
          e.resolve_marshallable_exception
          result.add_error(e)
        end

        assertion_count.times {result.add_assertion}
        run_count.times {result.add_run}
      end
      
      # repackage failure to include host
      def add_failure(failure)
        super(failure.class.new(failure.test_name + " [#{@host}]", failure.location, failure.message))
      end

      # repackage error to include host
      def add_error(error)
        e = error.class.new(error.test_name + " [#{@host}]", error.exception)
        e.make_exception_marshallable
        super(e)
      end
      
      def failed_due_to_deadlock?
        @errors.any? && DeepTest::DeadlockDetector.due_to_deadlock?(@errors.last)
      end
    end
  end
end
