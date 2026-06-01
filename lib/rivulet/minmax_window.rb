# frozen_string_literal: true

module Rivulet
  class MinMaxWindow < Window
    def initialize
      super
      @items = []
      @min_deque = Deque.new
      @max_deque = Deque.new
      @front = 0
    end

    def add(item)
      idx = @items.size
      @min_deque.pop while @min_deque.any? && @items[@min_deque.last] >= item
      @max_deque.pop while @max_deque.any? && @items[@max_deque.last] <= item
      @min_deque.push(idx)
      @max_deque.push(idx)
      @items.push(item)
      super
    end

    def evict
      return super if @front >= @items.size

      @min_deque.shift if @min_deque.first == @front
      @max_deque.shift if @max_deque.first == @front
      @front += 1
      super
    end

    def min
      @items[@min_deque.first] unless empty?
    end

    def max
      @items[@max_deque.first] unless empty?
    end

    def range
      max - min unless empty?
    end
  end
end
