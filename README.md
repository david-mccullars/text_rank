# TextRank

* README:         https://github.com/david-mccullars/text_rank
* Documentation:  http://www.rubydoc.info/github/david-mccullars/text_rank
* Bug Reports:    https://github.com/david-mccullars/text_rank/issues


## Status

[![Gem Version](https://badge.fury.io/rb/text_rank.svg)](https://badge.fury.io/rb/text_rank)
[![Build Status](https://github.com/david-mccullars/text_rank/workflows/CI/badge.svg)](https://github.com/david-mccullars/text_rank/actions?workflow=CI)
[![Code Climate](https://codeclimate.com/github/david-mccullars/text_rank/badges/gpa.svg)](https://codeclimate.com/github/david-mccullars/text_rank)
[![Test Coverage](https://codeclimate.com/github/david-mccullars/text_rank/badges/coverage.svg)](https://codeclimate.com/github/david-mccullars/text_rank/coverage)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)


## Description

[TextRank](https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf) is
an unsupervised keyword extraction algorithm based on
[PageRank](http://ilpubs.stanford.edu:8090/422/1/1999-66.pdf).  Other
strategies for keyword extraction generally rely on either statistics (like
inverse document frequency and term frequency) which ignore context, or they
rely on machine learning, requiring a corpus of training data which likely will
not be suitable for all applications.  TextRank is found to produce superior
results in many situations with minimal computational cost.


## Features

* Multiple PageRank implementations to choose one best suited for the performance
needs of your application
* Framework for adding additional PageRank implementations (e.g. a native
implemenation)
* Extensible architecture to customize how text is filtered
* Extensible architecture to customize how text is tokenized
* Extensible architecture to customize how tokens are filtered
* Extensible architecture to customize how keywords ranks are filtered/processed


## Installation

```
gem install text_rank
```

## Requirements

* Ruby 3.0.0 or higher
* [engtagger](https://github.com/yohasebe/engtagger) gem is optional but
required for `TextRank::TokenFilter::PartOfSpeech`
* [nokogiri](https://github.com/sparklemotion/nokogiri) gem is optional but
required for `TextRank::CharFilter::StripHtml`

## Usage

**TextRank**

```ruby
require 'text_rank'

text = <<-END
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

# Default, basic keyword extraction.  Try this first:
keywords = TextRank.extract_keywords(text)

# Keyword extraction with all of the bells and whistles:
keywords = TextRank.extract_keywords_advanced(text)

# Fully customized extraction:
extractor = TextRank::KeywordExtractor.new(
  strategy:   :sparse,  # Specify PageRank strategy (dense or sparse)
  damping:    0.85,     # The probability of following the graph vs. randomly choosing a new node
  tolerance:  0.0001,   # The desired accuracy of the results
  char_filters: [...],  # A list of filters to be applied prior to tokenization
  tokenizers: [...],    # A list of tokenizers to perform tokenization
  token_filters: [...], # A list of filters to be applied to each token after tokenization
  graph_strategy: ...,  # A class or strategy instance for producing a graph from tokens
  rank_filters: [...],  # A list of filters to be applied to the keyword ranks after keyword extraction
)

# Add another filter to the end of the char_filter chain
extractor.add_char_filter(:AsciiFolding)

# Add a part of speech filter to the token_filter chain BEFORE the Stopwords filter
pos_filter = TextRank::TokenFilter::PartOfSpeech.new(parts_to_keep: %w[nn])
extractor.add_token_filter(pos_filter, before: :Stopwords)

# Perform the extraction with at most 100 iterations
extractor.extract(text, max_iterations: 100)
```

**PageRank**

It is also possible to use this gem for PageRank only.

```ruby
require 'page_rank'

PageRank.calculate(strategy: :sparse, damping: 0.8, tolerance: 0.00001) do
  add('node_a', 'node_b', weight: 3.2)
  add('node_b', 'node_d', weight: 2.1)
  add('node_b', 'node_e', weight: 4.7)
  add('node_e', 'node_a', weight: 1.3)
end
```

There are currently two pure Ruby implementations of PageRank:

1. **sparse**: A sparsely-stored strategy which performs multiplication proportional
to the number of edges in the graph.  For graphs with a very low node-to-edge
ratio, this will perform better in a pure Ruby setting.  It is recommended to
use this strategy until such a time as there are native implementations.
2. **dense**: A densely-stored matrix strategy which performs up to `max_iterations`
matrix multiplications or until the tolerance is reached.  This is more of a
canonical implementation and is fine for small or dense graphs, but it is not
advised for large, sparse graphs as Ruby is not fast when it comes to matrix
multiplication.  Each iteration is O(N^3) where N is the number of graph nodes.

## License

MIT. See the `LICENSE` file.


## References

> R. Mihalcea and P. Tarau, “TextRank: Bringing Order into Texts,” in Proceedings of EMNLP 2004. Association for Computational Linguistics, 2004, pp. 404–411.

> Brin, S.; Page, L. (1998). "The anatomy of a large-scale hypertextual Web search engine". Computer Networks and ISDN Systems 30: 107–117.
