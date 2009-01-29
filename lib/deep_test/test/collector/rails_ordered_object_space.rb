require 'test/unit/collector/objectspace'
module DeepTest
  module Test
    module Collector
      
      # This allows us to run tests in a similar order to how rails normal runs them
      # (i.e. units, functionals, integration) without having to mintain the test file
      # loading order and passing it down the line somehow.
      class RailsOrderedObjectSpace < ::Test::Unit::Collector::ObjectSpace
        
        # this is like ::Test::Unit::AutoRunner::COLLECTORS[:objectspace] in standard Test::Unit
        ::Test::Unit::AutoRunner::COLLECTORS[:rails_ordered_objectspace] = proc do |r|
          c = DeepTest::Test::Collector::RailsOrderedObjectSpace.new
          c.filter = r.filters
          c.collect($0.sub(/\.rb\Z/, ''))
        end

        def sort(suites)
          done = int = filter_and_sort_suites(suites, ActionController::IntegrationTest)
          done += func = filter_and_sort_suites(suites - done, ActionController::TestCase)
          done += others = filter_and_sort_suites(suites - done, ::Test::Unit::TestCase)
          
          ordered = others + func + int
          if ordered.size == suites.size
            ordered
          else
            oddballs = suites - ordered
            
            warn <<-STR

WARNING:
    Deep Test isn\'t sure it has preserved the standard test running order.
    Tests that aren\'t of the standard rails unit, functional, or integration
    classes will be run after those that are.

The #{oddballs.uniq.size} oddballs are of classes: #{oddballs.map(&:name).uniq.inspect}

oddballs:
#{oddballs.inspect}

STR
            ordered + oddballs
          end
        end
        
        def filter_and_sort_suites(suites, klass)
          suites.select {|s| s.name.constantize < klass}.sort_by {|s| suite_to_filename(s)}
        end
        
        def suite_to_filename(s)
          s.name.underscore + ".rb"
        end
        
      end
    end
  end
end
