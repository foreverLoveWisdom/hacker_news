# frozen_string_literal: true

# Handle routing request for Home
class HomeController < ApplicationController
  def news
    @news = NewsParsing.new
    @news.parse
  end
end
