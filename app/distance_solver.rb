class WikipediaDistanceSolver

  def initialize(start_point, end_point)
    @all_nodes_seen = Set.new([start_point])
    @new_nodes_by_tier = [@all_nodes_seen]
    @end_point = end_point
  end

  def find_distance
    return 0 if @start_point == @end_point
    backtrace_one_level!
    return 1 if @one_tier_from_done.include?(@end_point)
    
    until @new_nodes_by_tier.last.empty? || @all_nodes_seen.intersect?(@one_tier_from_done)
      get_next_tier!
    end
    @new_nodes_by_tier.empty? ? -1 : @new_nodes_by_tier.count
  end

  def get_next_tier!
    next_tier = Set.new
    @new_nodes_by_tier.last.each do |new_node|
      getter = WikipediaGetter.new(new_node)
      new_items = Set.new(getter.get_linked_page_titles)
      next_tier.merge(new_items)
      break if new_items.intersect?(@one_tier_from_done)
    end
    @new_nodes_by_tier << next_tier - @all_nodes_seen
    @all_nodes_seen.merge(@new_nodes_by_tier.last)
  end

  def backtrace_one_level!
    getter = WikipediaGetter.new(@end_point)
    @one_tier_from_done = Set.new(getter.get_backlinked_page_titles)
  end

end
