# frozen_string_literal: true

# LeetCode 239: Sliding Window Maximum
# https://leetcode.com/problems/sliding-window-maximum/
#
# Given an array and window size k, return the max of each window.

require "bundler/setup"
require "rivulet"

def max_sliding_window(nums, k)
  Rivulet.minmax(nums).windows(k) { |w| w.max }
end

puts "LC239: Sliding Window Maximum"
puts "  [1,3,-1,-3,5,3,6,7], k=3 => #{max_sliding_window([1, 3, -1, -3, 5, 3, 6, 7], 3).inspect}"
# => [3, 3, 5, 5, 6, 7]
puts "  [1], k=1 => #{max_sliding_window([1], 1).inspect}"
# => [1]
