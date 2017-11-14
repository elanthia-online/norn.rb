require "norn/script/downstream"

class Script
  ##
  ## dynamically generates
  ## the context of a Script
  ## execution anything here
  ## will exist on the top-level
  ## of the Script runtime
  ##
  class Context
     def self.inject(*objs)
      objs.each do |obj|
        const = if obj.is_a?(Class) or obj.is_a?(Module)
          obj.name.split("::").last.to_sym
        else
          obj.class.name.split("::").last.to_sym
        end
        self.const_set(const, obj)
      end
      self
    end

    def self.of(script, args = [])
      ctx = Class.new(Context)
      ctx.const_set(:Script, script)
      ctx.const_set(:Game, script.game)
      ctx.const_set(:World, script.game.world)
      ctx.const_set(:ARGV, args)
      ctx.inject *script.game.world.context
      ctx
    end

    def self.keepalive!
      loop do sleep(10) end
    end
  end
end