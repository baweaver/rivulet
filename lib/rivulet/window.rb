# frozen_string_literal: true

module Rivulet
  class Window
    def initialize
      @size = 0
    end

    def size = @size
    def empty? = @size.zero?

    def add(item)
      @size += 1
      self
    end

    def evict
      @size -= 1 if @size > 0
    end
  end
end
