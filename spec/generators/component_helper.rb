module Generator
  module Component
    COMPONENTS = [
      "room objs",
      "room players",
    ]

    TAGS = [
      "compDef",
      "component",
    ]
    
    def self.simple(tag, type, exists)
      [%{<#{tag} id='#{type}'>
        You also see a #{exists}.
        </#{tag}>}]
    end

    def self.complex(tag, type, exists)
      [%{<#{tag} id='#{type}'>},
       %{You also see a #{exists}.},
       %{</#{tag}>}]
    end

    def self.generate
      exists = Exist.random_list
      type   = COMPONENTS.sample
      tag    = TAGS.sample
      chunks = send([:simple, :complex].sample, tag, type, exists.string)

      OpenStruct.new(
        chunks: chunks, 
        type: type, 
        exists: exists,
        tag: tag,
      )
    end
  end

end