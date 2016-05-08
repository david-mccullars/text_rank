###About

This gem provides an implementation of the [TextRank](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0ahUKEwjK9tfHxcvMAhVOzGMKHdaQBeEQFggdMAA&url=https%3A%2F%2Fweb.eecs.umich.edu%2F~mihalcea%2Fpapers%2Fmihalcea.emnlp04.pdf&usg=AFQjCNHL5SGlxLy4qmEg1yexaKGZK_Q7IA): an unsupervised keyword extraction algorithm based on [PageRank](http://ilpubs.stanford.edu:8090/422/1/1999-66.pdf).

###Install

```
gem install text_rank
```

###Usage

```ruby
text = <<-END
In a castle of Westphalia, belonging to the Baron of Thunder-ten-Tronckh, lived
a youth, whom nature had endowed with the most gentle manners. His countenance
was a true picture of his soul. He combined a true judgment with simplicity of
spirit, which was the reason, I apprehend, of his being called Candide. The old
servants of the family suspected him to have been the son of the Baron’s
sister, by a good, honest gentleman of the neighborhood, whom that young lady
would never marry because he had been able to prove only seventy-one
quarterings, the rest of his genealogical tree having been lost through the
injuries of time.
END

keywords = TextRank::KeywordExtractor.new
keywords.extract(text)
```

> Reference: R. Mihalcea and P. Tarau, “TextRank: Bringing Order into Texts,” in Proceedings of EMNLP 2004. Association for Computational Linguistics, 2004, pp. 404–411.

> Reference: Brin, S.; Page, L. (1998). "The anatomy of a large-scale hypertextual Web search engine". Computer Networks and ISDN Systems 30: 107–117.
