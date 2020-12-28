# frozen_string_literal: true

# require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../../app/lib/story_parsing'

describe StoryParsing do
  let(:url) { 'https://dtinth.github.io/comic-mono-font' }
  let(:image) { 'https://repository-images.githubusercontent.com/164606802/cd83d680-894c-11e9-83f7-c353c70df1cb' }

  context 'when initializes successfully' do
    it 'requires 2 arguments' do
      story = described_class.new(url, image)
      expect(story.class).to eq(described_class)
    end
  end

  context 'when initializes unsuccessfully' do
    it 'throws argument error' do
      expect { described_class.new(url) }.to raise_error(ArgumentError)
    end
  end

  describe '#parse' do
    subject(:story) { described_class.new(url, image) }

    context 'when parse successfully' do
      let(:story_response) { instance_double(HTTParty::Response, body: story_response_body, code: 200) }
      let(:story_response_body) { '<p>Generates the Comic Mono font files based on Comic Shanns font.</p>' }

      before do
        allow(HTTParty).to receive(:get).and_return(story_response)
        story.parse
      end

      it 'returns content' do
        expect(story.content).to include('Generates the Comic Mono font files based on Comic Shanns font.')
      end
    end

    context 'when parse unsuccessfully' do
      let(:invalid_story_response) { instance_double(HTTParty::Response, code: 400) }

      before do
        allow(HTTParty).to receive(:get).and_return(invalid_story_response)
        allow(Rails.logger).to receive(:debug)
        story.parse
      end

      it 'returns error' do
        expect(story.error).to eq(true)
      end

      it 'logs debug' do
        error_message = 'Rescued Exception:'\
                        ' #<StandardError: Failed to fetch page content.'\
                        " Response code: #{invalid_story_response.code}>"
        expect(Rails.logger).to have_received(:debug).with(error_message)
      end
    end
  end
end
