# frozen_string_literal: true

RSpec.describe Rivulet do
  it "has a version number" do
    expect(Rivulet::VERSION).not_to be_nil
  end

  describe ".sum" do
    describe "#windows" do
      it "produces fixed-size sliding window averages" do
        expect(Rivulet.sum([10, 20, 30, 40, 50]).windows(3) { |w| w.average }).to eq([20.0, 30.0, 40.0])
      end

      it "raises on non-positive size" do
        expect { Rivulet.sum([1]).windows(0) }.to raise_error(ArgumentError)
      end

      it "raises on non-positive step" do
        expect { Rivulet.sum([1]).windows(2, step: 0) }.to raise_error(ArgumentError)
      end

      it "returns a builder without a block" do
        expect(Rivulet.sum([1, 2, 3]).windows(2)).to be_a(Rivulet::WindowBuilder)
      end

      it "builder.each_window yields live window" do
        results = Rivulet.sum([10, 20, 30]).windows(2).each_window { |w| [w.sum, w.average] }
        expect(results).to eq([[30, 15.0], [50, 25.0]])
      end

      it "step skips intermediate windows" do
        results = Rivulet.sum([1, 2, 3, 4, 5]).windows(3, step: 2) { |w| w.sum }
        expect(results).to eq([6, 12])
      end
    end

    describe "#tumbling" do
      it "emits non-overlapping windows" do
        results = Rivulet.sum([1, 2, 3, 4, 5, 6]).tumbling(3) { |w| w.sum }
        expect(results).to eq([6, 15])
      end

      it "returns a builder without a block" do
        expect(Rivulet.sum([1, 2, 3]).tumbling(2)).to be_a(Rivulet::WindowBuilder)
      end
    end

    describe "#max_window" do
      it "yields windows satisfying the rule" do
        sums = Rivulet.sum([5, 3, 8, 2, 7]).max_window { |w| w.sum <= 10 }.each_window { |w| w.sum }
        sums.each { |s| expect(s).to be <= 10 }
      end

      it "returns empty when rule always fails" do
        result = Rivulet.sum([100, 200]).max_window { |w| w.sum <= 50 }.each_window { |w| w.sum }
        expect(result).to be_empty
      end

      it "max_by returns the best value" do
        result = Rivulet.sum([5, 3, 8, 2, 7]).max_window { |w| w.sum <= 10 }.max_by { |w| w.size }
        expect(result).to be >= 2
      end
    end

    describe "#min_window" do
      it "yields windows where goal is met, shrinking each time" do
        sizes = Rivulet.sum([2, 3, 1, 2, 4, 3]).min_window { |w| w.sum >= 7 }.each_window { |w| w.size }
        expect(sizes).to include(2)
      end

      it "min_by finds smallest satisfying window" do
        result = Rivulet.sum([2, 3, 1, 2, 4, 3]).min_window { |w| w.sum >= 7 }.min_by { |w| w.size }
        expect(result).to eq(2)
      end

      it "returns empty when goal never met" do
        result = Rivulet.sum([1, 1]).min_window { |w| w.sum >= 100 }.each_window { |w| w.size }
        expect(result).to be_empty
      end
    end

    describe "#max_size_while" do
      it "returns the largest window size under the constraint" do
        result = Rivulet.sum([5, 3, 8, 2, 7, 4, 6, 1, 9, 3]).max_size_while { |w| w.sum <= 10 }
        expect(result).to be >= 2
      end

      it "returns zero when rule always fails" do
        expect(Rivulet.sum([100]).max_size_while { |w| w.sum <= 0 }).to eq(0)
      end
    end

    describe "#max_sum_while" do
      it "returns the max sum under the constraint" do
        result = Rivulet.sum([5, 3, 8, 2, 7]).max_sum_while { |w| w.sum <= 10 }
        expect(result).to be <= 10
        expect(result).to be >= 8
      end
    end

    describe "#min_size_where" do
      it "returns the smallest window meeting the goal" do
        expect(Rivulet.sum([2, 3, 1, 2, 4, 3]).min_size_where { |w| w.sum >= 7 }).to eq(2)
      end

      it "returns nil when goal is never met" do
        expect(Rivulet.sum([1, 1, 1]).min_size_where { |w| w.sum >= 100 }).to be_nil
      end
    end

    describe "with mapper (replaces Rivulet.measure)" do
      it "sums a derived value" do
        result = Rivulet.sum(["hi", "hello", "world"], &:bytesize).max_size_while { |w| w.sum <= 10 }
        expect(result).to be >= 2
      end

      it "windows with mapper" do
        avgs = Rivulet.sum([1, 2, 3, 4]) { |x| x * 10 }.windows(2) { |w| w.average }
        expect(avgs).to eq([15.0, 25.0, 35.0])
      end
    end

    describe Rivulet::SumWindow do
      it "returns nil average when empty" do
        expect(Rivulet::SumWindow.new.average).to be_nil
      end

      it "tracks sum and average" do
        w = Rivulet::SumWindow.new
        w.add(10)
        w.add(20)
        expect(w.sum).to eq(30)
        expect(w.average).to eq(15.0)
      end

      it "evicts correctly from the front" do
        w = Rivulet::SumWindow.new
        w.add(10)
        w.add(20)
        w.evict
        expect(w.sum).to eq(20)
        expect(w.size).to eq(1)
      end

      it "evict on empty is safe" do
        w = Rivulet::SumWindow.new
        expect { w.evict }.not_to raise_error
        expect(w.sum).to eq(0)
      end
    end
  end

  describe ".count" do
    describe "#max_window" do
      it "finds non-repeating windows" do
        longest = Rivulet.count([:a, :b, :c, :a, :d, :b, :e]).max_window { |w| !w.repeats? }.max_by { |w| w.size }
        expect(longest).to be >= 3
      end

      it "handles all-repeating input" do
        sizes = Rivulet.count([:a, :a, :a]).max_window { |w| !w.repeats? }.each_window { |w| w.size }
        expect(sizes).to all(eq(1))
      end

      it "returns empty when rule always fails" do
        result = Rivulet.count([:a, :a]).max_window { |w| w.distinct > 5 }.each_window { |w| w.size }
        expect(result).to be_empty
      end
    end

    describe "#min_window" do
      it "works with count windows" do
        result = Rivulet.count([:a, :b, :c, :a, :b]).min_window { |w| w.distinct >= 3 }.each_window { |w| w.distinct }
        result.each { |d| expect(d).to be >= 3 }
      end
    end

    describe "#max_distinct_while" do
      it "returns the max distinct count" do
        expect(Rivulet.count([:a, :b, :c, :a, :d]).max_distinct_while { |w| !w.repeats? }).to eq(4)
      end
    end

    describe Rivulet::CountWindow do
      it "tracks frequencies" do
        w = Rivulet::CountWindow.new
        w.add(:a)
        w.add(:b)
        w.add(:a)
        expect(w.distinct).to eq(2)
        expect(w.repeats?).to be true
        expect(w.max_count).to eq(2)
      end

      it "evicts correctly" do
        w = Rivulet::CountWindow.new
        w.add(:a)
        w.add(:a)
        w.evict
        expect(w.repeats?).to be false
        expect(w.distinct).to eq(1)
      end

      it "deletes count at zero" do
        w = Rivulet::CountWindow.new
        w.add(:a)
        w.evict
        expect(w.distinct).to eq(0)
      end

      it "evict from empty returns nil" do
        w = Rivulet::CountWindow.new
        expect(w.evict).to be_nil
      end

      it "covers? checks target frequencies" do
        w = Rivulet::CountWindow.new
        w.add(:a)
        w.add(:b)
        w.add(:a)
        expect(w.covers?({ a: 2, b: 1 })).to be true
        expect(w.covers?({ a: 3 })).to be false
      end

      it "exposes counts" do
        w = Rivulet::CountWindow.new
        w.add(:x)
        expect(w.counts).to eq({ x: 1 })
      end
    end
  end

  describe ".minmax" do
    describe "#windows" do
      it "tracks rolling min and max" do
        results = Rivulet.minmax([3, 1, 4, 1, 5, 9]).windows(3) { |w| [w.min, w.max, w.range] }
        expect(results[0]).to eq([1, 4, 3])
      end

      it "raises on non-positive size" do
        expect { Rivulet.minmax([1]).windows(0) }.to raise_error(ArgumentError)
      end
    end

    describe "#max_window" do
      it "constrains by range" do
        ranges = Rivulet.minmax([1, 2, 3, 10, 11, 12]).max_window { |w| w.range <= 5 }.each_window { |w| w.range }
        ranges.each { |r| expect(r).to be <= 5 }
      end
    end

    describe "#max_range_while" do
      it "returns the max range under constraint" do
        result = Rivulet.minmax([1, 3, 2, 5, 4]).max_range_while { |w| w.size <= 3 }
        expect(result).to be >= 2
      end
    end

    describe Rivulet::MinMaxWindow do
      it "returns nil min/max when empty" do
        w = Rivulet::MinMaxWindow.new
        expect(w.min).to be_nil
        expect(w.max).to be_nil
        expect(w.range).to be_nil
      end

      it "updates after eviction" do
        w = Rivulet::MinMaxWindow.new
        w.add(1)
        w.add(5)
        w.add(3)
        w.evict  # evicts 1, which IS the min deque head
        expect(w.min).to eq(3)
        expect(w.max).to eq(5)
      end

      it "updates max after evicting the maximum" do
        w = Rivulet::MinMaxWindow.new
        w.add(9)
        w.add(2)
        w.add(5)
        w.evict  # evicts 9, which IS the max deque head
        expect(w.max).to eq(5)
      end
    end
  end

  describe Rivulet::WindowBuilder do
    describe "#max_by" do
      it "returns top k" do
        expect(Rivulet.sum([1, 2, 3, 4, 5]).windows(2).max_by(3) { |w| w.sum }).to eq([9, 7, 5])
      end

      it "returns nil for empty" do
        expect(Rivulet.sum([]).windows(2).max_by { |w| w.sum }).to be_nil
      end
    end

    describe "#min_by" do
      it "returns bottom k" do
        expect(Rivulet.sum([1, 2, 3, 4, 5]).windows(2).min_by(3) { |w| w.sum }).to eq([3, 5, 7])
      end

      it "returns nil for empty" do
        expect(Rivulet.sum([]).windows(2).min_by { |w| w.sum }).to be_nil
      end
    end

    describe "#first" do
      it "returns first value with block" do
        expect(Rivulet.sum([1, 2, 3, 4]).windows(2).first { |w| w.sum }).to eq(3)
      end

      it "returns first k values" do
        expect(Rivulet.sum([1, 2, 3, 4]).windows(2).first(2) { |w| w.sum }).to eq([3, 5])
      end

      it "returns first k without block" do
        result = Rivulet.sum([1, 2, 3]).windows(2).first(2)
        expect(result.size).to eq(2)
      end

      it "filters nil from block" do
        result = Rivulet.sum([1, 2, 3, 4, 5]).windows(2).first(2) { |w| w.sum > 5 ? w.sum : nil }
        expect(result).to eq([7, 9])
      end

      it "skips nil in single mode" do
        result = Rivulet.sum([1, 2, 3, 4]).windows(2).first { |w| w.sum > 4 ? w.sum : nil }
        expect(result).to eq(5)
      end

      it "works without a block" do
        expect(Rivulet.sum([1, 2, 3]).windows(2).first).not_to be_nil
      end

      it "returns nil for empty" do
        expect(Rivulet.sum([]).windows(2).first { |w| w.sum }).to be_nil
      end
    end

    describe "#take" do
      it "is an alias for first(k)" do
        expect(Rivulet.sum([1, 2, 3, 4]).windows(2).take(2) { |w| w.sum }).to eq([3, 5])
      end
    end

    describe "#count" do
      it "counts windows" do
        expect(Rivulet.sum([1, 2, 3, 4, 5]).windows(3).count).to eq(3)
      end
    end

    describe "filter_map semantics" do
      it "each_window filters nil values" do
        result = Rivulet.sum([1, 2, 3, 4, 5]).windows(2).each_window { |w| w.sum > 5 ? w.sum : nil }
        expect(result).to eq([7, 9])
      end
    end
  end

  describe ".stats" do
    describe "#windows" do
      it "tracks sum, minmax, and count in a single pass" do
        results = Rivulet.stats([3, 1, 4, 1, 5]).windows(3) do |w|
          [w.sum, w.min, w.max, w.distinct]
        end
        expect(results[0]).to eq([8, 1, 4, 3])
        expect(results[1]).to eq([6, 1, 4, 2])
        expect(results[2]).to eq([10, 1, 5, 3])
      end

      it "average and range" do
        result = Rivulet.stats([2, 4, 6]).windows(3) { |w| [w.average, w.range] }
        expect(result).to eq([[4.0, 4]])
      end
    end

    describe "#max_window" do
      it "constrains by sum and yields all stats" do
        windows = Rivulet.stats([1, 2, 3, 10]).max_window { |w| w.sum <= 6 }.each_window { |w| w.sum }
        windows.each { |s| expect(s).to be <= 6 }
      end
    end

    describe "#tumbling" do
      it "emits non-overlapping stat windows" do
        results = Rivulet.stats([1, 2, 3, 4, 5, 6]).tumbling(3) { |w| w.sum }
        expect(results).to eq([6, 15])
      end
    end

    describe Rivulet::StatsWindow do
      subject(:w) { Rivulet::StatsWindow.new }

      it "returns nil for min/max/range/average when empty" do
        expect(w.min).to be_nil
        expect(w.max).to be_nil
        expect(w.range).to be_nil
        expect(w.average).to be_nil
      end

      it "tracks all metrics after adds" do
        w.add(3); w.add(1); w.add(4)
        expect(w.sum).to eq(8)
        expect(w.average).to eq(8.fdiv(3))
        expect(w.min).to eq(1)
        expect(w.max).to eq(4)
        expect(w.range).to eq(3)
        expect(w.distinct).to eq(3)
        expect(w.repeats?).to be false
      end

      it "tracks repeated items" do
        w.add(2); w.add(2)
        expect(w.distinct).to eq(1)
        expect(w.repeats?).to be true
        expect(w.max_count).to eq(2)
      end

      it "evicts from the front correctly" do
        w.add(10); w.add(5); w.add(8)
        w.evict
        expect(w.sum).to eq(13)
        expect(w.min).to eq(5)
        expect(w.max).to eq(8)
        expect(w.size).to eq(2)
      end

      it "evicting the min updates it" do
        w.add(1); w.add(9); w.add(3)
        w.evict
        expect(w.min).to eq(3)
        expect(w.max).to eq(9)
      end

      it "evict on empty is safe" do
        expect { w.evict }.not_to raise_error
      end

      it "covers? delegates to count tracking" do
        w.add(1); w.add(2); w.add(1)
        expect(w.covers?({ 1 => 2, 2 => 1 })).to be true
        expect(w.covers?({ 1 => 3 })).to be false
      end
    end
  end

  describe Rivulet::Deque do
    subject(:d) { Rivulet::Deque.new }

    it "push/first/last/any?" do
      d.push(1)
      d.push(2)
      expect(d.first).to eq(1)
      expect(d.last).to eq(2)
      expect(d.any?).to be true
    end

    it "shift advances the front" do
      d.push(10)
      d.push(20)
      d.shift
      expect(d.first).to eq(20)
    end

    it "pop removes from the back" do
      d.push(1)
      d.push(2)
      expect(d.pop).to eq(2)
      expect(d.last).to eq(1)
    end

    it "pop on empty returns nil" do
      expect(d.pop).to be_nil
    end

    it "shift on empty returns nil" do
      expect(d.shift).to be_nil
    end

    it "empty? is true when all elements shifted" do
      d.push(1)
      d.shift
      expect(d.empty?).to be true
    end
  end

  describe Rivulet::Window do
    it "tracks size" do
      w = Rivulet::Window.new
      w.add(1)
      w.add(2)
      expect(w.size).to eq(2)
      expect(w.empty?).to be false
    end

    it "evicts" do
      w = Rivulet::Window.new
      w.add(1)
      w.evict
      expect(w.size).to eq(0)
      expect(w.empty?).to be true
    end

    it "does not go negative" do
      w = Rivulet::Window.new
      w.evict
      expect(w.size).to eq(0)
    end
  end
end
