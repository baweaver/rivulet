# frozen_string_literal: true

# LeetCode 424: Longest Repeating Character Replacement
# https://leetcode.com/problems/longest-repeating-character-replacement/
#
# Given a string s and integer k, find the longest substring where you can
# replace at most k characters to make all characters the same.
#
# Window is valid when: size - max_frequency <= k

require "bundler/setup"
require "rivulet"

def character_replacement(s, k)
  Rivulet.count(s.chars)
    .max_window { |w| w.size - w.max_count <= k }
    .max_by { |w| w.size } || 0
end

puts "LC424: Longest Repeating Character Replacement"
puts "  'ABAB', k=2    => #{character_replacement('ABAB', 2)}"    # 4
puts "  'AABABBA', k=1 => #{character_replacement('AABABBA', 1)}" # 4
