module Generator
  module Stream
    TYPES = [
      :bounty,
      :inv,
      :thoughts,
    ]

    def self.stringify(thing)
      if thing.respond_to?(:string) 
        thing.string
      else
        thing.to_s
      end
    end

    def self.tag(type, contents)
      OpenStruct.new(
        type: type,
        contents: contents,
        chunks: close([
          %{<pushStream id='#{type.to_s}'/>}, 
          stringify(contents),
        ])
      )
    end

    def self.close(*parts)
      chunks = parts.concat([%{<popStream/>}]).flatten
      if rand > 0.66
        [chunks.join("")]
      else
        chunks
      end
    end
    
    def self.bounty
      tag :bounty, Bounty.generate
    end

    def self.inv
      tag :inv, Exist.random_list
    end

    def self.thoughts
      tag :thoughts, %{You hear the thoughts of #{String.random(5,10)} echo in your mind.}
    end

    def self.generate
      send TYPES.sample
    end
  end
end