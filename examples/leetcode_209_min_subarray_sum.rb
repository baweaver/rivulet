# frozen_string_literal: true

# LeetCode 209: Minimum Size Subarray Sum
# https://leetcode.com/problems/minimum-size-subarray-sum/
#
# Given an array of positive integers and a target, find the minimal length
# subarray whose sum is >= target. Return 0 if none exists.

require "bundler/setup"
require "rivulet"

def min_subarray_len(target, nums)
  Rivulet.sum(nums).min_size_where { |w| w.sum >= target }
end

# Examples from LeetCode
puts "LC209: Minimum Size Subarray Sum"
puts "  target=7, [2,3,1,2,4,3] => #{min_subarray_len(7, [2, 3, 1, 2, 4, 3])}"  # 2
puts "  target=4, [1,4,4]       => #{min_subarray_len(4, [1, 4, 4])}"             # 1
puts "  target=11, [1,1,1,1]    => #{min_subarray_len(11, [1, 1, 1, 1])}"         # 0
