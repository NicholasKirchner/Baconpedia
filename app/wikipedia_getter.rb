require 'httparty'

class WikipediaGetter
  include HTTParty
  base_uri 'en.wikipedia.org'

  LINK_LIMIT = "max"

  def initialize(title)
    @title = title
    @query_options = { :action => 'query',
                       :format => 'json',
                       :rawcontinue => true
                     }
  end

  def forward_link_options(continue = nil)
    forward_options = { :prop => 'links',
                        :pllimit => LINK_LIMIT,
                        :plnamespace => 0,
                        :titles => @title
                      }
    forward_options[:plcontinue] = continue if continue
    { :query => @query_options.merge( forward_options ) }
  end

  def backward_link_options(continue = nil)
    backward_options = { :list => 'backlinks',
                         :bllimit => LINK_LIMIT,
                         :blnamespace => 0,
                         :bltitle => @title
                       }
    backward_options[:blcontinue] = continue if continue
    { :query => @query_options.merge( backward_options ) }
  end

  def get_linked_page_titles
    linked_page_titles = []
    continue_param = nil

    loop do
      response = get_api_response(forward_link_options(continue_param))
      
      if response["error"]
        raise WikiError, response["error"].to_s
      end

      linked_page_titles << response["query"]["pages"].values.map do |page_data|
        #the || [] on the following line is to deal with responses which
        #have "missing" => "" (or similar).  TODO: Isolate this case and write
        #a spec for it.
        (page_data["links"] || []).map { |link| link["title"] }
      end
      
      break unless response["query-continue"]
      
      continue_param = response["query-continue"]["links"]["plcontinue"]
    end
    linked_page_titles.flatten
  end

  def get_backlinked_page_titles
    backlinked_page_titles = []
    continue_param = nil

    loop do
      response = get_api_response(backward_link_options(continue_param))

      if response["error"]
        raise WikiError, response["error"].to_s
      end

      backlinked_page_titles << response["query"]["backlinks"].map { |blink| blink["title"] }

      break unless response["query-continue"]

      continue_param = response["query-continue"]["backlinks"]["blcontinue"]
    end
    backlinked_page_titles.flatten
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

class WikiError < StandardError
end
