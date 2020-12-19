# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  describe 'GET /news' do
    it 'returns http success' do
      get '/home/news'
      expect(response).to have_http_status(:success)
    end
  end
end
