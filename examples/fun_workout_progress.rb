# frozen_string_literal: true

# Example: Workout Progression
# Find your best 4-week improvement window and detect plateaus.

require "bundler/setup"
require "rivulet"

# Simulate 16 weeks of squat max (lbs), with a plateau in the middle
weights = [
  185, 190, 195, 200, 205, 210, 215, 220,  # steady gains
  220, 222, 221, 220, 222, 221, 220, 222,  # plateau
  225, 230, 235, 240, 245, 250, 255, 260,  # breakthrough
]

puts "=== Workout Progression ==="
puts "Weeks tracked: #{weights.size}"
puts "Start: #{weights.first} lbs, Current: #{weights.last} lbs"
puts

# Best 4-week improvement (max range in any 4-week window)
best_range = Rivulet.minmax(weights).windows(4).max_by { |w| w.range }
puts "Best 4-week block: +#{best_range} lbs"
puts

# Detect plateaus: 4-week windows where range <= 5 lbs
plateaus = Rivulet.minmax(weights).windows(4).each_window { |w| w.range if w.range <= 5 }
puts "Plateau windows (range <= 5 lbs): #{plateaus.size}"
plateaus.each_with_index do |range, i|
  puts "  Plateau #{i + 1}: range #{range} lbs"
end
puts

# Longest PR streak: each week strictly higher than the previous
# Use plain Ruby since we need to compare consecutive elements
longest_pr = weights.each_cons(2).chunk { |a, b| b > a }.filter_map { |increasing, pairs| pairs.size + 1 if increasing }.max || 0
puts "Longest PR streak: #{longest_pr} weeks"
