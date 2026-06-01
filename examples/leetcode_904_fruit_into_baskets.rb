# frozen_string_literal: true

# LeetCode 904: Fruit Into Baskets
# https://leetcode.com/problems/fruit-into-baskets/
#
# You have two baskets. Find the longest contiguous subarray
# containing at most 2 distinct types of fruit.

require "bundler/setup"
require "rivulet"

def total_fruit(fruits)
  Rivulet.count(fruits)
    .max_window { |w| w.distinct <= 2 }
    .max_by { |w| w.size } || 0
end

puts "LC904: Fruit Into Baskets"
puts "  [1,2,1]     => #{total_fruit([1, 2, 1])}"       # 3
puts "  [0,1,2,2]   => #{total_fruit([0, 1, 2, 2])}"    # 3
puts "  [1,2,3,2,2] => #{total_fruit([1, 2, 3, 2, 2])}" # 4
