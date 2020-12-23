# frozen_string_literal: true

# Handle routing request for Home
class HomeController < ApplicationController
  def news
    binding.pry
    @news_content = NewsParsing.new.parse
  end
end
