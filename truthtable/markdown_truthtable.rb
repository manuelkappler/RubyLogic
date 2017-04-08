require './TruthTable'
require './Logic'
require './LogicParser'
require 'colorize'
require 'optparse'

options = {:novars => true}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: truthtable.rb [options] expression_string[s]"
  opts.on("-a", "--all", "Print all WFFs") do |a|
    options[:printall] = a
  end
  opts.on("-e", "--equiv", "Checks whether the two given expressions are equivalent") do |e|
    options[:equivalent] = e
  end
  opts.on("--novars", "Don't print the variables, just print the sentences") do |n|
    options[:novars] = false
  end
end
opt_parser.parse!

if options[:equivalent]
  var1, wff1 = parse_string(ARGV[0])
  var2, wff2 = parse_string(ARGV[1], var1)
#  puts var2
#  puts wff1.inspect
#  puts wff2.inspect
  tt = TruthTable.new(var2)
  tt.add_wff wff1
  tt.add_wff wff2
  options[:printall] ? tt.print_with_terminaltable : tt.print_wffs_with_terminaltable([wff1, wff2], options[:novars])
  puts "Are #{wff1.to_s} and #{wff2.to_s} equivalent? #{(tt.are_equivalent? wff1, wff2) ? "Yes" : "No"}"
else
  wffs = []
  vars = {}
  ARGV.each do |formula|
    vars, wff = parse_string(formula, vars)
    wffs << wff
  end
  tt = TruthTable.new(vars)
  wffs.each do |wff|
    tt.add_wff wff
  end
  options[:printall] ? tt.print_with_terminaltable : tt.print_wffs_with_terminaltable(wffs, options[:novars])
end
