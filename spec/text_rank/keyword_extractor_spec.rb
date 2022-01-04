require 'spec_helper'

describe TextRank::KeywordExtractor do
  let(:custom_rank_filter_class) do
    Class.new do
      def filter!(ranks, **)
        ranks.merge!('Extra' => 1.0)
      end
    end
  end

  it 'extracts with Whitespace only' do
    ranks = TextRank::KeywordExtractor.new.extract(<<~TEST)
      In a castle of Westphalia, belonging to the Baron of Thunder-ten-Tronckh, lived
      a youth, whom nature had endowed with the most gentle manners. His countenance
      was a true picture of his soul. He combined a true judgment with simplicity of
      spirit, which was the reason, I apprehend, of his being called Candide. The old
      servants of the family suspected him to have been the son of the Baron's
      sister, by a good, honest gentleman of the neighborhood, whom that young lady
      would never marry because he had been able to prove only seventy-one
      quarterings, the rest of his genealogical tree having been lost through the
      injuries of time.
    TEST
    {
      # Exact values come from computing the eigenvector.
      # We expect to get close to this (but not exact)
      'of'                  => 0.07842971759106117,
      'the'                 => 0.0708332032114509,
      'a'                   => 0.04047172804720519,
      'been'                => 0.02586978530589166,
      'to'                  => 0.025487211020915446,
      'his'                 => 0.02546675220639665,
      'whom'                => 0.0185229930628293,
      'had'                 => 0.018388785274819852,
      'was'                 => 0.01762686387864202,
      'with'                => 0.017567034580877678,
      'true'                => 0.01724351699286949,
      'Baron'               => 0.01683392805266423,
      'would'               => 0.011608959819597323,
      'never'               => 0.011599384517407234,
      'lady'                => 0.011433549974862385,
      'marry'               => 0.011398573206194803,
      'young'               => 0.011170043121385385,
      'because'             => 0.011056316093109676,
      'that'                => 0.010683757938453659,
      'he'                  => 0.010640445023621386,
      'Candide'             => 0.010626165542630543,
      'The'                 => 0.010585532741276625,
      'called'              => 0.010399894432185298,
      'manners'             => 0.010385050004722132,
      'His'                 => 0.010355420332836544,
      'old'                 => 0.010319074120919265,
      'gentle'              => 0.01028520518328394,
      'only'                => 0.01012906333046103,
      'being'               => 0.010070153680553714,
      'seventy-one'         => 0.010069379436281627,
      'countenance'         => 0.010064971868873882,
      'prove'               => 0.010016542295357905,
      'most'                => 0.00999171434556221,
      'servants'            => 0.009944247202504641,
      'having'              => 0.009924625493087402,
      'tree'                => 0.009884596034858075,
      'by'                  => 0.009867198519445222,
      'nature'              => 0.009842787194488889,
      'good'                => 0.009837142656336242,
      'quarterings'         => 0.009821586959194105,
      'sister'              => 0.00981431890554646,
      'lost'                => 0.009802608563380439,
      'able'                => 0.009773817939438587,
      'honest'              => 0.009771087139076302,
      'youth'               => 0.009768687741041986,
      'neighborhood'        => 0.009754710768420471,
      'genealogical'        => 0.009702128570658577,
      'He'                  => 0.009700997776421532,
      'endowed'             => 0.009700962222503013,
      'suspected'           => 0.009700053254310906,
      'combined'            => 0.009688506107135248,
      'him'                 => 0.009681425592668713,
      'through'             => 0.00962493773125193,
      'soul'                => 0.009611607723303281,
      'I'                   => 0.0095985755197566,
      'gentleman'           => 0.009579524631903976,
      'family'              => 0.009561728940263059,
      's'                   => 0.009550178575262974,
      'apprehend'           => 0.009548573965412605,
      'reason'              => 0.009546665383104919,
      'lived'               => 0.0095425302142448,
      'which'               => 0.009541290019172559,
      'simplicity'          => 0.009467005163688452,
      'spirit'              => 0.009464253083328315,
      'judgment'            => 0.009457539626784162,
      'have'                => 0.009440922774045069,
      'Westphalia'          => 0.009412725731009899,
      'belonging'           => 0.009396606730389532,
      'Thunder-ten-Tronckh' => 0.009380286017121266,
      'rest'                => 0.009346372311594176,
      'picture'             => 0.00922337103610832,
      'son'                 => 0.00900671709032691,
      'castle'              => 0.008938183092707686,
      'injuries'            => 0.008864010830003963,
      'In'                  => 0.005699214155899267,
      'time'                => 0.00558497477759928,
    }.each do |k, v|
      expect(ranks[k]).to be_within(0.0001).of(v)
    end
  end

  it 'extracts from array of text' do
    ranks = TextRank::KeywordExtractor.new.extract([<<~TEST1, <<~TEST2, <<~TEST3])
      In a castle of Westphalia, belonging to the Baron of Thunder-ten-Tronckh, lived
      a youth, whom nature had endowed with the most gentle manners.
    TEST1
      His countenance was a true picture of his soul. He combined a true judgment
      with simplicity of spirit, which was the reason, I apprehend, of his being
      called Candide.
    TEST2
      The old servants of the family suspected him to have been the son of the
      Baron's sister, by a good, honest gentleman of the neighborhood, whom that
      young lady would never marry because he had been able to prove only seventy-one
      quarterings, the rest of his genealogical tree having been lost through the
      injuries of time.
    TEST3
    # These numbers should be slightly different than if we concatenated the strings
    # together because we will avoid building graph edges between the boundary tokens
    # (those tokens at the beginning or end of each text in the array).
    # We expect to get close to this (but not exact)
    {
      'of'    => 0.08111182819064046,
      'the'   => 0.07321447571708903,
      'a'     => 0.04162826286773359,
      'his'   => 0.026669570973517784,
      'been'  => 0.02628220013248464,
      'to'    => 0.02589186762286176,
      'whom'  => 0.01884269632501968,
      'had'   => 0.018692069918838462,
      'with'  => 0.01818822350109298,
      'true'  => 0.01777124221769915,
      'was'   => 0.01771751823245395,
      'Baron' => 0.017189650358858617,
      # Testing the first 12 is sufficient for this spec
    }.each do |k, v|
      expect(ranks[k]).to be_within(0.0001).of(v)
    end
  end

  it 'advanced tokenizer' do
    extractor = TextRank::KeywordExtractor.advanced
    tokens = extractor.tokenize(<<~TEST)
      <h1>In a castle of Westphalia</h1> belonging to the Baron of Thunder-ten-Tronckh, lived happily
      a youth, whom nature had endowed with the most gentle manners. His countenance
      was a true picture of his soul. He combined a true judgment with simplicity of
      spirit, which was the reason, I apprehend, of his being called Candide at candide@gmail.com. The old
      servants of the family suspected him to have been the son of the Baron's
      sister, by a good, honest gentleman <strong>of</strong> the neighborhood, whom that young lady
      would never marry because he'd been able to prove only seventy-one
      quarterings, the rest of his genealogical tree having been lost through the
      injuries of time. &copy;
    TEST
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

  specify 'customize filters' do
    extractor = TextRank::KeywordExtractor.new
    extractor.graph_strategy = TextRank::GraphStrategy::Coocurrence.new(ngram_size: 2)
    extractor.add_char_filter :StripPossessive
    extractor.add_char_filter :StripHtml, before: :StripPossessive
    extractor.add_tokenizer :Punctuation
    extractor.add_token_filter :MinLength
    extractor.add_token_filter :Stopwords, at: 0
    extractor.add_rank_filter(custom_rank_filter_class.new)
    expect(extractor.extract('Apple orange&apos;s <h1>a Grape</h1>').keys).to match_array(%w[Apple orange Grape Extra])
  end
end
