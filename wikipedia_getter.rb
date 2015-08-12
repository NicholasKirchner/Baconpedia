require 'httparty'

class WikipediaGetter
  include HTTParty
  base_uri 'en.wikipedia.org'

  def initialize(titles)
    @options = { :query => { :action => 'query',
                             :format => 'json',
                             :prop => 'links',
                             :redirects => true,
                             :pllimit => 'max',
                             :plnamespace => '0',
                             :rawcontinue => true,
                             :titles => titles.join('|') } }
  end

  def options_with_plcontinue(plcontinue)
    return @options if plcontinue.nil?
    result = @options.clone
    result[:query][:plcontinue] = plcontinue
    result
  end

  def get_linked_page_titles
    linked_page_titles = []
    plcontinue_param = nil
    
    loop do
      response = get_api_response(options_with_plcontinue(plcontinue_param))

      linked_page_titles << response["query"]["pages"].values.map do |page_data|
        page_data["links"].map { |link| link["title"] }
      end.compact
      
      break unless response["query-continue"]
      
      plcontinue_param = response["query-continue"]["links"]["plcontinue"]
    end
    linked_page_titles.compact
  end

  def get_api_response(url_query)
    begin
      tries ||= 3
      result = self.class.get("/w/api.php", url_query)
    rescue Errno::ECONNRESET => e
      if (tries -= 1) > 0
        puts "retrying due to connection_reset"
        retry
      else
        raise e
      end
    end
    if result["error"]
      puts result["error"]
    end
    result
  end
end

WikipediaGetter.new(["Kevin_Bacon"]).get_linked_page_titles
