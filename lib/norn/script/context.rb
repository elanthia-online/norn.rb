class Script
  ##
  ## dynamically generates
  ## the context of a Script
  ## execution
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

    def self.of(script)
      ctx = Class.new(Context)
      ctx.const_set(:Script, script)
      ctx.inject *script.game.world.context
      ctx
    end
  end
end