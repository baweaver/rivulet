# frozen_string_literal: true

# Example: Background Job Throughput
# Monitor Sidekiq/GoodJob processing rates to detect queue stalls.
# Alert if throughput drops below a threshold over a rolling window.

require "bundler/setup"
require "rivulet"

# Simulate jobs-per-minute over 2 hours (120 data points)
# Normal: ~50 jobs/min, with a stall at minutes 45-55
rng = Random.new(77)
throughput = 120.times.map do |minute|
  base = 50
  stall = minute.between?(45, 55) ? -40 : 0
  [0, base + stall + rng.rand(-8..8)].max
end

min_throughput = 20  # alert if rolling average drops below this
window_size = 10     # 10-minute rolling window

puts "=== Background Job Throughput ==="
puts "Duration: #{throughput.size} minutes"
puts "Alert threshold: < #{min_throughput} jobs/min (#{window_size}-min average)"
puts

# Find all windows where average throughput is below threshold
stall_windows = Rivulet.sum(throughput)
  .windows(window_size)
  .each_window { |w| w.average if w.average < min_throughput }

puts "Stall periods detected: #{stall_windows.size}"
if stall_windows.any?
  puts "  Worst window: #{stall_windows.min.round(1)} jobs/min avg"
end
puts

# Peak throughput window
peak = Rivulet.sum(throughput).windows(window_size).max_by { |w| w.average }
puts "Peak #{window_size}-min window: #{peak.round(1)} jobs/min avg"
