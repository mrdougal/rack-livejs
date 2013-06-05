require 'nokogiri'
require 'rack'
require 'rack/livejs'
require 'rack/test'
require 'rspec'

describe Rack::Livejs do

  include Rack::Test::Methods

  let(:decorated_app) do
    fixtures_dir = File.expand_path("../../fixtures", __FILE__)
    Rack::Directory.new(fixtures_dir)
  end

  let(:app) { described_class.new(decorated_app) }

  describe "getting an HTML file" do

    before do
      get "page.html"
    end

    let(:html) { Nokogiri::HTML(last_response.body) }

    it "retains the HTML content" do
      expect(html.css("head title").text).to eq("Sample page")
      expect(html.css("body").text.strip).to eq("Sample content")
    end

    it "injects the live.js script" do
      script_tag = html.css("head script").first
      expect(script_tag).to_not be_nil
      expect(script_tag[:src]).to eq("http://livejs.com/live.js")
    end

  end

  describe "getting a non-HTML file" do

    before do
      get "text.txt"
    end

    it "returns the expected content" do
      expect(last_response.body).to include("sample content")
    end

    it "returns the expected content-type" do
      expect(last_response.content_type).to eq "text/plain"
    end

    it "does not inject live.js" do
      expect(last_response.body).to_not include("live.js")
    end

  end

end
