# frozen_string_literal: true

require_relative "rivulet/version"
require_relative "rivulet/deque"
require_relative "rivulet/window"
require_relative "rivulet/window_builder"
require_relative "rivulet/stream"
require_relative "rivulet/sum_window"
require_relative "rivulet/sum_stream"
require_relative "rivulet/count_window"
require_relative "rivulet/count_stream"
require_relative "rivulet/minmax_window"
require_relative "rivulet/minmax_stream"
require_relative "rivulet/stats_window"
require_relative "rivulet/stats_stream"

module Rivulet
  def self.sum(source, &mapper) = SumStream.new(source, mapper: mapper || nil)
  def self.count(source) = CountStream.new(source)
  def self.minmax(source) = MinMaxStream.new(source)
  def self.stats(source) = StatsStream.new(source)
end
