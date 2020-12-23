# frozen_string_literal: true

require 'net/http'
require 'logger'

# Handle parsing news content
class NewsParsing
  HACKER_NEWS = 'https://news.ycombinator.com/best'

  def initialize(url = HACKER_NEWS)
    @url = url
    @news_list = []
  end

  def parse
    uri = URI(@url)
    begin
      response = Net::HTTP.get_response(uri)
      raise StandardError, "Failed to fetch page content. Response code: #{response.code}" unless response.code == '200'

      doc = Nokogiri::HTML(response.body)
      story_links = doc.xpath("//table[1]/tr/td/a[@class='storylink']")
      news_list = []
      story_links.each do |story_link|
      article_url = story_link.attributes['href'].to_s
      news_hash = {
        title: story_link.text,
        article_url: article_url,
      }
      news_list << news_hash
      end
      news_list
    rescue StandardError => e
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
    end
  end

  private

  # def filter_article_content(article_response)
  #   Readability::Document.new(article_response.body,
  #                             tags: %w[p img],
  #                             attributes: %w[src href],
  #                             remove_empty_nodes: true)
  # end
end
