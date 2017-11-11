module Norn
  class Parser
    ##
    ## normalizes GS tags to true HTML-style tags
    ##
    module Normalizer
      OPEN_STREAM  = %r{<pushStream id=(?:'|")(?<type>\w+)(?:'|")/>}
      CLOSE_STREAM = %r{<popStream id=(?:'|")(?<type>\w+)(?:'|")/>}
      OPEN_STYLE   = %r{<style id=(?:'|")(?<type>\w+)(?:'|") />}
      ##
      ## fix GS tags so that Oga
      ## can reliably parse them
      ##
      def self.apply(packet)
        packet.gsub!(%{<pushBold/>}, %{<monster>})
        packet.gsub!(%{<popBold/>},  %{</monster>})
        ## normalize stream XML
        packet.gsub!(OPEN_STREAM)     do %{<stream id="#{$~[:type]}">}  end
        packet.gsub!(CLOSE_STREAM)    do %{</stream>} end
        packet.gsub!(%{<popStream/>}) do %{</stream>} end
        ## normalize style XML
        packet.gsub!(%{<style id=""/>}, %{</style>})
        packet.gsub!(OPEN_STYLE) do %{<style id="#{$~[:type]}">} end
        return packet
      end
    end
  end
end