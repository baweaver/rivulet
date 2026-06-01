# frozen_string_literal: true

# Example: Reading Streak Tracker
# Find your longest consecutive daily reading streak.

require "bundler/setup"
require "rivulet"
require "date"

# Simulate reading dates over 3 months (some gaps)
rng = Random.new(55)
start = Date.new(2024, 1, 1)
dates = (0..89).select { |d| rng.rand < 0.75 }.map { |d| start + d }

puts "=== Reading Streak Tracker ==="
puts "Days with reading: #{dates.size} / 90"
puts

# Convert to day numbers for gap detection
days = dates.map(&:jd)

# Longest streak: window is valid while each consecutive pair has gap = 1
longest = Rivulet.minmax(days)
  .max_window { |w| w.range == w.size - 1 }
  .max_by { |w| w.size }

puts "Longest streak: #{longest} days"
puts

# Current streak (from the end)
current = Rivulet.minmax(days.reverse)
  .max_window { |w| w.range == w.size - 1 }
  .first { |w| w.size }

puts "Current streak: #{current} days"
