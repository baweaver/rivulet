# frozen_string_literal: true

# Example: Bulk Insert Chunking
# Split records into chunks that stay under PostgreSQL's 65535 bind parameter limit.
# Each record uses N bind params (one per column).

require "bundler/setup"
require "rivulet"

# Simulate ActiveRecord-style rows with varying column counts
columns_per_row = 12
records = 8000.times.map { |i| { id: i, columns: columns_per_row } }
max_binds = 65_535

puts "=== Bulk Insert Chunking ==="
puts "Records: #{records.size}"
puts "Columns per row: #{columns_per_row}"
puts "Max bind params: #{max_binds}"
puts

max_chunk = Rivulet.sum(records) { |_| columns_per_row }
  .max_size_while { |w| w.sum <= max_binds }

puts "Max rows per INSERT: #{max_chunk}"
puts "Chunks needed: #{(records.size.to_f / max_chunk).ceil}"
