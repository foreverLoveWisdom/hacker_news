# frozen_string_literal: true

require 'logger'

# Parsing stories content
class StoriesParsing
  attr_reader :url, :failed_stories, :stories

  HACKER_NEWS = 'https://news.ycombinator.com/best'

  def initialize(url = HACKER_NEWS)
    @url            = url
    @failed_stories = 0
    @stories        = []
    @threads        = []
  end

  def parse
    response = HTTParty.get(url)
    raise_url_fetching_error(response)
    doc = Nokogiri::HTML(response.body)
    story_urls = get_story_urls(doc)
    get_stories_info(story_urls)
    @threads.each(&:join)
  rescue StandardError => e
    Rails.logger.debug { "Rescued exception: #{e.inspect}" }
  end

  private

  def raise_url_fetching_error(response)
    raise StandardError, "Failed to fetch page content. Response code: #{response.code}" unless response.code == 200
  end

  def get_story_urls(doc)
    doc.xpath("//table[1]/tr/td/a[@class='storylink']")
       .map { |story_link| story_link.attributes['href'].to_s }
       .reject { |story_url| link_unfetchable?(story_url) }
  end

  def get_stories_info(story_urls)
    story_urls.each do |story_url|
      get_story_data(story_url)
    end
  end

  def get_story_data(story_url)
    @threads << Thread.new do
      meta_data = fetch_meta_info(story_url)
      raise_meta_api_error(meta_data, story_url)
      story_info = generate_story_data(meta_data, story_url)
      next if story_info[:title].blank?

      @stories << story_info
    rescue StandardError => e
      @failed_stories += 1
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
      next
    end
  end

  def raise_meta_api_error(meta_data, story_url)
    raise StandardError, "Failed to get meta data for #{story_url}" unless meta_data.dig('result',
                                                                                         'status') == 'OK'
  end

  def generate_story_data(meta_data, story_url)
    {
      title: meta_data.dig('meta', 'title'),
      image: meta_data.dig('meta', 'image'),
      excerpt: "#{meta_data.dig('meta', 'description')}...",
      url: story_url
    }
  end

  def link_unfetchable?(story_link)
    story_link.include?('medium') || story_link.include?('item?')
  end

  def fetch_meta_info(story_url)
    meta_url = 'https://api.urlmeta.org'
    HTTParty.get(
      meta_url,
      headers: { 'Authorization' => 'Basic ZG9tYW5odGllbjIwMTFAZ21haWwuY29tOmExVk1vMkdJV0JrcTl0M3dmYWhn' },
      query: { 'url' => story_url }
    )
  end
end
