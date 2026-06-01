# frozen_string_literal: true

# Example: Typing Speed & Flow Detection
# Find when you were in flow (sustained high WPM) vs hitting a wall.

require "bundler/setup"
require "rivulet"

# Simulate WPM samples every minute during a 60-minute writing session
rng = Random.new(22)
wpm = [
  *10.times.map { 40 + rng.rand(-5..5) },    # warmup
  *20.times.map { 75 + rng.rand(-8..8) },    # flow state
  *5.times.map { 25 + rng.rand(-10..5) },    # hit a wall
  *15.times.map { 60 + rng.rand(-10..10) },  # recovered
  *10.times.map { 30 + rng.rand(-8..5) },    # fading
]

puts "=== Typing Speed & Flow Detection ==="
puts "Session: #{wpm.size} minutes"
puts "Average: #{(wpm.sum.to_f / wpm.size).round(1)} WPM"
puts

# Best 10-minute flow window
flow_avg = Rivulet.sum(wpm).windows(10).max_by { |w| w.average }
puts "Peak flow (10-min window): #{flow_avg} WPM avg"
puts

# Worst 5-minute slump
slump_avg = Rivulet.sum(wpm).windows(5).min_by { |w| w.average }
puts "Worst slump (5-min window): #{slump_avg} WPM avg"
puts

# Longest stretch above 60 WPM
above_60 = Rivulet.minmax(wpm)
  .max_window { |w| w.min >= 60 }
  .max_by { |w| w.size }

puts "Longest stretch above 60 WPM: #{above_60 || 0} minutes"
puts

# Detect "wall" moments: 5-min windows where average drops below 35
walls = Rivulet.sum(wpm).windows(5).each_window { |w| true if w.average < 35 }
puts "Wall moments (5-min avg < 35 WPM): #{walls.size}"
