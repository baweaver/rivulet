# frozen_string_literal: true

module Rivulet
  class CountStream < Stream
    def max_distinct_while(&rule)
      best = 0
      each_max_window(rule) { |w| best = w.distinct if w.distinct > best }
      best
    end

    private

    def new_window = CountWindow.new
  end
end
