# frozen_string_literal: true

require 'net/http'
require 'logger'

# Handle parsing news content
class NewsParsing
  HACKER_NEWS = 'https://news.ycombinator.com/best'

  def initialize(url = HACKER_NEWS)
    @url = url
  end

  def parse
    uri = URI(@url)
    begin
      response = Net::HTTP.get_response(uri)
      raise StandardError, "Failed to fetch page content. Response code: #{response.code}" unless response.code == '200'

      generate_news_list(response)
    rescue StandardError => e
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
    end
  end

  private

  def generate_news_list(response)
    best_news = []
    doc = Nokogiri::HTML(response.body)
    story_links = doc.xpath("//table[1]/tr/td/a[@class='storylink']")
    fetch_articles_info(best_news, story_links)
    best_news
  end

  def fetch_articles_info(best_news, story_links)
    story_links.each do |story_link|
      extract_article_data(best_news, story_link)
    rescue StandardError => e
      Rails.logger.debug { "Rescued exception: #{e.inspect}" }
    ensure
      next
    end
  end

  def extract_article_data(best_news, story_link)
    article_uri = URI(story_link.attributes['href'].to_s)
    article_response = Net::HTTP.get_response(article_uri)
    unless article_response.code == '200'
      raise StandardError,
            "Failed to fetch article content at #{article_uri}. Response code: #{article_response.code}"
    end

    article_body = filter_article_content(article_response)
    news_hash = get_news_info(article_body, story_link)
    best_news << news_hash
  end

  def get_news_info(article_body, story_link)
    {
      title: story_link.text,
      image_url: article_body.images.first,
      article_excerpt: "#{article_body.content.strip.first(50)}...".gsub(/\n/, '')
    }
  end

  def filter_article_content(article_response)
    Readability::Document.new(article_response.body,
                              tags: %w[p img],
                              attributes: %w[src href],
                              remove_empty_nodes: true)
  end
end
