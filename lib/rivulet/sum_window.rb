# frozen_string_literal: true

module Rivulet
  class SumWindow < Window
    def initialize
      super
      @sum = 0
      @items = []
      @front = 0
    end

    def add(value)
      @sum += value
      @items.push(value)
      super
    end

    def evict
      if @front < @items.size
        @sum -= @items[@front]
        @front += 1
      end
      super
    end

    def sum = @sum

    def average
      @sum.fdiv(size) unless empty?
    end
  end
end
