# frozen_string_literal: true

# LeetCode 2461: Maximum Sum of Distinct Subarrays With Length K
# https://leetcode.com/problems/maximum-sum-of-distinct-subarrays-with-length-k/
#
# Find the maximum sum among all subarrays of length k that contain
# only distinct elements.

require "bundler/setup"
require "rivulet"

def maximum_subarray_sum(nums, k)
  Rivulet.count(nums).windows(k) { |w| w.repeats? ? nil : w.sum } .max || 0
end

puts "LC2461: Maximum Sum of Distinct Subarrays With Length K"
puts "  [1,5,4,2,9,9,9], k=3 => #{maximum_subarray_sum([1, 5, 4, 2, 9, 9, 9], 3)}"  # 15
puts "  [4,4,4], k=3          => #{maximum_subarray_sum([4, 4, 4], 3)}"                # 0
