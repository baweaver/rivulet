# frozen_string_literal: true

module Rivulet
  # A double-ended queue with O(1) push/pop at both ends.
  # Backed by a growing array with a front index; no element is ever shifted.
  class Deque
    def initialize
      @data  = []
      @front = 0
    end

    def push(val) = @data.push(val)

    def pop
      @data.pop unless empty?
    end

    def shift
      @front += 1 unless empty?
    end

    def first     = @data[@front]
    def last      = @data.last
    def any?      = @front < @data.size
    def empty?    = @front >= @data.size
  end
end
