# frozen_string_literal: true

module Rivulet
  class CountWindow < Window
    def initialize
      super
      @counts = Hash.new(0)
      @items = []
      @front = 0
    end

    def add(item)
      @counts[item] += 1
      @items.push(item)
      super
    end

    def evict
      if @front < @items.size
        item = @items[@front]
        @counts[item] -= 1
        @counts.delete(item) if @counts[item].zero?
        @front += 1
        super
        item
      else
        super
        nil
      end
    end

    def repeats? = @counts.any? { |_, n| n > 1 }
    def distinct = @counts.size
    def max_count = @counts.values.max || 0
    def counts = @counts

    def covers?(target_counts)
      target_counts.all? { |k, v| @counts[k] >= v }
    end
  end
end
