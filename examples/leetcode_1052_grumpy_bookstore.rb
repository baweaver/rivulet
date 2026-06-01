# frozen_string_literal: true

# LeetCode 1052: Grumpy Bookstore Owner
# https://leetcode.com/problems/grumpy-bookstore-owner/
#
# A bookstore owner has customers[i] arriving each minute.
# grumpy[i] = 1 means the owner is grumpy that minute (customers unsatisfied).
# The owner can suppress grumpiness for `minutes` consecutive minutes.
# Find the maximum number of satisfied customers.

require "bundler/setup"
require "rivulet"

def max_satisfied(customers, grumpy, minutes)
  # Base satisfaction: customers when owner is NOT grumpy
  base = customers.zip(grumpy).sum { |c, g| g == 0 ? c : 0 }

  # Extra satisfaction from suppressing grumpiness for `minutes` window:
  # only grumpy-minute customers are "rescued"
  rescued = customers.zip(grumpy).map { |c, g| g == 1 ? c : 0 }

  best_rescue = Rivulet.sum(rescued).windows(minutes).max_by { |w| w.sum } || 0

  base + best_rescue
end

puts "LC1052: Grumpy Bookstore Owner"
customers = [1, 0, 1, 2, 1, 1, 7, 5]
grumpy =    [0, 1, 0, 1, 0, 1, 0, 1]
puts "  customers=#{customers.inspect}"
puts "  grumpy=#{grumpy.inspect}, minutes=3"
puts "  => #{max_satisfied(customers, grumpy, 3)}"  # 16
