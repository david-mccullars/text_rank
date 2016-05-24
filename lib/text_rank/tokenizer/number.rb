#encoding: UTF-8
module TextRank
  module Tokenizer

    ##
    # A tokenizer regex that preserves (optionally formatted) numbers as a single token.
    ##
    Number = %r{
      (
        [1-9]\d{3,}       # 453231162
        (?:\.\d+)?        # 453231162.17

        |

        [1-9]\d{0,2}      # 453
        (?:,\d{3})*       # 453,231,162
        (?:\.\d+)?        # 453,231,162.17

        |

        0                 # 0
        (?:\.\d+)?        # 0.17

        |

        (?:\.\d+)         # .17
      )
    }x

  end
end
