# frozen_string_literal: true

require 'logger'
# Parsing story content
class StoryParsing
  attr_reader :url, :image, :error, :content

  def initialize(url, image)
    @url   = url
    @image = image
    @error = false
    @content = ''
  end

  def parse
    response = HTTParty.get(url)
    raise_url_fetching_error(response)
    story = Readability::Document.new(response.body,
                                      tags: %w[div p img a],
                                      attributes: %w[src href],

                                      remove_empty_nodes: true)
    @content = story.content.strip
  rescue StandardError => e
    Rails.logger.debug("Rescued Exception: #{e.inspect}")
  end

  private

  def raise_url_fetching_error(response)
    return if response.code == 200

    @error = true
    raise StandardError, "Failed to fetch page content. Response code: #{response.code}"
  end
end
