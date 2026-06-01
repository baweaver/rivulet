# Rivulet

Sliding window operations for Ruby collections.

Fixed and variable-size windows with O(1) incremental state and near-zero allocations. Sum, count, min/max, and combined stats windows that grow, shrink, and emit results without copying.

## Installation

```ruby
gem "rivulet"
```

## Usage

### Moving average

```ruby
Rivulet.sum(latencies).windows(3) { |w| w.average }
# => [20.0, 30.0, 40.0]
```

### Batch records under a byte budget

```ruby
Rivulet.sum(records, &:bytesize)
  .max_size_while { |w| w.sum <= 1024 }
# => 12  (max records that fit)
```

### Minimum subarray meeting a target

```ruby
Rivulet.sum(nums).min_size_where { |w| w.sum >= target }
# => 2  (smallest window with sum >= target)
```

### Longest non-repeating run

```ruby
Rivulet.count(events)
  .max_window { |w| !w.repeats? }
  .max_by { |w| w.size }
# => 5
```

### Sliding window maximum (O(n) via monotonic deque)

```ruby
Rivulet.minmax(prices).windows(20) { |w| w.max }
# => [103, 105, 105, ...]
```

### Top-k windows

```ruby
Rivulet.sum(data).windows(5).max_by(3) { |w| w.average }
# => [98.2, 95.1, 93.7]
```

### Minimum window containing all target characters

```ruby
target = Hash.new(0)
t.each_char { |c| target[c] += 1 }

Rivulet.count(s.chars)
  .min_window { |w| w.covers?(target) }
  .min_by { |w| w.size }
# => 4  (smallest window covering all of t)
```

### Early termination

```ruby
Rivulet.sum(data)
  .max_window { |w| w.sum <= budget }
  .first { |w| w.size }
# => 1  (first valid window's size)
```

## Window Types

| Entry point | Tracks | Window methods |
|---|---|---|
| `Rivulet.sum(source)` | Running total | `sum`, `average`, `size` |
| `Rivulet.sum(source) { \|item\| ... }` | Derived metric sum | `sum`, `average`, `size` |
| `Rivulet.count(source)` | Item frequencies | `distinct`, `repeats?`, `max_count`, `covers?`, `counts`, `size` |
| `Rivulet.minmax(source)` | Rolling min/max | `min`, `max`, `range`, `size` |
| `Rivulet.stats(source)` | All of the above | `sum`, `average`, `min`, `max`, `range`, `distinct`, `repeats?`, `max_count`, `covers?`, `counts`, `size` |

## API

### Building a window stream

```ruby
stream = Rivulet.sum(data)        # or .count, .minmax
stream = Rivulet.sum(data) { |item| item.bytesize }  # with mapper
```

### Fixed-size windows

```ruby
stream.windows(n)                 # => WindowBuilder
stream.windows(n) { |w| ... }    # => Array (filter_map semantics)
```

### Variable-size windows (grow/shrink)

```ruby
stream.max_window { |w| rule }      # => WindowBuilder (maximize: shrink when invalid)
stream.min_window { |w| goal }  # => WindowBuilder (minimize: shrink while still valid)
```

`max_window` grows the window and evicts from the front when the rule fails — use it to find the **largest** window under a constraint.

`min_window` grows the window and shrinks from the front while the goal holds — use it to find the **smallest** window meeting a goal.

### Terminal methods on WindowBuilder

All terminals yield the **live window** — no snapshots allocated.

```ruby
builder.each_window { |w| ... }   # filter_map: collect non-nil block results
builder.max_by { |w| ... }        # single best score
builder.max_by(k) { |w| ... }    # top-k scores (descending)
builder.min_by { |w| ... }        # single smallest score
builder.min_by(k) { |w| ... }    # bottom-k scores (ascending)
builder.first { |w| ... }         # first non-nil result
builder.first(k) { |w| ... }     # first k non-nil results
builder.take(k) { |w| ... }      # alias for first(k)
builder.count                     # number of valid windows
```

### Reducers (single-value shortcuts)

```ruby
stream.max_size_while { |w| rule }     # largest window size under constraint
stream.max_sum_while { |w| rule }      # largest sum under constraint (sum only)
stream.min_size_where { |w| goal }     # smallest window size meeting goal (sum only)
stream.max_distinct_while { |w| rule } # most distinct items (count only)
stream.max_range_while { |w| rule }    # largest range (minmax only)
```

## Performance

Rivulet's builder path allocates near-zero objects regardless of input size:

```
200k items, budget 500:
  max_window.max_by { size }       39 objects
  max_size_while (reducer)          13 objects
  windows(5) { average }            18 objects
```

The `minmax` window uses monotonic deques for O(1) amortized min/max per step. All window types maintain O(1) incremental state updates.

## Requirements

- Ruby >= 3.2

## License

MIT
