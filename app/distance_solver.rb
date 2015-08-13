class WikipediaDistanceSolver

  def initialize(start_point, end_point)
    @all_nodes_seen = Set.new([start_point])
    @new_nodes_by_tier = [@all_nodes_seen]
    @end_point = end_point
  end

  def find_distance
    until @new_nodes_by_tier.last.empty? || @all_nodes_seen.include?(@end_point)
      get_next_tier!
      puts "tier: #{@new_nodes_by_tier.count}, items: #{@new_nodes_by_tier.last.count}"
    end
    @new_nodes_by_tier.empty? ? -1 : @new_nodes_by_tier.count - 1
  end

  def get_next_tier!
    next_tier = Set.new
    @new_nodes_by_tier.last.each do |new_node|
      getter = WikipediaGetter.new(new_node)
      next_tier.merge(getter.get_linked_page_titles)
      break if next_tier.include? @end_point
    end
    @new_nodes_by_tier << next_tier - @all_nodes_seen
    @all_nodes_seen.merge(@new_nodes_by_tier.last)
  end

end
