# frozen_string_literal: true

# Example: API Batch Packing
# Pack records into batches that fit under a byte budget for an API endpoint.

require "bundler/setup"
require "rivulet"

# Simulate records with varying payload sizes
records = 500.times.map do |i|
  { id: i, payload: "x" * rand(50..500) }
end

max_bytes = 4096

puts "=== API Batch Packing ==="
puts "Records: #{records.size}"
puts "Max payload: #{max_bytes} bytes"
puts

# Largest single batch that fits
biggest_size = Rivulet.sum(records) { |r| r[:payload].bytesize }
  .max_window { |w| w.sum <= max_bytes }
  .max_by { |w| w.size }

puts "Largest batch size: #{biggest_size} records"

# Max batch size without allocating snapshots
max_batch_size = Rivulet.sum(records) { |r| r[:payload].bytesize }
  .max_size_while { |w| w.sum <= max_bytes }

puts "Max batch size (via reduce): #{max_batch_size}"
