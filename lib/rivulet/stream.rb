# frozen_string_literal: true

module Rivulet
  class Stream
    def initialize(source)
      @source = source
    end

    def windows(size, step: 1, &block)
      raise ArgumentError, "size must be positive" unless size.positive?
      raise ArgumentError, "step must be positive" unless step.positive?

      builder = WindowBuilder.new(stream: self, mode: :fixed, size: size, step: step)
      block ? builder.each_window(&block) : builder
    end

    def tumbling(size, &block)
      windows(size, step: size, &block)
    end

    def max_window(&rule)
      WindowBuilder.new(stream: self, mode: :variable, rule: rule)
    end

    def min_window(&goal)
      WindowBuilder.new(stream: self, mode: :satisfied, rule: goal)
    end

    # @api private — used by WindowBuilder
    def iterate_windows(mode:, size: nil, rule: nil, step: 1, &block)
      case mode
      when :fixed     then iterate_fixed(size: size, step: step, &block)
      when :variable  then iterate_variable(rule: rule, &block)
      when :satisfied then iterate_satisfied(rule: rule, &block)
      # :nocov:
      else raise ArgumentError, "unknown mode: #{mode}"
      # :nocov:
      end
    end

    private

    def iterate_fixed(size:, step:)
      window = new_window
      emit_count = 0
      @source.each do |item|
        window.add(item)
        window.evict while window.size > size

        if window.size == size
          yield window if (emit_count % step).zero?
          emit_count += 1
        end
      end
    end

    def iterate_variable(rule:)
      window = new_window
      @source.each do |item|
        window.add(item)
        window.evict until window.empty? || rule.call(window)

        yield window unless window.empty?
      end
    end

    def iterate_satisfied(rule:)
      window = new_window
      @source.each do |item|
        window.add(item)

        until window.empty? || !rule.call(window)
          yield window
          window.evict
        end
      end
    end

    def each_max_window(rule)
      iterate_windows(mode: :variable, rule: rule) { |w| yield w }
    end

    def new_window = Window.new
  end
end
