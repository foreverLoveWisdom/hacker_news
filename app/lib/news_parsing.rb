# frozen_string_literal: true

require 'net/http'
require 'logger'

# Handle parsing news content
class NewsParsing

  HACKER_NEWS = 'https://news.ycombinator.com/best'

  def initialize(url = HACKER_NEWS)
    @url            = url
    @failed_stories = 0
    @news_list      = []
  end

  def failed_stories
    @failed_stories
  end

  def parse
    uri = URI(@url)
    begin
      response = Net::HTTP.get_response(uri)
      raise StandardError, "Failed to fetch page content. Response code: #{response.code}" unless response.code == '200'

      doc         = Nokogiri::HTML(response.body)
      story_links = doc.xpath("//table[1]/tr/td/a[@class='storylink']")
      news_list   = []
      threads     = []
      begin
        story_links.each do |story_link|
          threads << Thread.new do
            next if story_link.include?('medium')

            story_url = story_link.attributes['href'].to_s
            next if story_url.include?('item')

            meta_url    = 'https://api.urlmeta.org'
            meta_result = HTTParty.get(
              meta_url,
              headers: { 'Authorization' => 'Basic ZG9tYW5odGllbjIwMTFAZ21haWwuY29tOmExVk1vMkdJV0JrcTl0M3dmYWhn' },
              query:   { 'url' => story_url }
            )

            unless meta_result.dig('result', 'status') == 'OK'
              raise StandardError, "Failed to get meta data for #{story_url}"
            end

            story_hash = {
              title:         story_link.text,
              story_image:   meta_result.dig("meta", "image"),
              story_excerpt: "#{meta_result.dig("meta", "description")}...",
              story_url:     story_url
            }

            news_list << story_hash
          rescue StandardError => e
            @failed_stories += 1
            Rails.logger.debug { "Rescued exception: #{e.inspect}" }
            next
          end
        end
      end

      threads.each(&:join)
      news_list
    rescue StandardError => e
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
    end
  end

  private

    def filter_story_content(story_response)
      Readability::Document.new(story_response.body,
                                tags:               %w[p img],
                                attributes:         %w[src href],
                                remove_empty_nodes: true)
    end
end
