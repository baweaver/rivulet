# frozen_string_literal: true

# Example: Rate Limit Detection
# Detect if any user exceeded N requests within a 60-second window.

require "bundler/setup"
require "rivulet"

# Simulate request timestamps for a single user (seconds since epoch)
# Normal traffic with a burst in the middle
base = 1_700_000_000
requests = [
  *20.times.map { |i| base + i * 5 },       # steady: 1 req per 5s
  *15.times.map { |i| base + 100 + i * 2 },  # burst: 1 req per 2s
  *10.times.map { |i| base + 200 + i * 10 }, # cool down
].sort

window_seconds = 60
max_requests = 10

puts "=== Rate Limit Detection ==="
puts "Requests: #{requests.size}"
puts "Window: #{window_seconds}s, limit: #{max_requests} requests"
puts

# Use Rivulet.sum with a mapper that computes time span, then use
# plain Ruby sliding window for time-based constraint since the window
# validity depends on timestamp differences (first to last).

# Time-based sliding window: find max requests fitting in window_seconds
# Use Rivulet.sum where each request = 1, constrained by time span
# Since we need (last - first) <= window_seconds, use max_window with sum
# tracking count, but we need the time span — use the index trick:
# map timestamps to deltas from previous, then sum of deltas = time span.

# Plain Ruby approach: sliding window over sorted timestamps
peak_count = 0
peak_start = 0
left = 0

requests.each_with_index do |t, right|
  # Shrink from left while span exceeds window
  left += 1 while requests[left] < t - window_seconds
  count = right - left + 1
  if count > peak_count
    peak_count = count
    peak_start = left
  end
end

puts "Peak requests in #{window_seconds}s window: #{peak_count}"
puts "  From: #{Time.at(requests[peak_start])} to #{Time.at(requests[peak_start + peak_count - 1])}"
puts "  Exceeded limit? #{peak_count > max_requests ? 'YES' : 'No'}"
