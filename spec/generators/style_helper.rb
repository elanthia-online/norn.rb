module Generator
  module Style
    TYPES = [
      "roomName",
      "roomDesc",
    ]

    TAGS = [
      "style"
    ]
    
    def self.simple(tag, type, contents)
      [%{<#{tag} id="#{type}"/>
        #{contents}
        <#{tag} id=""/>}]
    end

    def self.complex(tag, type, contents)
      simple(tag, (TYPES - [type]).first, String.random(10, 20)) + [%{<#{tag} id="#{type}"/>},
       contents,
       %{<#{tag} id=""/>}]
    end

    def self.generate
      contents = String.random(10, 200)
      type   = TYPES.sample
      tag    = TAGS.sample
      method = [:simple, :complex].sample
      chunks = send(method, tag, type, contents)

      OpenStruct.new(
        way: method,
        string: chunks.join,
        chunks: chunks, 
        type: type, 
        contents: contents,
        tag: tag,
      )
    end
  end

end