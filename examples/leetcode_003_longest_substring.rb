# frozen_string_literal: true

# LeetCode 3: Longest Substring Without Repeating Characters
# https://leetcode.com/problems/longest-substring-without-repeating-characters/
#
# Given a string s, find the length of the longest substring
# without repeating characters.

require "bundler/setup"
require "rivulet"

def length_of_longest_substring(s)
  Rivulet.count(s.chars)
    .max_window { |w| !w.repeats? }
    .max_by { |w| w.size } || 0
end

# Examples from LeetCode
puts "LC3: Longest Substring Without Repeating Characters"
puts "  'abcabcbb' => #{length_of_longest_substring('abcabcbb')}"  # 3
puts "  'bbbbb'    => #{length_of_longest_substring('bbbbb')}"     # 1
puts "  'pwwkew'   => #{length_of_longest_substring('pwwkew')}"    # 3
puts "  ''         => #{length_of_longest_substring('')}"           # 0
