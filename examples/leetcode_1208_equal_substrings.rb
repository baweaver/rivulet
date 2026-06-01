# frozen_string_literal: true

# LeetCode 1208: Get Equal Substrings Within Budget
# https://leetcode.com/problems/get-equal-substrings-within-budget/
#
# Given strings s and t of equal length, and a max cost, find the longest
# substring of s that can be changed to t with cost <= maxCost.
# Cost of changing s[i] to t[i] is |s[i] - t[i]|.

require "bundler/setup"
require "rivulet"

def equal_substring(s, t, max_cost)
  costs = s.chars.zip(t.chars).map { |a, b| (a.ord - b.ord).abs }

  Rivulet.sum(costs).max_size_while { |w| w.sum <= max_cost }
end

puts "LC1208: Get Equal Substrings Within Budget"
puts "  s='abcd', t='bcdf', maxCost=3 => #{equal_substring('abcd', 'bcdf', 3)}"    # 3
puts "  s='abcd', t='cdef', maxCost=3 => #{equal_substring('abcd', 'cdef', 3)}"    # 1
puts "  s='abcd', t='acde', maxCost=0 => #{equal_substring('abcd', 'acde', 0)}"    # 1
