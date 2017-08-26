module Norn
  module Parser
    module Tokens
      ## tokens that are imporant to the parser
      OPEN_TAG         = "<"
      CLOSE_TAG        = ">"
      SELF_CLOSING_TAG = "/"
      WHITESPACE       = " "
      ## garbage GS nonsense
      PUSH             = "push"
      POP              = "pop"
      ## garbage tags
      SEP              = "sep"
      MONSTER_BOLD     = "bold"
      NORMAL_BOLD      = "b"
      ## cache size lookup
      POP_LENGTH       = POP.size
      PUSH_LENGTH      = PUSH.size
      ## for peeking ahead in a token stream
      ## to parse metadata that exists after
      ## <a> tag declaration
      STOP_TOKENS      = [",", ".", "\n", "\t", "\r"]
      STOP_WORDS       = ["and"]
    end
  end
end