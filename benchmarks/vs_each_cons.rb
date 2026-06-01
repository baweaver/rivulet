# frozen_string_literal: true

require "bundler/setup"
require "rivulet"
require "benchmark/ips"

data = (1..100_000).map { rand(1..100) }

puts "=== Moving Average: Rivulet vs each_cons vs hand-rolled ==="
puts "Data: 100k integers, window size: 5\n\n"

Benchmark.ips do |x|
  x.report("each_cons(5)") do
    data.each_cons(5).map { |w| w.sum.fdiv(5) }
  end

  x.report("Rivulet.sum windows(5)") do
    Rivulet.sum(data).windows(5) { |w| w.average }
  end

  x.report("hand-rolled O(1) sum") do
    result = []
    sum = 0
    buf = []
    data.each do |item|
      buf << item
      sum += item
      if buf.size > 5
        sum -= buf.shift
      end
      result << sum.fdiv(5) if buf.size == 5
    end
    result
  end

  x.compare!
end
