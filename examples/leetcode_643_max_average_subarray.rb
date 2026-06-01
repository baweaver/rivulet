# frozen_string_literal: true

# LeetCode 643: Maximum Average Subarray I
# https://leetcode.com/problems/maximum-average-subarray-i/
#
# Find the contiguous subarray of length k with the maximum average.

require "bundler/setup"
require "rivulet"

def find_max_average(nums, k)
  Rivulet.sum(nums).windows(k).max_by { |w| w.average }
end

puts "LC643: Maximum Average Subarray I"
puts "  [1,12,-5,-6,50,3], k=4 => #{find_max_average([1, 12, -5, -6, 50, 3], 4)}"  # 12.75
puts "  [5], k=1               => #{find_max_average([5], 1)}"                       # 5.0
