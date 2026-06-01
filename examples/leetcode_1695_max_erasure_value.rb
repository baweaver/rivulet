# frozen_string_literal: true

# LeetCode 1695: Maximum Erasure Value
# https://leetcode.com/problems/maximum-erasure-value/
#
# Find the maximum sum of a subarray with all unique elements.

require "bundler/setup"
require "rivulet"

def maximum_unique_subarray(nums)
  Rivulet.count(nums)
    .max_window { |w| !w.repeats? }
    .max_by { |w| w.sum }  || 0
end

puts "LC1695: Maximum Erasure Value"
puts "  [4,2,4,5,6]         => #{maximum_unique_subarray([4, 2, 4, 5, 6])}"              # 17
puts "  [5,2,1,2,5,2,1,2,5] => #{maximum_unique_subarray([5, 2, 1, 2, 5, 2, 1, 2, 5])}" # 8
