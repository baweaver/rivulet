# frozen_string_literal: true

# LeetCode 1456: Maximum Number of Vowels in a Substring of Given Length
# https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/
#
# Given a string s and integer k, return the max number of vowels
# in any substring of length k.

require "bundler/setup"
require "rivulet"

VOWELS = Set.new(%w[a e i o u])

def max_vowels(s, k)
  Rivulet.sum(s.chars) { |c| VOWELS.include?(c) ? 1 : 0 }
    .windows(k)
    .max_by { |w| w.sum }
end

puts "LC1456: Maximum Number of Vowels in a Substring"
puts "  'abciiidef', k=3 => #{max_vowels('abciiidef', 3)}"  # 3
puts "  'aeiou', k=2     => #{max_vowels('aeiou', 2)}"      # 2
puts "  'leetcode', k=3  => #{max_vowels('leetcode', 3)}"   # 2
