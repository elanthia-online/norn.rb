module Parser
  class State

    attr_accessor :mode, :open_tags

    def initialize
      @open_tags = []
    end

    def open(tag)
      @open_tags << tag.downcase.to_sym
    end

    def close(tag)
      
    end

    def mode(m)

    end
  end
end