require 'require_all'
require 'set'

require_all 'app'

start_point = ARGV.join.split("/").last
solver = WikipediaDistanceSolver.new(start_point, "Kevin Bacon")
puts solver.find_distance