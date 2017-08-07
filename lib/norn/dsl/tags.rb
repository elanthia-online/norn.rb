module Norn
  module DSL
    module Tags
      Bold = %r{
        <(|\/)(pushBold|popBold|b)(|\/)>
      }x

      Exist = %r{
        <a
        \s*
        exist="(?<id>[\-\d]+)"
        \s*
        noun="(?<noun>[a-zA-Z\-']+)">
        (?<desc>.*?)
        <\/a>
      }x

      ExistWithStatus = %r{
        <a\s*exist="(?<id>[\-\d]+)"\s*noun="(?<noun>[a-zA-Z\-']+)">
        (?<desc>[a-zA-Z\s]+)
        <\/a>
        \s*
        \((?<status>[a-zA-Z\s,]+)\)($|,|\s*and)
      }x

      ComponentOpen = %r{
        <(component|compDef)
        \s*
        id=
        (?:'|")
        (?<type>[a-z\s]+)
        (?:'|")
        \s*
        >
      }x
      ComponentClose = %r{
        <\/
        (component|compDef)
        >
      }x

      Status = %r{
        <indicator
        \s*
        id=(?:"|')Icon(?<type>.*?)(?:"|')
        \s*
        visible=(?:"|')(?<content>y|n)(?:"|')
        \s*\/>
      }x

      StreamOpen = %r{
        <pushStream
        \s*
        id=(?:"|')(?<type>.*?)(?:"|')
        />
      }x
      StreamClose = %r{
        <popStream(?<attrs>.*?)\/>
      }x

      HandOpen = %r{
        <(?<type>left|right)(|\s*exist="(?<id>.*?)"\s*noun="(?<noun>.*?)")>
      }x
      HandClose = %r{
        <\/(left|right)>
      }x

      D = %r{
        <d>(?<content>.*?)</d>
      }x

      RoundTime = %r{
        <(?<type>castTime|roundTime)
        \s
        value=("|')(?<content>\d+)("|')\/>
      }x

      Prompt = %r{
        <(?<type>prompt)
        \s
        time=("|')(?<content>\d+)("|')>
      }x

      StyleOpen  = %r{<style\sid=("|')(?<type>[a-zA-Z]+)("|')\/>}x
      StyleContent = %r{
        <style\sid=("|')(?<type>[a-zA-Z]+)("|')\s*\/>(?<content>.*?)<style\sid=""\s*\/>
      }x
      StyleClose = %r{
        <style
        \s*
        id=('|")('|")
        \s*\/>
      }x
    end
  end
end