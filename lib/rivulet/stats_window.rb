# frozen_string_literal: true

module Rivulet
  class StatsWindow < MinMaxWindow
    def initialize
      super
      @sum = 0
      @counts = Hash.new(0)
    end

    def add(item)
      @sum += item
      @counts[item] += 1
      super
    end

    def evict
      if @front < @items.size
        item = @items[@front]
        @sum -= item
        @counts[item] -= 1
        @counts.delete(item) if @counts[item].zero?
      end
      super
    end

    def sum = @sum
    def average = empty? ? nil : @sum.fdiv(size)

    def distinct = @counts.size
    def repeats? = @counts.any? { |_, n| n > 1 }
    def max_count = @counts.values.max || 0
    def counts = @counts
    def covers?(target_counts)
      target_counts.all? { |k, v| @counts[k] >= v }
    end
  end
end
