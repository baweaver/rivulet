# frozen_string_literal: true

module Rivulet
  class SumStream < Stream
    def initialize(source, mapper: nil)
      super(mapper ? source.lazy.map(&mapper) : source)
    end

    def max_size_while(&rule)
      best = 0
      each_max_window(rule) { |w| best = w.size if w.size > best }
      best
    end

    def max_sum_while(&rule)
      best = 0
      each_max_window(rule) { |w| best = w.sum if w.sum > best }
      best
    end

    def min_size_where(&goal)
      best = nil
      iterate_windows(mode: :satisfied, rule: goal) do |w|
        best = w.size if best.nil? || w.size < best
      end
      best
    end

    private

    def new_window = SumWindow.new
  end
end
