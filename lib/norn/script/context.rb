require "norn/script/downstream/receiver"
require "norn/script/downstream/mutator"
require "norn/script/downstream/suppressor"

class Script
  ##
  ## dynamically generates
  ## the context of a Script
  ## execution anything here
  ## will exist on the top-level
  ## of the Script runtime
  ##
  class Context
    def self.name_of(obj)
      if obj.is_a?(Class) or obj.is_a?(Module)
        obj.name
      else
        obj.class.name
      end
    end

     def self.inject(*objs)
      objs.each do |prop, obj|
        if name_of(obj).start_with?("Norn::")
          const = name_of(obj).split("::").last.to_sym
          self.const_set(const, obj)
        end
      end
      self
    end

    def self.proxy_classes(ctx, script)
      receiver_proxy = Class.new do
        def self.of(&block)
          Downstream::Receiver.new(
            const_get(:Game).receivers, 
            const_get(:Script), 
            &block)
        end
      end

      mutator_proxy = Class.new do
        def self.of(&block)
          Downstream::Mutator.new(
            const_get(:Game).mutators, 
            const_get(:Script), 
            &block)
        end
      end

      suppressor_proxy = Class.new do
        def self.of(**args)
          Downstream::Suppressor.new(const_get(:Mutator), **args)
        end
      end

      [receiver_proxy, mutator_proxy, suppressor_proxy].each do |proxy|
        proxy.const_set(:Game, script.game)
        proxy.const_set(:Script, script)
      end

      suppressor_proxy.const_set(:Mutator, mutator_proxy)

      ctx.const_set(:Receiver,   receiver_proxy)
      ctx.const_set(:Mutator,    mutator_proxy)
      ctx.const_set(:Suppressor, suppressor_proxy)
    end

    def self.of(script, args = [])
      ctx = Class.new(Context)
      ctx.const_set(:Script, script)
      ctx.const_set(:Commands, script.commands)
      ctx.const_set(:Game, script.game)
      ctx.const_set(:World, script.game.world)
      ctx.const_set(:ARGV, args)
      script.game.world.exports.each do |mod, exports|
        ctx.const_set(mod, exports)
      end
      Context.proxy_classes(ctx, script)
      ctx.inject *script.game.world.context
      ctx
    end

    def self.name
      const_get(:Script).name
    end

    def self.to_s
      "Context::Script::#{name}"
    end

    def self.inspect
      to_s
    end

    def self.put(cmd)
      script = const_get(:Script)
      script.safe_write %{#{script.name}>#{cmd}}
      const_get(:Game).write_game_command cmd
    end
  end
end