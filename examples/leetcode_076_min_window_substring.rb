# frozen_string_literal: true

# LeetCode 76: Minimum Window Substring
# https://leetcode.com/problems/minimum-window-substring/
#
# Given strings s and t, find the smallest window in s that contains
# all characters of t (including duplicates).

require "bundler/setup"
require "rivulet"

def min_window(s, t)
  return "" if t.empty?

  target = Hash.new(0)
  t.each_char { |c| target[c] += 1 }

  best_size = Rivulet.count(s.chars)
    .min_window { |w| w.covers?(target) }
    .min_by { |w| w.size }

  return "" unless best_size

  # Now find the actual window of that size using a second pass
  # (Rivulet gives us the answer; locating it is a simple scan)
  counts = Hash.new(0)
  front = 0
  s.each_char.with_index do |c, i|
    counts[c] += 1
    while target.all? { |k, v| counts[k] >= v }
      return s[front, best_size] if i - front + 1 == best_size
      counts[s[front]] -= 1
      front += 1
    end
  end
  ""
end

puts "LC76: Minimum Window Substring"
puts "  s='ADOBECODEBANC', t='ABC' => '#{min_window('ADOBECODEBANC', 'ABC')}'"  # "BANC"
puts "  s='a', t='a'               => '#{min_window('a', 'a')}'"                 # "a"
puts "  s='a', t='aa'              => '#{min_window('a', 'aa')}'"                # ""
