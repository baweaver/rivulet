# frozen_string_literal: true

# Example: Game Win Streaks
# Find longest win/loss streaks and best win-rate window.

require "bundler/setup"
require "rivulet"

# Simulate 50 ranked matches: 1 = win, 0 = loss
rng = Random.new(7)
matches = 50.times.map { rng.rand < 0.6 ? 1 : 0 }

wins = matches.count(1)
puts "=== Game Win Streaks ==="
puts "Matches: #{matches.size}, Wins: #{wins}, Losses: #{matches.size - wins}"
puts "Overall win rate: #{(wins.to_f / matches.size * 100).round(1)}%"
puts

# Longest win streak (window valid while all are wins)
win_streak = Rivulet.sum(matches)
  .max_window { |w| w.sum == w.size }
  .max_by { |w| w.size }

puts "Longest win streak: #{win_streak}"
puts

# Longest loss streak (window valid while all are losses)
loss_streak = Rivulet.sum(matches)
  .max_window { |w| w.sum == 0 }
  .max_by { |w| w.size }

puts "Longest loss streak: #{loss_streak}"
puts

# Best 10-game window by win rate
best_avg = Rivulet.sum(matches).windows(10).max_by { |w| w.average }
puts "Best 10-game stretch: #{(best_avg * 100).round(0)}% win rate"
puts

# Worst 10-game window
worst_avg = Rivulet.sum(matches).windows(10).min_by { |w| w.average }
puts "Worst 10-game stretch: #{(worst_avg * 100).round(0)}% win rate"
