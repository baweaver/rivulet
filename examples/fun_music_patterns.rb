# frozen_string_literal: true

# Example: Music Listening Patterns
# Find your longest unique-artist streak and detect listening loops.

require "bundler/setup"
require "rivulet"

# Simulate a listening history
artists = %w[
  Radiohead Bjork Portishead Massive_Attack Tricky
  Radiohead Radiohead Radiohead
  Boards_of_Canada Aphex_Twin Autechre Squarepusher Plaid Broadcast
  Aphex_Twin Aphex_Twin Aphex_Twin Aphex_Twin
  Stereolab Tortoise Yo_La_Tengo Pavement Guided_by_Voices Sebadoh
  Built_to_Spill Archers_of_Loaf Superchunk
]

puts "=== Music Listening Patterns ==="
puts "Tracks played: #{artists.size}"
puts "Unique artists: #{artists.uniq.size}"
puts

# Longest streak of unique artists (no repeats)
longest_unique = Rivulet.count(artists)
  .max_distinct_while { |w| !w.repeats? }

puts "Longest unique-artist streak: #{longest_unique} tracks"
puts

# Detect loops: windows where one artist dominates (>= 3/5 plays)
loops = Rivulet.count(artists)
  .windows(5)
  .each_window { |w| w.max_count if w.max_count >= 3 }

puts "Listening loops (1 artist >= 3/5 plays): #{loops.size}"
