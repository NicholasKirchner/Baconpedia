require 'httparty'

class WikipediaGetter
  include HTTParty
  base_uri 'en.wikipedia.org'

  LINK_LIMIT = 10

  def initialize(titles)
    titles = [titles] unless titles.is_a? Array
    @titles = titles.join('|')
    @query_options = { :action => 'query',
                       :format => 'json',
                       :rawcontinue => true
                     }
  end

  def forward_link_options(continue = nil)
    forward_options = { :prop => 'links',
                        :redirects => true,
                        :pllimit => LINK_LIMIT,
                        :plnamespace => 0,
                        :titles => @titles
                      }
    forward_options[:plcontinue] = continue if continue
    { :query => @query_options.merge( forward_options ) }
  end

  def get_linked_page_titles
    linked_page_titles = []
    plcontinue_param = nil
    
    loop do
      response = get_api_response(forward_link_options(plcontinue_param))

      linked_page_titles << response["query"]["pages"].values.map do |page_data|
        page_data["links"].map { |link| link["title"] }
      end
      
      break unless response["query-continue"]
      
      plcontinue_param = response["query-continue"]["links"]["plcontinue"]
    end
    linked_page_titles.flatten
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

#WikipediaGetter.new(["Kevin_Bacon"]).get_linked_page_titles
