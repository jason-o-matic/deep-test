module DeepTest
  class Worker
    attr_reader :number

    def initialize(number, blackboard, worker_listener)
      @number = number
      @blackboard = blackboard
      @listener = worker_listener
    end

    def run
      @listener.starting(self)
      while work_unit = next_work_unit
        @listener.starting_work(self, work_unit)

        start_time = Time.now
        result = begin
                   work_unit.run
                 rescue Exception => error
                   Error.new(work_unit, error)
                 end
        result.time = Time.now - start_time
        result.host = Socket.gethostname

        @listener.finished_work(self, work_unit, result)
        @blackboard.write_result result
        if ENV['DEEP_TEST_SHOW_WORKER_DOTS'] == 'yes'
          $stdout.print '.'
          $stdout.flush
        end
      end
    rescue Server::NoWorkUnitsRemainingError
      DeepTest.logger.debug("Worker #{number}: no more work to do")
    rescue Exception => e
      DeepTest.logger.debug "Worker #{number} EXCEPTION: #{e.message}\n#{e.backtrace.join("\n")}"
      raise
    end

    def next_work_unit
      DeepTest.logger.debug "Worker #{number} getting next work unit from: #{@blackboard.inspect}"
      @blackboard.take_work
    rescue Server::NoWorkUnitsAvailableError
      sleep 0.02
      retry
    end

    class Error
      attr_accessor :work_unit, :error

      def initialize(work_unit, error)
        @work_unit, @error = work_unit, error
      end

      def ==(other)
        work_unit == other.work_unit &&
            error == other.error
      end

      def to_s
        "#{@work_unit}: #{@error}\n" + (@error.backtrace || []).join("\n")
      end
    end
  end
end
