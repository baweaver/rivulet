# frozen_string_literal: true

# Example: Weather "Nice Day" Streaks
# Find the longest stretch of perfect weather days.

require "bundler/setup"
require "rivulet"

# Simulate 90 days of high temps (°F) — spring into summer
rng = Random.new(44)
temps = 90.times.map do |day|
  seasonal = 55 + day * 0.4 + Math.sin(day / 7.0) * 8
  (seasonal + rng.rand(-8.0..8.0)).round(1)
end

# Simulate rain: 1 = rain, 0 = dry
rain = 90.times.map { rng.rand < 0.2 ? 1 : 0 }

nice_low = 65.0
nice_high = 80.0

puts "=== Weather Nice Day Streaks ==="
puts "Days: #{temps.size}"
puts "Nice range: #{nice_low}°F - #{nice_high}°F, no rain"
puts

# Longest streak of nice temps (in range)
nice_temp_streak = Rivulet.minmax(temps)
  .max_window { |w| w.min >= nice_low && w.max <= nice_high }
  .max_by { |w| w.size }

puts "Longest nice-temp streak: #{nice_temp_streak || 0} days"
puts

# Longest dry streak
dry_streak = Rivulet.sum(rain)
  .max_window { |w| w.sum == 0 }
  .max_by { |w| w.size }

puts "Longest dry streak: #{dry_streak} days"
puts

# Longest streak of BOTH nice temp AND no rain
nice_days = temps.zip(rain).map { |t, r| (t >= nice_low && t <= nice_high && r == 0) ? 1 : 0 }
perfect_streak = Rivulet.sum(nice_days)
  .max_window { |w| w.sum == w.size }
  .max_by { |w| w.size }

puts "Longest perfect weather streak: #{perfect_streak || 0} days"
puts

# Hottest 7-day stretch
hottest_week = Rivulet.sum(temps).windows(7).max_by { |w| w.average }
puts "Hottest week: #{hottest_week.round(1)}°F avg"
