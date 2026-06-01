# frozen_string_literal: true

require "bundler/setup"
require "rivulet"
require "benchmark/ips"

data = (1..200_000).map { rand(1..100) }
budget = 500

puts "=== Builder vs Reduce: max window size under budget ==="
puts "Data: 200k integers, budget: #{budget}\n\n"

Benchmark.ips do |x|
  x.report("builder (max_window.max_by)") do
    Rivulet.sum(data).max_window { |w| w.sum <= budget }.max_by { |w| w.size }
  end

  x.report("reducer (max_size_while)") do
    Rivulet.sum(data).max_size_while { |w| w.sum <= budget }
  end

  x.report("windows(5) { average }") do
    Rivulet.sum(data).windows(5) { |w| w.average }
  end

  x.compare!
end
