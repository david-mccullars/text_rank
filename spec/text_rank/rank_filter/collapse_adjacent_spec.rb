require 'spec_helper'

describe TextRank::RankFilter::CollapseAdjacent do
  EXAMPLE_TEXT = <<~TEST
    Candide and his valet had got beyond the barrier, before it was known in the camp that the German Jesuit was dead. The wary Cacambo had taken care to fill his wallet with bread, chocolate, bacon, fruit, and a few bottles of wine. With their Andalusian horses they penetrated into an unknown country, where they perceived no beaten track. At length they came to a beautiful meadow intersected with purling rills. Here our two adventurers fed their horses. Cacambo proposed to his master to take some food, and he set him an example.
    
    "How can you ask me to eat ham," said Candide, "after killing the Baron's son, and being doomed never more to see the beautiful Cunegonde? What will it avail me to spin out my wretched days and drag them far from her in remorse and despair? And what will the Journal of Trevoux say?"
    
    While he was thus lamenting his fate, he went on eating. The sun went down. The two wanderers heard some little cries which seemed to be uttered by women. They did not know whether they were cries of pain or joy; but they started up precipitately with that inquietude and alarm which every little thing inspires in an unknown country. The noise was made by two naked girls, who tripped along the mead, while two monkeys were pursuing them and biting their buttocks. Candide was moved with pity; he had learned to fire a gun in the Bulgarian service, and he was so clever at it, that he could hit a filbert in a hedge without touching a leaf of the tree. He took up his double-barrelled Spanish fusil, let it off, and killed the two monkeys.
  TEST

  it 'should collapse and remove all single tokens when there are more instances of the combo than singletons' do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'candide'   => 0.019419035615479842,
        'beautiful' => 0.015509572886452754,
        'little'    => 0.01495291163079878,
        'horses'    => 0.01486823201620794,
        'drag'      => 0.014657860280239304,
        'country'   => 0.014412569811892607,
        'mead'      => 0.014341784918006825,
        'cries'     => 0.014292943715786686,
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'candide',
                                            'beautiful',
                                            'horses',
                                            'drag',
                                            'little cries', # we collapse 'little cries' because it shows up as a pair more than 'little' or 'cries' as singles
                                            'country',
                                            'mead',
                                          ])
  end

  it 'should collapse and remove all single tokens when there are only instances of the combo' do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'candide'   => 0.019419035615479842,
        'beautiful' => 0.015509572886452754,
        'spin'      => 0.01495291163079878,
        'horses'    => 0.01486823201620794,
        'drag'      => 0.014657860280239304,
        'country'   => 0.014412569811892607,
        'mead'      => 0.014341784918006825,
        'unknown'   => 0.014292943715786686,
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'candide',
                                            'beautiful',
                                            'spin',
                                            'horses',
                                            'drag',
                                            'unknown country', # we collapse 'unknown country' and remove both singles because the two only occur as a pair
                                            'mead',
                                          ])
  end

  it 'should collapse but retain single tokens that occur strictly more often than the combo' do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'candide'   => 0.019419035615479842,
        'two'       => 0.019112569811892607,
        'beautiful' => 0.015509572886452754,
        'spin'      => 0.01495291163079878,
        'horses'    => 0.01486823201620794,
        'drag'      => 0.014657860280239304,
        'monkeys'   => 0.014341784918006825,
        'unknown'   => 0.014292943715786686,
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'candide',
                                            'two',          # we retain 'two' because it occurs more times than 'two monkeys'
                                            'two monkeys',  # we collapse 'two monkeys' & REMOVE 'monkeys' because the latter only ever occurs as the pair
                                            'beautiful',
                                            'spin',
                                            'horses',
                                            'drag',
                                            'unknown',
                                          ])
  end

  it "should collapse even if combo occurrs less often than single tokens as long as it occurrs a 'significant' enough times" do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'cacambo'   => 0.019419035615479842,
        'wanderers' => 0.015509572886452754,
        'he'        => 0.01495291163079878,
        'horses'    => 0.01486823201620794,
        'was'       => 0.014657860280239304,
        'days'      => 0.014341784918006825,
        'unknown'   => 0.014292943715786686,
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'cacambo',
                                            'wanderers',
                                            'he',       # we retain 'he' because it occurs more times than 'he was'
                                            'horses',
                                            'he was',   # we add 'he was' because it occurs at least 30% as often as 'he' & 'was' (which meets our significance threshold)
                                            'was',      # we retain 'was' because it occurs more times than 'he was'
                                            'days',
                                            'unknown',
                                          ])
  end

  it "should NOT collapse a combo when it shows up 'significantly' less than the single tokens" do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'candide'   => 0.019419035615479842,
        'beautiful' => 0.015509572886452754,
        'and'       => 0.01495291163079878,
        'horses'    => 0.01486823201620794,
        'avail'     => 0.014657860280239304,
        'mead'      => 0.014341784918006825,
        'unknown'   => 0.014292943715786686,
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'candide', # we retain 'candide' because it occurs more times than 'and candide'
                                            # we do NOT add 'and candide' even though it appears because it occurs less than 30% of the time of 'and' & 'candide' (which fails to meet the significance threshold)
                                            'beautiful',
                                            'and',    # we retain 'and' because it occurs more times than 'and candide'
                                            'horses',
                                            'avail',
                                            'mead',
                                            'unknown',
                                          ])
  end

  it 'should make multiple passes to collapse until satisfied that the top X have been fully collapsed' do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'candide'   => 0.019419035615479842,
        'beautiful' => 0.015509572886452754,
        'little'    => 0.01495291163079878,
        'two'       => 0.01486823201620794,
        'cries'     => 0.014657860280239304,
        'country'   => 0.014412569811892607,
        'mead'      => 0.014341784918006825,
        'pity'      => 0.014157860930477813,
        'monkeys'   => 0.013157860280239304, # Not in the top 8
        'cunegonde' => 0.007292943715791801, # Not in the top 8
      },
      original_text: EXAMPLE_TEXT,
    )
    expect(collapsed.keys).to match_array([
                                            'candide',
                                            'beautiful',
                                            'two',
                                            'little cries',
                                            'country',
                                            'mead',
                                            'pity',
                                            'two monkeys', # This doesn't get collapsed on the first pass because 'monkeys' isn't in the top 8, but after collapsing 'little cries' it falls into the top 8
                                            'cunegonde', # This does not get collapsed into 'beautiful cunegonde' because 'cunegonde' never falls into the top 8
                                          ])
  end

  it 'non-ASCII tokens that match the scan regex should not cause nil errors' do
    collapsed = TextRank::RankFilter::CollapseAdjacent.new(ranks_to_collapse: 8, max_tokens_to_combine: 3).filter!(
      {
        'product'       => 0.019419035615479842,
        'beautiful'     => 0.015509572886452754,
        'little'        => 0.01495291163079878,
        'horses'        => 0.01486823201620794,
        'drag'          => 0.014657860280239304,
        'country'       => 0.014412569811892607,
        'mead'          => 0.014341784918006825,
        'certification' => 0.014292943715786686,
      },
      original_text: "Product Certiﬁcation #{EXAMPLE_TEXT}",
    )
    expect(collapsed.keys).to match_array([
                                            'product certiﬁcation',
                                            'beautiful',
                                            'little',
                                            'horses',
                                            'drag',
                                            'country',
                                            'mead',
                                            'certification',
                                          ])
  end
end
