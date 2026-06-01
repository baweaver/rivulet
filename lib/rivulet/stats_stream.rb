# frozen_string_literal: true

module Rivulet
  class StatsStream < Stream
    private

    def new_window = StatsWindow.new
  end
end
