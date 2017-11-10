class Script
  ##
  ## dynamically generates
  ## the context of a Script
  ## execution
  ##
  class Context
     def self.inject(obj, namespace = nil)
      const = namespace

      if const.nil?
        if obj.is_a?(Class) or obj.is_a?(Module)
          const = obj.name.split("::").last.to_sym
        else
          const = obj.class.name.split("::").last.to_sym
        end
      end
      self.const_set(const, obj)
      self
    end

    def self.of(script)
      ctx = Class.new(Context)
      ctx.inject(script, :Context)
      ctx.inject(script.game.world)
      ctx.inject(script.game.world.room)
      ctx.inject(script.game.world.stance)
      ctx.inject(script.game.world.status)
      ctx.inject(script.game.world.containers)
      ctx.inject(script.game.world.char)
      ctx
    end
  end
end