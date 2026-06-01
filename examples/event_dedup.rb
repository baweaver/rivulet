# frozen_string_literal: true

# Example: Event Stream Deduplication
# Find the longest run of unique events in a noisy stream.

require "bundler/setup"
require "rivulet"

# Simulate a noisy event stream with some repeated IDs
rng = Random.new(123)
event_ids = 200.times.map { rng.rand(1..50) }

puts "=== Event Stream Deduplication ==="
puts "Events: #{event_ids.size}"
puts "Unique IDs in stream: #{event_ids.uniq.size}"
puts

# Longest run with no repeated event ID
longest_size = Rivulet.count(event_ids)
  .max_window { |w| !w.repeats? }
  .max_by { |w| w.size }

puts "Longest non-repeating run: #{longest_size} events"
puts

# Use reducer shortcut to just get the length
longest_length = Rivulet.count(event_ids)
  .max_distinct_while { |w| !w.repeats? }

puts "Longest run length (via reducer): #{longest_length}"
puts

# Count runs of at least 5 unique events
good_runs = Rivulet.count(event_ids)
  .max_window { |w| !w.repeats? }
  .each_window { |w| w.size if w.size >= 5 }

puts "Runs with >= 5 unique events: #{good_runs.size}"
good_runs.first(3).each_with_index do |size, i|
  puts "  Run #{i + 1}: #{size} events"
end
