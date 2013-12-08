#!/usr/bin/env ruby

require 'rubygems'
require 'papercfg'

# This script uses an fxin_to_stapol.yml file to create ASCII-grams of the
# main grid for each ROACH2 showing where each ADC chip is getting its signal.
# This can be used to verify that inputs to an individual ADC chip do not form
# a "high value" baseline.

cell_text = '--'
row_cells = [cell_text] * 16
# Build global_grid[0..6][0..15]
global_grid = []
7.times {global_grid << row_cells.dup}

fin = ARGV[0] || 'fxin_to_stapol.yml'
map = PaperCfg.load_file(fin)

# Pattern used to parse stapols
pattern = PaperCfg::PATTERNS['stapol']

for f in 1..8
  # Build grid[0..6][0..15]
  grid = []
  7.times {grid << row_cells.dup}

  # Init outlier counter
  num_outliers = 0

  for chip in 'A'..'H'
    for chan in 1..4
      if pattern !~ map["f#{f}#{chip}#{chan}"]
        warn "invalid stapol for f#{f}#{chip}#{chan} " +
             "(#{map["f#{f}#{chip}#{chan}"]})"
        next
      end

      row, col, pol = $1, $2, $3

      # Skip Y pols
      next if pol == 'Y'

      # Count and skip outliers
      unless ('A'..'G') === row
        num_outliers += 1
        next
      end

      # Convert row and col to number
      row = row.ord - 'A'.ord
      col = col.to_i

      # Put text in grid and global_grid
      if grid[row][col] != cell_text
        warn "position for f#{f}#{chip}#{chan} is " +
             "already marked #{grid[row][col]}"
      end
      if global_grid[row][col] != cell_text
        warn "global position for f#{f}#{chip}#{chan} is " +
             "already marked #{global_grid[row][col]}"
      end
      grid[row][col] = "#{chip}#{chan}"
      global_grid[row][col] = "f#{f}"
    end
  end

  # Output grid
  puts "PAPER F Engine #{f} (pf#{f}) Input Grid (#{num_outliers} outliers not shown):"
  puts
  puts "     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15"
  puts "  +----------------------------------------------------------------+"

  for row in 0..6
    print "#{'ABCDEFG'[row]} | "
    print grid[row].join('  ')
    print " | #{'ABCDEFG'[row]}"
    puts
  end

  puts "  +----------------------------------------------------------------+"
  puts "     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15"
  puts
  puts
end

# Output global_grid
puts "PAPER F Engine Global Input Grid (outliers not shown):"
puts
puts "     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15"
puts "  +----------------------------------------------------------------+"

for row in 0..6
  print "#{'ABCDEFG'[row]} | "
  print global_grid[row].join('  ')
  print " | #{'ABCDEFG'[row]}"
  puts
end

puts "  +----------------------------------------------------------------+"
puts "     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15"

