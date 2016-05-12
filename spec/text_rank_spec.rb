require 'spec_helper'

describe TextRank do

  it 'has a version number' do
    expect(TextRank::VERSION).not_to be nil
  end

  specify 'TextRank.extract_keywords' do
    expect(TextRank.extract_keywords('The man went to town and found the town empty').keys).to eq(%w[went town man])
  end

  specify 'TextRank.extract_keywords_advanced' do
    expect(TextRank.extract_keywords_advanced("The <b>man</b> went to the abandoned town &amp; found the town wasn't abandoned").keys).to eq(['abandoned town', 'went', 'man'])
  end

end
