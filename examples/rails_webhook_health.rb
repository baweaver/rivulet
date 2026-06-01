# frozen_string_literal: true

# Example: Webhook Delivery Health
# Monitor webhook delivery attempts and detect endpoints that are failing
# consistently — trigger circuit breaker when failure rate exceeds threshold
# over a rolling window.

require "bundler/setup"
require "rivulet"

# Simulate delivery results for one endpoint: 1 = success, 0 = failure
# Healthy, then degraded, then recovering
rng = Random.new(42)
deliveries = [
  *30.times.map { rng.rand < 0.95 ? 1 : 0 },   # healthy: 95% success
  *20.times.map { rng.rand < 0.3 ? 1 : 0 },    # degraded: 30% success
  *15.times.map { rng.rand < 0.6 ? 1 : 0 },    # recovering: 60% success
  *35.times.map { rng.rand < 0.98 ? 1 : 0 },   # healthy again
]

window_size = 10
failure_threshold = 0.5  # trip circuit breaker at 50% failure rate

puts "=== Webhook Delivery Health ==="
puts "Deliveries: #{deliveries.size}"
puts "Window: #{window_size}, circuit breaker at #{(failure_threshold * 100).to_i}% failure"
puts

# Rolling success rate
rates = Rivulet.sum(deliveries).windows(window_size) { |w| w.average }

puts "Success rate over time (sampled every 10):"
rates.each_slice(10).with_index do |chunk, i|
  puts "  #{i * 10}-#{i * 10 + chunk.size - 1}: #{chunk.map { |r| r >= failure_threshold ? '✓' : '✗' }.join}"
end
puts

# Find windows where circuit breaker would trip
tripped_windows = Rivulet.sum(deliveries)
  .windows(window_size)
  .each_window { |w| w if w.average < failure_threshold }

puts "Circuit breaker tripped: #{tripped_windows.size} times"
puts

# Longest consecutive healthy streak
healthy_streak = Rivulet.sum(deliveries)
  .max_window { |w| w.average >= failure_threshold }
  .max_by { |w| w.size }

puts "Longest healthy streak: #{healthy_streak || 0} deliveries"

# Worst window
worst = Rivulet.sum(deliveries).windows(window_size).min_by { |w| w.average }
puts "Worst window: #{(worst * 100).round(1)}% success rate"
