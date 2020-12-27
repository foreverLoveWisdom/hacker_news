# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/lib/story_parsing'

describe StoryParsing do
  context 'when initializes successfully' do
    it 'requires 2 arguments' do
      url = 'https://dtinth.github.io/comic-mono-font'
      image = 'https://repository-images.githubusercontent.com/164606802/cd83d680-894c-11e9-83f7-c353c70df1cb'
      story = described_class.new(url, image)
      expect(story.url).to eq(url)
    end
  end
end
