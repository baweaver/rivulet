# frozen_string_literal: true

# Example: Session Activity Windows
# Group user page views into sessions based on inactivity gaps.
# A session ends when there's a gap of more than 30 minutes between events.

require "bundler/setup"
require "rivulet"

# Simulate page view timestamps for one user over a day
base = Time.new(2024, 3, 15, 8, 0, 0)
page_views = [
  *10.times.map { |i| base + i * 60 },          # 8:00-8:09, active
  *5.times.map { |i| base + 600 + i * 120 },    # 8:10-8:18, slower
  # 45 min gap (session break)
  *8.times.map { |i| base + 4500 + i * 90 },    # 9:15-9:25, new session
  # 2 hour gap
  *12.times.map { |i| base + 12000 + i * 45 },  # 11:20-11:29, another session
]

gap_threshold = 30 * 60 # 30 minutes in seconds

puts "=== Session Activity Windows ==="
puts "Page views: #{page_views.size}"
puts "Gap threshold: #{gap_threshold / 60} minutes"
puts

# Split page views into sessions using plain Ruby based on time gaps
sessions = page_views.chunk_while { |a, b| b - a <= gap_threshold }.to_a

puts "Sessions detected: #{sessions.size}"
sessions.each_with_index do |session, i|
  duration = session.size < 2 ? 0 : (session.last - session.first) / 60.0
  puts "  Session #{i + 1}: #{session.size} views, #{duration.round(1)} min"
end
