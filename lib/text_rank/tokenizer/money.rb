module TextRank
  module Tokenizer

    CURRENCY_SYMBOLS = '[' + [
      "\u00a4", # Generic Currency Symbol
      "\u0024", # Dollar Sign
      "\u00a2", # Cent Sign
      "\u00a3", # Pound Sterling
      "\u00a5", # Yen Symbol
      "\u20a3", # Franc Sign
      "\u20a4", # Lira Symbol
      "\u20a7", # Peseta Sign
      "\u20ac", # Euro Symbol
      "\u20B9", # Rupee
      "\u20a9", # Won Sign
      "\u20b4", # Hryvnia Sign
      "\u20af", # Drachma Sign
      "\u20ae", # Tugrik Sign
      "\u20b0", # German Penny Sign
      "\u20b2", # Guarani Sign
      "\u20b1", # Peso Sign
      "\u20b3", # Austral Sign
      "\u20b5", # Cedi Sign
      "\u20ad", # Kip Sign
      "\u20aa", # New Sheqel Sign
      "\u20ab", # Dong Sign
      "\u0025", # Percent
      "\u2030", # Per Million
    ].join + ']'
    private_constant :CURRENCY_SYMBOLS # Do not expose this to avoid confusion

    ##
    # A tokenizer regex that preserves money or formatted numbers as a single token. This
    # currently supports 24 different currency symbols:
    #
    # rubocop:disable Style/AsciiComments
    #
    # * ¤
    # * $
    # * ¢
    # * £
    # * ¥
    # * ₣
    # * ₤
    # * ₧
    # * €
    # * ₹
    # * ₩
    # * ₴
    # * ₯
    # * ₮
    # * ₰
    # * ₲
    # * ₱
    # * ₳
    # * ₵
    # * ₭
    # * ₪
    # * ₫
    # * %
    # * ‰

    # rubocop:enable Style/AsciiComments
    #
    # It also supports two alternative formats for negatives as well as optional three digit comma
    # separation and optional decimals.
    ##
    # rubocop:disable Naming/ConstantName
    Money = /
      (
        #{CURRENCY_SYMBOLS} -? #{Number}       # $-45,231.21
        |
        -? #{CURRENCY_SYMBOLS} #{Number}       # -$45,231.21
        |
        \( #{CURRENCY_SYMBOLS} #{Number} \)    # ($45,231.21)
      )
    /x
    # rubocop:enable Naming/ConstantName

  end
end
