# frozen_string_literal: true

# Handle routing request for Home
class HomeController < ApplicationController
  def stories
    @news = StoriesParsing.new
    @news.parse
  end

  def story
    @story = StoryParsing.new(params[:url], params[:image])
    @story.parse
  end
end
