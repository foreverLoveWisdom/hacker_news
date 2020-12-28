# frozen_string_literal: true

require_relative '../rails_helper'
require_relative '../support/fixture/story_sample_data'
require_relative '../../app/lib/stories_parsing'

describe StoriesParsing do
  subject(:news) { described_class.new }

  let(:url) { 'https://github.com/compumike/hairpin-proxy/issues/5' }
  let(:sample_story_data) do
    {
      title: meta_data.dig('meta', 'title'),
      image: meta_data.dig('meta', 'image'),
      excerpt: "#{meta_data.dig('meta', 'description')}...",
      url: url
    }
  end
  let(:meta_response) { instance_double(HTTParty::Response, body: meta_data, code: 200) }
  let(:meta_data) do
    StorySampleData::META_DATA
  end

  describe '#get_story_urls' do
    it 'returns a list of story urls' do
      story_urls = news.send(:get_story_urls, Nokogiri::HTML(StorySampleData::STORIES_RESPONSE))
      expect(story_urls).to include(url)
    end
  end

  describe '#fetch_meta_info' do
    it 'returns meta data' do
      allow(HTTParty).to receive(:get).and_return(meta_response)
      meta_data_response = news.send(:fetch_meta_info, url)
      expect(meta_data_response.body).to eq(meta_data)
    end
  end

  describe '#generate_story_data' do
    it 'returns story data' do
      story_data = news.send(:generate_story_data, meta_data, url)
      expect(story_data).to eq(sample_story_data)
    end
  end

  describe '#link_unfetchable?' do
    context 'when link is unfetchable' do
      it 'returns false when link from medium' do
        unfetchable = news.send(:link_unfetchable?, 'https://medium.com/swlh/how-to-install-rspec-in-your-ruby-on-rails-backend-e726278e59da')
        expect(unfetchable).to eq(true)
      end

      it 'returns false when link is a HackerNews question' do
        unfetchable = news.send(:link_unfetchable?, 'https://news.ycombinator.com/item?id=25556569')
        expect(unfetchable).to eq(true)
      end
    end

    context 'when link is fetchable' do
      it 'returns true' do
        unfetchable = news.send(:link_unfetchable?, url)
        expect(unfetchable).to eq(false)
      end
    end
  end

  describe '#get_stories_info' do
    let(:story_urls) { [url] }

    before do
      allow(HTTParty).to receive(:get).and_return(meta_data)
    end

    it 'returns stories' do
      news.send(:get_stories_info, story_urls)
      sleep(1)
      expect(news.stories).to include(sample_story_data)
    end
  end
end
