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

  context 'TextRank.similarity' do
    specify 'no overlap' do
      k1 = %w[town man empty found]
      k2 = %w[general jar ocean sea]
      expect(TextRank.similarity(k1, k2)).to eq(0.0)
    end

    specify 'little overlap' do
      k1 = %w[town man empty found]
      k2 = %w[general ocean found jar]
      expect(TextRank.similarity(k1, k2)).to eq(0.0785251884167666)
    end

    specify 'some overlap' do
      k1 = %w[town man empty found]
      k2 = %w[general empty found jar]
      expect(TextRank.similarity(k1, k2)).to eq(0.24821529740414022)
    end

    specify 'much overlap' do
      k1 = %w[town man empty found]
      k2 = %w[man empty found town]
      expect(TextRank.similarity(k1, k2)).to eq(0.6114679165482296)
    end

    specify 'extreme overlap' do
      k1 = %w[man empty town found]
      k2 = %w[man empty found town]
      expect(TextRank.similarity(k1, k2)).to eq(0.9088350794293929)
    end

    specify 'same' do
      k1 = %w[town man empty found]
      expect(TextRank.similarity(k1, k1)).to eq(1.0)
    end
  end
end
