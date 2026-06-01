# frozen_string_literal: true

module Rivulet
  class MinMaxStream < Stream
    def max_range_while(&rule)
      best = 0
      each_max_window(rule) { |w| best = w.range if w.range && w.range > best }
      best
    end

    private

    def new_window = MinMaxWindow.new
  end
end
