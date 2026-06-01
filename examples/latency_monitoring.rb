# frozen_string_literal: true

# Example: Service Latency Monitoring
# Compute moving averages and detect anomalous spikes.

require "bundler/setup"
require "rivulet"

# Simulate 1000 latency samples (ms) with a few spikes
rng = Random.new(42)
latencies = 1000.times.map do |i|
  base = 50 + Math.sin(i / 50.0) * 10
  spike = (i.between?(400, 410) || i.between?(700, 705)) ? rng.rand(200..500) : 0
  (base + rng.rand(-5.0..5.0) + spike).round(1)
end

puts "=== Service Latency Monitoring ==="
puts "Samples: #{latencies.size}"
puts "Baseline: ~50ms, spikes at positions 400-410 and 700-705"
puts

# 20-sample moving average
averages = Rivulet.sum(latencies).windows(20) { |w| w.average }
puts "Moving average (window=20): #{averages.size} data points"
puts "  Min avg: #{averages.min.round(1)}ms"
puts "  Max avg: #{averages.max.round(1)}ms"
puts

# Detect windows where the spread (max - min) exceeds a threshold
# This finds the volatile regions
volatile_windows = Rivulet.minmax(latencies)
  .windows(10)
  .each_window { |w| w if w.range > 100 }

puts "Volatile windows (range > 100ms, window=10): #{volatile_windows.size}"
puts

# Find the single worst 10-sample window by range
worst_range = Rivulet.minmax(latencies)
  .max_range_while { |w| w.size <= 10 }

puts "Worst range in any 10-sample window: #{worst_range}ms"
puts

# Rolling P95 approximation: find windows where >5% of values exceed threshold
threshold = 100
hot_windows = Rivulet.count(latencies.map { |l| l > threshold ? :hot : :ok })
  .windows(50)
  .each_window { |w| w if w.counts[:hot].to_i > 2 }

puts "Windows (size=50) with >5% over #{threshold}ms: #{hot_windows.size}"
