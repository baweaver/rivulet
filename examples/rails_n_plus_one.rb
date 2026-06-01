# frozen_string_literal: true

# Example: N+1 Query Detection
# Scan a request log for bursts of identical queries — a sign of N+1 problems.
# Flag any window where the same query appears more than N times.

require "bundler/setup"
require "rivulet"

# Simulate a request's SQL query log
queries = [
  "SELECT * FROM users WHERE id = 1",
  "SELECT * FROM posts WHERE user_id = 1",
  *20.times.map { |i| "SELECT * FROM comments WHERE post_id = #{i}" },  # N+1!
  "SELECT COUNT(*) FROM comments",
  "SELECT * FROM users WHERE id = 2",
  *15.times.map { |i| "SELECT * FROM tags WHERE post_id = #{i}" },      # another N+1
  "UPDATE users SET last_seen = NOW() WHERE id = 1",
]

# Normalize queries: strip literal values to group identical patterns
def normalize(sql)
  sql.gsub(/= \d+/, "= ?").gsub(/\d+/, "?")
end

normalized = queries.map { |q| normalize(q) }
repeat_threshold = 5

puts "=== N+1 Query Detection ==="
puts "Queries in request: #{queries.size}"
puts "Threshold: #{repeat_threshold} identical patterns in a window"
puts

# Find the worst burst: largest window (up to 25) with repeated patterns
# Use count window to detect repeats via max_count
worst_burst_size = Rivulet.count(normalized)
  .max_window { |w| w.size <= 25 }
  .max_by { |w| w.max_count >= repeat_threshold ? w.size : nil }

puts "Worst burst size: #{worst_burst_size || 'none'}"
puts

# Quick check: does any 10-query window have a dominant pattern?
has_n_plus_1 = Rivulet.count(normalized)
  .windows(10)
  .first { |w| w.max_count >= repeat_threshold ? true : nil }

puts "N+1 detected in any 10-query window? #{has_n_plus_1 ? 'YES' : 'No'}"
