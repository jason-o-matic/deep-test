module DeepTest
  module Distributed
    class DispatchController
      def initialize(options, receivers)
        @options = options
        @receivers = receivers
      end

      def dispatch(method_name, *args)
        dispatch_with_options(method_name, {}, *args)
      end

      def dispatch_with_options(method_name, options, *args)
        raise NoDispatchReceiversError if @receivers.empty?

        @options.ui_instance.dispatch_starting(method_name)

        threads = @receivers.map do |r|
          Thread.new do
            Thread.current[:receiver] = r
            Timeout.timeout(@options.timeout_in_seconds) do
              begin
                DeepTest.logger.debug "Dispatching to #{r.inspect}: #{method_name}(*#{args.inspect})"
                r.send method_name, *args
              rescue Exception => ex
                DeepTest.logger.debug "DISPATCH EXCEPTION from #{r.inspect}: #{ex.message}\n#{ex.backtrace.join("\n")}"
                raise
              end
            end
          end
        end

        results = []
        threads.each do |t|
          begin
            results << t.value
          rescue Timeout::Error
            @receivers.delete t[:receiver]
            DeepTest.logger.error "Timeout dispatching #{method_name} to #{t[:receiver].__drburi}"
          rescue DRb::DRbConnError
            @receivers.delete t[:receiver]
            unless options[:ignore_connection_error]
              DeepTest.logger.error "Connection Refused dispatching #{method_name} to #{t[:receiver].__drburi}"
            end
          rescue Exception => e
            @receivers.delete t[:receiver]
            DeepTest.logger.error "Exception while dispatching #{method_name} to #{t[:receiver].__drburi} #{e.message}\n#{e.backtrace.join("\n")}"
          end
        end

        results
      ensure
        @options.ui_instance.dispatch_finished(method_name)
      end
    end

    class NoDispatchReceiversError < StandardError; end
  end
end
