# frozen_string_literal: true

require "bundler/setup"
require "rivulet"
require "benchmark/ips"

data = (1..100_000).map { rand(1..100) }

puts "=== Window Types: fixed windows(10) over 100k items ==="
puts

Benchmark.ips do |x|
  x.report("sum windows") do
    Rivulet.sum(data).windows(10) { |w| w.average }
  end

  x.report("minmax windows") do
    Rivulet.minmax(data).windows(10) { |w| w.range }
  end

  x.report("count windows") do
    Rivulet.count(data).windows(10) { |w| w.distinct }
  end

  x.report("sum+mapper windows") do
    Rivulet.sum(data) { |x| x * 2 }.windows(10) { |w| w.average }
  end

  x.compare!
end
