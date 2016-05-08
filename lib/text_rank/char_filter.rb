module TextRank
  ##
  # Character filters pre-process text prior to tokenization.  It is during
  # this phase that the text should be "cleaned up" so that the tokenizer will
  # produce valid tokens.  Character filters should not attempt to remove undesired
  # tokens, however.  That is the job of the token filter.  Examples include
  # converting non-ascii characters to related ascii characters, forcing text to
  # lower case, stripping out HTML, converting English contractions (e.g. "won't")
  # to the non-contracted form ("will not"), and more.
  # 
  # Character filters are applied as a chain, so care should be taken to use them
  # in the desired order.
  ##
  module CharFilter

    autoload :AsciiFolding,     'text_rank/char_filter/ascii_folding'
    autoload :Lowercase,        'text_rank/char_filter/lowercase'
    autoload :StripEmail,       'text_rank/char_filter/strip_email'
    autoload :StripHtml,        'text_rank/char_filter/strip_html'
    autoload :StripPossessive,  'text_rank/char_filter/strip_possessive'
    autoload :UndoContractions, 'text_rank/char_filter/undo_contractions'

  end
end
