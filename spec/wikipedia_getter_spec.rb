require_relative '../app/wikipedia_getter'
require 'json'

def json_fixture(filename)
  File.open("spec/fixtures/#{filename}.json").read
end

describe WikipediaGetter do
  context "#initialize" do
    it "should accept a string as an argument" do
      name = "Joey Jo-Jo Junior Shabadoo"
      getter = WikipediaGetter.new(name)
      expect(getter.instance_variable_get(:@titles)).to eq(name)
    end

    it "should accept an array as an argument, and concatenate the items" do
      names = ["Joey Jo-Jo Junior Shabadoo", "Kevin Bacon"]
      getter = WikipediaGetter.new(names)
      expect(getter.instance_variable_get(:@titles)).to eq(names.join("|"))
    end
  end

  context "#forward_link_options" do

    before :each do
      @name = "Joey Jo-Jo Junior Shabadoo"
      @getter = WikipediaGetter.new(@name)
      @expected_query_params = {
        :query => {
          :action => 'query',
          :format => 'json',
          :rawcontinue => true,
          :prop => 'links',
          :redirects => true,
          :pllimit => WikipediaGetter::LINK_LIMIT,
          :plnamespace => 0,
          :titles => @name
        }
      }
    end

    it "should return the correct query params given no argument" do
      expect(@getter.forward_link_options).to eq(@expected_query_params)
    end

    it "should return the correct query params if given an argument" do
      argument = "testing"
      @expected_query_params[:query][:plcontinue] = argument
      expect(@getter.forward_link_options(argument)).to eq(@expected_query_params)
    end
  end

  context "#get_api_response" do
    it "should retry three times if connection resets happen, then raise an error if it happens again." do
      expect(WikipediaGetter).to receive(:get).exactly(3).times { raise Errno::ECONNRESET }
      getter = WikipediaGetter.new("Joey Jo-Jo Junior Shabadoo")
      expect { getter.get_api_response("testing") }.to raise_error(Errno::ECONNRESET)
    end

    it "should make the correct call to HTTParty" do
      argument = {:query => {}}
      expect(WikipediaGetter).to receive(:get).with("/w/api.php", argument).and_return({})
      getter = WikipediaGetter.new("Joey Jo-Jo Junior Shabadoo")
      getter.get_api_response(argument)
    end
  end

  context "#get_linked_page_titles" do
    it "should compile a list of all page titles" do
      getter = WikipediaGetter.new("Joey Jo-Jo Junior Shabadoo")
      allow(getter).to receive(:get_api_response) do |url_query|
        file = url_query[:query][:plcontinue] ? "wiki_query_without_continue" : "wiki_query_with_continue"
        JSON.parse(json_fixture(file))
      end

      expect(getter.get_linked_page_titles).to include("Actor")
      expect(getter.get_linked_page_titles).to include("WorldCat")
    end

    it "should raise an error if wiki's response has one" do
      getter = WikipediaGetter.new("Joey Jo-Jo Junior Shabadoo")
      allow(getter).to receive(:get_api_response) { JSON.parse(json_fixture("wiki_error")) }
      expect { getter.get_linked_page_titles }.to raise_error(WikiError)
    end

  end
end