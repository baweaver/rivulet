# frozen_string_literal: true

# Example: Stock Price Analysis
# Rolling min/max spread, moving average crossover detection.

require "bundler/setup"
require "rivulet"

# Simulate 500 days of stock prices with trend + noise
rng = Random.new(99)
prices = 500.times.each_with_object([100.0]) do |i, arr|
  trend = Math.sin(i / 80.0) * 20
  noise = rng.rand(-3.0..3.0)
  arr << (arr.last + trend * 0.05 + noise).round(2)
end

puts "=== Stock Price Analysis ==="
puts "Days: #{prices.size}"
puts "Price range: $#{prices.min} - $#{prices.max}"
puts

# 20-day and 50-day moving averages
ma20 = Rivulet.sum(prices).windows(20) { |w| w.average }
ma50 = Rivulet.sum(prices).windows(50) { |w| w.average }

puts "20-day MA: #{ma20.size} points, last: $#{ma20.last.round(2)}"
puts "50-day MA: #{ma50.size} points, last: $#{ma50.last.round(2)}"
puts

# Detect golden/death crosses using Rivulet on the spread series
# Align: MA50 starts 30 days after MA20
offset = 50 - 20
spread = ma20[offset..].zip(ma50).map { |short, long| short - long }

# A crossing is where the spread changes sign — use windows(2) to detect
signs = spread.map { |s| s >= 0 ? 1 : -1 }
crossings = Rivulet.sum(signs)
  .windows(2)
  .each_window { |w| w if w.sum.abs < 2 }

puts "MA crossovers detected: #{crossings.size}"
puts

# Widest 20-day price spread (reduce — no snapshots)
max_spread = Rivulet.minmax(prices).max_range_while { |w| w.size <= 20 }
puts "Widest 20-day price spread: $#{max_spread.round(2)}"
puts

# Most volatile 10-day window
worst_range = Rivulet.minmax(prices).windows(10).max_by { |w| w.range }
puts "Most volatile 10-day window:"
puts "  Range: $#{worst_range.round(2)}"
