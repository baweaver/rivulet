# frozen_string_literal: true

# LeetCode 1004: Max Consecutive Ones III
# https://leetcode.com/problems/max-consecutive-ones-iii/
#
# Given a binary array and k, return the longest subarray of 1s
# if you can flip at most k zeros.

require "bundler/setup"
require "rivulet"

def longest_ones(nums, k)
  Rivulet.sum(nums) { |n| n == 0 ? 1 : 0 }
    .max_size_while { |w| w.sum <= k }
end

puts "LC1004: Max Consecutive Ones III"
puts "  [1,1,1,0,0,0,1,1,1,1,0], k=2 => #{longest_ones([1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0], 2)}"  # 6
puts "  [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], k=3 => #{longest_ones([0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1], 3)}"  # 10
