# frozen_string_literal: true

# Handle routing request for Home
class HomeController < ApplicationController
  def news
    @news_content = NewsParsing.new.parse
  end
end
