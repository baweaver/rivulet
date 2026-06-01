# frozen_string_literal: true

# Example: Budget Burn Rate
# Track daily spending and find your worst 7-day stretch.

require "bundler/setup"
require "rivulet"

# Simulate 30 days of spending
rng = Random.new(33)
daily_spending = 30.times.map do |day|
  base = day.between?(10, 16) ? 80 : 35  # splurge week
  (base + rng.rand(-15.0..25.0)).round(2)
end

monthly_budget = 1200.0
weekly_budget = monthly_budget / 4.0

puts "=== Budget Burn Rate ==="
puts "Monthly budget: $#{monthly_budget}"
puts "Weekly budget: $#{weekly_budget.round(2)}"
puts

# Worst 7-day spending window
worst_week_sum = Rivulet.sum(daily_spending).windows(7).max_by { |w| w.sum }
puts "Worst 7-day stretch: $#{worst_week_sum.round(2)} (budget: $#{weekly_budget.round(2)})"
puts

# How many consecutive days can you sustain before hitting budget?
days_under = Rivulet.sum(daily_spending)
  .max_size_while { |w| w.sum <= monthly_budget }

puts "Days before hitting monthly budget: #{days_under}"
