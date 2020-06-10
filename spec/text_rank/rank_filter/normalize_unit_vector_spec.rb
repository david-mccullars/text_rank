require 'spec_helper'

describe TextRank::RankFilter::NormalizeUnitVector do
  it 'normalize to a unit vector' do
    collapsed = TextRank::RankFilter::NormalizeUnitVector.new.filter!(
      {
        'candide'   => 0.3092173387079902,
        'beautiful' => 0.5766156537926637,
        'little'    => 0.5563730204097321,
        'horses'    => 0.029519461112416212,
        'drag'      => 0.18104336291582246,
        'country'   => 0.07470270548260227,
        'mead'      => 0.8510949293418663,
        'cries'     => 0.0013624894517173525,
      },
    )
    expect(collapsed.values.map { |v| v * v }.reduce(:+)).to be_within(0.00001).of(1.0)
  end
end
