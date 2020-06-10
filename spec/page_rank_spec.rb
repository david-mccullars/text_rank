require 'spec_helper'

describe PageRank do
  %w[dense sparse].each do |strategy|
    specify "calculate with #{strategy} matrix (node size 5)" do
      ranks = subject.calculate(strategy: strategy, damping: 0.8, tolerance: 0.0000001) do
        add('A', 'B')
        add('A', 'C')
        add('A', 'D')
        add('B', 'C')
        add('B', 'D')
        add('C', 'A')
        add('D', 'A')
        add('D', 'C')
        add('D', 'E')
      end
      expect(ranks.keys).to eq(%w[A C D B E])
      {
        # eigenvector of matrix:
        # 1/25  1/25  21/25 23/75 1/5
        # 23/75 1/25  1/25  1/25  1/5
        # 23/75 22/50 1/25  23/75 1/5
        # 23/75 22/50 1/25  1/25  1/5
        # 1/25  1/25  1/25  23/75 1/5
        'A' => 0.307717930129122,
        'B' => 0.13960460058389013,
        'C' => 0.2475654917020985,
        'D' => 0.19544644081744617,
        'E' => 0.10966553676744323,
      }.each do |k, v|
        expect(ranks[k]).to be_within(0.0000001).of(v)
      end
    end

    specify "calculate with weighted #{strategy} matrix (node size 3)" do
      ranks = subject.calculate(strategy: strategy, damping: 0.85, tolerance: 0.00001) do
        add('frank', 'ann',  weight: 1.0)
        add('frank', 'june', weight: 0.5)
        add('june',  'ann',  weight: 2.0)
      end
      expect(ranks.keys).to eq(%w[ann june frank])
      {
        # eigenvector of matrix:
        # 1/20  1/20 1/3
        # 1/3   1/20 1/3
        # 37/60 9/10 1/3
        'frank' => 0.2023950075898128,
        'june'  => 0.2597402597402597,
        'ann'   => 0.5378647326699275,
      }.each do |k, v|
        expect(ranks[k]).to be_within(0.00001).of(v)
      end
    end

    specify "calculate with repeated links #{strategy} matrix (node size 3)" do
      ranks = subject.calculate(strategy: strategy, damping: 0.85, tolerance: 0.00001) do
        add('A', 'B', weight: 300.0)
        add('A', 'B', weight: 100.0)
        add('A', 'B', weight: 100.0)
        add('A', 'C', weight: 350.0)
        add('B', 'C', weight: 400.0)
        add('B', 'A', weight: 420.0)
        add('C', 'A', weight: 360.0)
        add('C', 'B', weight: 370.0)
      end
      expect(ranks.keys).to eq(%w[B A C])
      {
        # eigenvector of matrix:
        'A' => 0.3346160795461795,
        'B' => 0.3522241378813615,
        'C' => 0.313159782572459,
      }.each do |k, v|
        expect(ranks[k]).to be_within(0.00001).of(v)
      end
    end
  end

  context 'not implemented errors' do
    subject { PageRank::Base.new }

    specify '#add' do
      expect { subject.add('A', 'B') }.to raise_error(NotImplementedError)
    end

    specify '#node_count' do
      expect { subject.send(:node_count) }.to raise_error(NotImplementedError)
    end

    specify '#initial_ranks' do
      expect { subject.send(:initial_ranks) }.to raise_error(NotImplementedError)
    end

    specify '#sort_ranks' do
      expect { subject.send(:sort_ranks, nil) }.to raise_error(NotImplementedError)
    end

    specify '#calculate_step' do
      expect { subject.send(:calculate_step, nil) }.to raise_error(NotImplementedError)
    end
  end
end
