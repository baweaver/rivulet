# frozen_string_literal: true

# LeetCode 567: Permutation in String
# https://leetcode.com/problems/permutation-in-string/
#
# Given strings s1 and s2, return true if s2 contains a permutation of s1.
# (Any window of size s1.length with the same character frequencies.)

require "bundler/setup"
require "rivulet"

def check_inclusion(s1, s2)
  target = Hash.new(0)
  s1.each_char { |c| target[c] += 1 }

  Rivulet.count(s2.chars).windows(s1.length) { |w| w.covers?(target) ? true : nil }.any?
end

puts "LC567: Permutation in String"
puts "  s1='ab', s2='eidbaooo'  => #{check_inclusion('ab', 'eidbaooo')}"   # true
puts "  s1='ab', s2='eidboaoo'  => #{check_inclusion('ab', 'eidboaoo')}"   # false
