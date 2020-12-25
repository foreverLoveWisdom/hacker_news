# frozen_string_literal: true

require 'logger'

# Handle parsing news content
class NewsParsing

  HACKER_NEWS = 'https://news.ycombinator.com/best'

  def initialize(url = HACKER_NEWS)
    @url            = url
    @failed_stories = 0
  end

  def failed_stories
    @failed_stories
  end

  def parse
    begin
      get_news_list
    rescue StandardError => e
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
    end
  end

  private

    def get_news_list
      response = Net::HTTP.get_response(URI(@url))
      raise StandardError, "Failed to fetch page content. Response code: #{response.code}" unless response.code == '200'

      doc         = Nokogiri::HTML(response.body)
      story_links = doc.xpath("//table[1]/tr/td/a[@class='storylink']")
      news_list   = []
      fetch_story_info(news_list, story_links)
      # threads.each(&:join)
      news_list
    end

    def fetch_story_info(news_list, story_links)
      threads = []
      story_links.each do |story_link|
        threads << Thread.new do
          begin
            next if story_link.include?('medium')

            story_url = story_link.attributes['href'].to_s
            story_response = HTTParty.get(story_url)

            unless story_response.code == 200
              raise StandardError, "Failed to fetch data for url: #{story_url}. Code: #{story_response.code}"
            end

            puts "Parsing data for: #{story_url}"
            story_data = filter_story_content(story_response)
            story_hash = {
              title:         story_link.text,
              story_image:   story_data.images.first,
              story_content: story_data.content.strip,
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
    end

    def filter_story_content(story_response)
      Readability::Document.new(story_response.body,
                                tags:               %w[p img],
                                attributes:         %w[src href],
                                remove_empty_nodes: true)
    end
end
