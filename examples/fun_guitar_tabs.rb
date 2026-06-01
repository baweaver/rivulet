# frozen_string_literal: true

# Example: Guitar Tab Analysis
# Parse real tablature (Tárrega's Lágrima) and analyze fret patterns,
# string crossings, position shifts, and phrase difficulty.

require "bundler/setup"
require "rivulet"

# Parse a classtab.org-style tab into a sequence of {string, fret} notes.
# We use the 1st version (Vincenzo della Vecchia) of Lágrima.
TAB = <<~TAB
  E|--4---5---7---|--2----------|--4---5---7---|--2----------|--12---11---9---|
  B|----0---0---0-|---0---0---0-|----0---0---0-|---0---0---0-|-------------7-|
  G|--------------|-----2-------|--------------|-----2-------|----9----9------|
  D|--2---4---6---|-1-----------|--2---4---6---|-1-----------|-11----9---7----|
  A|--------------|--------2----|--------------|--------2----|----------------|
  E|--------------|-------------|--------------|-------------|----------------|
TAB

def parse_tab(tab)
  lines = tab.strip.lines.map { |l| l.strip.sub(/^[EBGDA]\|/, "").chomp("|").chomp }
  notes = []

  max_len = lines.map(&:length).max
  (0...max_len).each do |col|
    lines.each_with_index do |line, string_idx|
      char = line[col]
      next unless char&.match?(/\d/)
      # Skip if previous char was also a digit (second digit of a two-digit fret)
      next if col > 0 && line[col - 1]&.match?(/\d/)

      fret_str = char
      fret_str += line[col + 1] if line[col + 1]&.match?(/\d/)

      notes << { string: string_idx + 1, fret: fret_str.to_i, position: col }
    end
  end

  notes.sort_by { |n| [n[:position], n[:string]] }
end

notes = parse_tab(TAB)
frets = notes.map { |n| n[:fret] }
strings = notes.map { |n| n[:string] }

puts "=== Guitar Tab Analysis: Tárrega - Lágrima (first 5 measures) ==="
puts "Notes parsed: #{notes.size}"
puts "Fret range: #{frets.min}-#{frets.max}"
puts "Strings used: #{strings.uniq.sort.join(', ')}"
puts

# Widest fret stretch in any 4-note phrase
widest = Rivulet.minmax(frets).windows(4).max_by { |w| w.range }
puts "Widest 4-note fret span: #{widest} frets"
puts

# Longest run staying on the same string
same_string_size = Rivulet.count(strings)
  .max_window { |w| w.distinct == 1 }
  .max_by { |w| w.size }

puts "Longest run on one string: #{same_string_size} notes"
puts

# Position shifts: how far does the fretting hand move between consecutive notes?
shifts = frets.each_cons(2).map { |a, b| (b - a).abs }

# Longest stretch in one "box" position (4-fret span)
box_size = Rivulet.minmax(frets)
  .max_window { |w| w.range <= 4 }
  .max_by { |w| w.size }

puts "Longest stretch in one position (4-fret box): #{box_size} notes"
puts

# String crossing density: crossings per 5-note window
crossings = strings.each_cons(2).map { |a, b| a == b ? 0 : 1 }
busiest = Rivulet.sum(crossings).windows(4).max_by { |w| w.sum }
calmest = Rivulet.sum(crossings).windows(4).min_by { |w| w.sum }

puts "String crossings per 5-note phrase:"
puts "  Busiest: #{busiest} crossings"
puts "  Calmest: #{calmest} crossings"
