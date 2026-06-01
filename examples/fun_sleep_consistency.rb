# frozen_string_literal: true

# Example: Sleep Consistency
# Find your most consistent and most chaotic weeks by bedtime variance.

require "bundler/setup"
require "rivulet"

# Simulate 6 weeks of bedtimes as minutes past midnight
# (e.g., 1380 = 11:00 PM, 1440 = midnight, 1500 = 1:00 AM)
rng = Random.new(88)
bedtimes = [
  # Week 1: consistent (11pm ± 15min)
  *7.times.map { 1380 + rng.rand(-15..15) },
  # Week 2: chaotic (varies 10pm to 2am)
  *7.times.map { 1380 + rng.rand(-120..180) },
  # Week 3: consistent again
  *7.times.map { 1410 + rng.rand(-10..10) },
  # Week 4: drifting later
  *7.times.map { |d| 1400 + d * 20 + rng.rand(-10..10) },
  # Week 5: very consistent early
  *7.times.map { 1350 + rng.rand(-5..5) },
  # Week 6: weekend chaos
  *5.times.map { 1380 + rng.rand(-10..10) },
  1500 + rng.rand(0..60), 1560 + rng.rand(0..60),
]

def format_time(minutes)
  h = (minutes / 60) % 24
  m = minutes % 60
  "%d:%02d %s" % [h == 0 ? 12 : (h > 12 ? h - 12 : h), m, h >= 12 ? "AM" : "PM"]
end

puts "=== Sleep Consistency ==="
puts "Days tracked: #{bedtimes.size}"
puts

# Most consistent 7-day window (smallest range)
most_consistent_range = Rivulet.minmax(bedtimes).windows(7).min_by { |w| w.range }
puts "Most consistent week: #{most_consistent_range} min spread"
puts

# Most chaotic week (largest range)
most_chaotic = Rivulet.minmax(bedtimes).windows(7).max_by { |w| w.range }
puts "Most chaotic week: #{most_chaotic} min spread"
puts

# Average bedtime over rolling 7-day windows
averages = Rivulet.sum(bedtimes).windows(7) { |w| w.average }
puts "Bedtime trend (7-day avg): #{format_time(averages.first.round)} → #{format_time(averages.last.round)}"
