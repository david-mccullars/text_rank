require 'spec_helper'

describe 'TextRank::Tokenizer::Number' do
  %w[
    453231162
    453231162.0
    4
    453
    453,231,162
    453,231,162.17981
    0
    0.17412
    .1
  ].each do |s|
    it "should accept #{s.inspect}" do
      expect(s.scan(TextRank::Tokenizer::Number)).to eq([[s]])
    end
  end

  %w[
    4532311a62
    453231162.
    01
    .
    1,1234
  ].each do |s|
    it "should NOT accept #{s.inspect}" do
      expect(s.scan(TextRank::Tokenizer::Number)).to_not eq([[s]])
    end
  end
end
