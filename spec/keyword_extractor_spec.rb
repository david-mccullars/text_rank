require 'spec_helper'

describe TextRank::KeywordExtractor do

  it 'has a version number' do
    expect(TextRank::VERSION).not_to be nil
  end

  it "extracts with Whitespace only" do
    ranks = TextRank::KeywordExtractor.new.extract(<<-END)
In a castle of Westphalia, belonging to the Baron of Thunder-ten-Tronckh, lived
a youth, whom nature had endowed with the most gentle manners. His countenance
was a true picture of his soul. He combined a true judgment with simplicity of
spirit, which was the reason, I apprehend, of his being called Candide. The old
servants of the family suspected him to have been the son of the Baron's
sister, by a good, honest gentleman of the neighborhood, whom that young lady
would never marry because he had been able to prove only seventy-one
quarterings, the rest of his genealogical tree having been lost through the
injuries of time.
    END
    {
      # Exact values come from computing the eigenvector.
      # We expect to get close to this (but not exact)
      "of"                   => 0.07946194617819763,
      "the"                  => 0.0719301908425961,
      "a"                    => 0.04072403984935129,
      "been"                 => 0.026068328713577605,
      "to"                   => 0.025809103912553057,
      "his"                  => 0.025646908134259908,
      "whom"                 => 0.01862900945095089,
      "had"                  => 0.018482663638841313,
      "was"                  => 0.017741276947882592,
      "with"                 => 0.0176802099234457,
      "true"                 => 0.017339067568301503,
      "would"                => 0.011631947692984845,
      "never"                => 0.011621660293960142,
      "lady"                 => 0.011459469677583501,
      "marry"                => 0.011422614190022072,
      "young"                => 0.011201280029968473,
      "because"              => 0.011084773437296965,
      "that"                 => 0.010725287444020246,
      "he"                   => 0.010674830728422166,
      "Candide."             => 0.010671298467194307,
      "The"                  => 0.010634993507532909,
      "called"               => 0.010447666775339077,
      "manners."             => 0.010432881592733742,
      "His"                  => 0.010397763866140844,
      "old"                  => 0.010377052697221854,
      "gentle"               => 0.01033726057672062,
      "only"                 => 0.010196049870911298,
      "seventy-one"          => 0.010138811136454757,
      "being"                => 0.010121807170402255,
      "countenance"          => 0.010107435261839213,
      "prove"                => 0.010083003166592053,
      "most"                 => 0.010052046317450915,
      "servants"             => 0.010012120940507062,
      "having"               => 0.009976198844552414,
      "tree"                 => 0.009937101992179778,
      "quarterings,"         => 0.009896698214339101,
      "nature"               => 0.009888076454161829,
      "good,"                => 0.009877939275869553,
      "by"                   => 0.009873021687235035,
      "lost"                 => 0.009865890557539041,
      "able"                 => 0.009835010878599969,
      "youth,"               => 0.009834129074294467,
      "honest"               => 0.009824061950420536,
      "neighborhood,"        => 0.009820335612200798,
      "sister,"              => 0.00981279178433966,
      "suspected"            => 0.009778205604424328,
      "him"                  => 0.009758217737837586,
      "genealogical"         => 0.009757633154931037,
      "endowed"              => 0.009753388337368895,
      "He"                   => 0.00974755467134323,
      "combined"             => 0.009731339961580899,
      "through"              => 0.009698064450488266,
      "lived"                => 0.009693719847331618,
      "I"                    => 0.009667230170328573,
      "soul."                => 0.009662015987585778,
      "gentleman"            => 0.00964459450393131,
      "family"               => 0.009643363998877401,
      "reason,"              => 0.00961933577279129,
      "apprehend,"           => 0.009617962696970636,
      "which"                => 0.009607048137389442,
      "Baron's"              => 0.0095949161420305,
      "Thunder-ten-Tronckh," => 0.009567895765958238,
      "belonging"            => 0.009547032398656695,
      "spirit,"              => 0.00953153264308638,
      "simplicity"           => 0.009526827828815157,
      "have"                 => 0.009523853692170948,
      "Westphalia,"          => 0.009506623183000357,
      "judgment"             => 0.009506266117442944,
      "rest"                 => 0.009425016883202363,
      "Baron"                => 0.009342505232793404,
      "picture"              => 0.009280335470026149,
      "son"                  => 0.009179562880668683,
      "castle"               => 0.009004112720353879,
      "injuries"             => 0.008940877116459089,
      "In"                   => 0.005728037135533031,
      "time."                => 0.005628873429632883,
    }.each do |k, v|
      expect(ranks[k]).to be_within(0.0001).of(v)
    end
  end

  it "advanced tokenizer" do
    extractor = TextRank::KeywordExtractor.advanced
    tokens = extractor.tokenize(<<-END)
<h1>In a castle of Westphalia</h1> belonging to the Baron of Thunder-ten-Tronckh, lived happily
a youth, whom nature had endowed with the most gentle manners. His countenance
was a true picture of his soul. He combined a true judgment with simplicity of
spirit, which was the reason, I apprehend, of his being called Candide at candide@gmail.com. The old
servants of the family suspected him to have been the son of the Baron's
sister, by a good, honest gentleman <strong>of</strong> the neighborhood, whom that young lady
would never marry because he'd been able to prove only seventy-one
quarterings, the rest of his genealogical tree having been lost through the
injuries of time. &copy;
    END
    expect(tokens).to eq(%w[
      castle
      westphalia
      belonging
      baron
      thunder-ten-tronckh
      lived
      youth
      nature
      endowed
      gentle
      manners
      countenance
      true
      picture
      soul
      combined
      true
      judgment
      simplicity
      spirit
      reason
      apprehend
      called
      candide
      old
      servants
      family
      suspected
      son
      baron
      sister
      good
      honest
      gentleman
      neighborhood
      young
      lady
      marry
      able
      prove
      seventy-one
      quarterings
      rest
      genealogical
      tree
      having
      lost
      injuries
      time
    ])
  end

  class CustomRankFilter
    def filter!(ranks, **)
      ranks.merge!('Extra' => 1.0)
    end
  end

  specify 'customize filters' do
    extractor = TextRank::KeywordExtractor.new
    extractor.tokenizer = :Whitespace
    extractor.graph_strategy = TextRank::GraphStrategy::Coocurrence.new(ngram_size: 2)
    extractor.add_char_filter :StripPossessive
    extractor.add_char_filter :StripHtml, before: :StripPossessive
    extractor.add_token_filter :MinLength
    extractor.add_token_filter :Stopwords, at: 0
    extractor.add_rank_filter(CustomRankFilter.new)
    expect(extractor.extract("Apple orange&apos;s <h1>a Grape</h1>").keys).to match_array(%w[Apple orange Grape Extra])
  end

  specify 'TextRank.extract_keywords' do
    expect(TextRank.extract_keywords('The man went to town and found the town empty').keys).to eq(%w[went town man])
  end

  specify 'TextRank.extract_keywords_advanced' do
    expect(TextRank.extract_keywords_advanced("The <b>man</b> went to the abandoned town &amp; found the town wasn't abandoned").keys).to eq(['abandoned town', 'went', 'man'])
  end

end
