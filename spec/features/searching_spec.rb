require 'rails_helper'

describe Searching do
  let(:regular_search) { described_class.new("search_term" => "car tax", "count" => 20) }
  # this is the search that was used in our sample JSON file (spec/fixtures/json/api_response_a)
  let(:results_hash) { regular_search.call.results }

  describe 'initialization' do
    it "initializes properly" do
      expect(regular_search.is_a?(described_class)).to eql(true)
    end
  end

  describe 'result count' do
    it "defaults to 10 results if no count is enetered" do
      small_search = described_class.new("search_term" => "car tax", "count" => "")
      expect(small_search.count).to eql(10)
    end

    it "leaves the count as is for entered counts between 1 and 1000" do
      expect(regular_search.count).to eql(20)
    end

    it "caps the count at 1000 for very large searches" do
      large_search = described_class.new("search_term" => "car tax", "count" => 1001)
      expect(large_search.count).to eql(1000)
    end
  end

  describe 'external request' do
    it 'creates a class that sends a request to rummager' do
      expect(regular_search.call.class).to eql(described_class::Results)
    end
  end
end
