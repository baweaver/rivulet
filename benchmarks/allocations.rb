# frozen_string_literal: true

require "bundler/setup"
require "rivulet"

data = (1..200_000).map { rand(1..100) }
budget = 500

def count_allocations
  before = GC.stat[:total_allocated_objects]
  yield
  GC.stat[:total_allocated_objects] - before
end

puts "=== Object Allocations: 200k items, budget #{budget} ==="
puts

results = {
  "max_window.max_by { size }" => count_allocations {
    Rivulet.sum(data).max_window { |w| w.sum <= budget }.max_by { |w| w.size }
  },
  "max_size_while (reducer)" => count_allocations {
    Rivulet.sum(data).max_size_while { |w| w.sum <= budget }
  },
  "windows(5) { average }" => count_allocations {
    Rivulet.sum(data).windows(5) { |w| w.average }
  },
  "windows(5).each_window { average }" => count_allocations {
    Rivulet.sum(data).windows(5).each_window { |w| w.average }
  },
}

results.each do |label, allocs|
  puts "  %-40s %10d objects" % [label, allocs]
end
