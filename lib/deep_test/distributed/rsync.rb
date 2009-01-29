module DeepTest
  module Distributed
    class RSync
      def self.sync(connection_info, options, destination)
        command = Args.new(connection_info, options).command(destination)
        DeepTest.logger.debug("rsycing: #{command}")
        output = `#{command}`
        raise "RSync Failed!!\nCommand failed: #{command}\nWith output:\nBEGIN#{'=' * 80}\n#{output}\nEND#{'=' * 82}" unless $?.success?
        output
      end

      class Args
        def initialize(connection_info, options)
          @connection_info = connection_info
          @options = options
          @sync_options = options.sync_options
          raise "Pushing code to a daemon isn't supported at the moment" if @sync_options[:daemon] && @sync_options[:push_code]
        end

        def command(destination)
          # The '/' after source tells rsync to copy the contents
          # of source to destination, rather than the source directory
          # itself
          "rsync -az --delete #{@sync_options[:rsync_options]} #{source_location}/ #{destination_location(destination)} 2>&1".strip.squeeze(" ")
        end

        def source_location
          loc = ""
          loc << common_location_options unless @sync_options[:local] || @sync_options[:push_code]
          loc << @sync_options[:source]
        end

        def destination_location(destination)
          loc = ""
          loc << common_location_options unless @sync_options[:local] || !@sync_options[:push_code]
          loc << destination
        end
        
        def common_location_options
          loc = ""
          loc << @sync_options[:username] << '@' if @sync_options[:username]
          loc << @connection_info.address
          loc << (@sync_options[:daemon] ? '::' : ':')
        end
      end
    end
  end
end
