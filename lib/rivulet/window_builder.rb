# frozen_string_literal: true

module Rivulet
  class WindowBuilder
    def initialize(stream:, mode:, size: nil, rule: nil, step: 1)
      @stream = stream
      @mode = mode
      @size = size
      @rule = rule
      @step = step
    end

    def each_window(&block)
      results = []
      iterate do |window|
        value = block.call(window)
        results << value if value
      end
      results
    end

    def max_by(k = nil, &block)
      if k
        top = []
        iterate do |window|
          score = block.call(window)
          top << score
          top.sort!.shift if top.size > k
        end
        top.sort.reverse
      else
        best = nil
        iterate do |window|
          score = block.call(window)
          best = score if best.nil? || score > best
        end
        best
      end
    end

    def min_by(k = nil, &block)
      if k
        top = []
        iterate do |window|
          score = block.call(window)
          top << score
          top.sort!.pop if top.size > k
        end
        top.sort
      else
        best = nil
        iterate do |window|
          score = block.call(window)
          best = score if best.nil? || score < best
        end
        best
      end
    end

    def first(k = nil, &block)
      if k
        results = []
        iterate do |window|
          value = block ? block.call(window) : window
          results << value if value
          break if results.size == k
        end
        results
      else
        result = nil
        iterate do |window|
          result = block ? block.call(window) : window
          break if result
        end
        result
      end
    end

    def take(k, &block) = first(k, &block)

    def count
      n = 0
      iterate { |_| n += 1 }
      n
    end

    private

    def iterate(&block)
      @stream.iterate_windows(mode: @mode, size: @size, rule: @rule, step: @step, &block)
    end
  end
end
