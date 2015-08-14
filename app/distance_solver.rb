class WikipediaDistanceSolver

  def initialize(start_point, end_point)
    @all_nodes_seen = Set.new([start_point])
    @new_nodes_by_tier = [@all_nodes_seen]
    @end_point = end_point
  end

  def find_distance
    return 0 if @start_point == @end_point
    backtrace_one_level_from_end!
    return 1 if @one_tier_from_done.include?(@end_point)
    
    until @new_nodes_by_tier.last.empty? || found_a_link?
      get_next_tier!
    end

    if @new_nodes_by_tier.last.empty?
      return -1
    elsif @new_nodes_by_tier.last.include?(@end_point)
      #yes, we can get here.  For example, if the start point input needs
      #sanitation (i.e. "Fred_Flintstone" is more properly identified as
      #"Fred Flintstone" -- no underscore.  In this case, @one_tier_from_done
      #would pick up "Fred Flintstone" which would not be equivalent to
      #a start point of "Fred_Flintstone"
      return @new_nodes_by_tier.count - 1
    else
      return @new_nodes_by_tier.count
    end
  end

  def get_next_tier!
    next_tier = Set.new
    @new_nodes_by_tier.last.each do |new_node|
      getter = WikipediaGetter.new(new_node)
      new_items = Set.new(getter.get_linked_page_titles)
      next_tier.merge(new_items)
      break if found_a_link?(new_items)
    end
    @new_nodes_by_tier << next_tier - @all_nodes_seen
    @all_nodes_seen.merge(@new_nodes_by_tier.last)
  end

  def backtrace_one_level_from_end!
    getter = WikipediaGetter.new(@end_point)
    @one_tier_from_done = Set.new(getter.get_backlinked_page_titles)
  end

  def found_a_link?(new_items = nil)
    new_items ||= @new_nodes_by_tier.last
    new_items.include?(@end_point) || new_items.intersect?(@one_tier_from_done)
  end

  
end
