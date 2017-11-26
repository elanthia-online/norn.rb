require "norn/script/downstream/receiver"
require "norn/script/downstream/mutator"

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

      [receiver_proxy, mutator_proxy].each do |proxy|
        proxy.const_set(:Game, script.game)
        proxy.const_set(:Script, script)
      end

      ctx.const_set(:Receiver, receiver_proxy)
      ctx.const_set(:Mutator,  mutator_proxy)
    end

    def self.of(script, args = [])
      ctx = Class.new(Context)
      ctx.const_set(:Script, script)
      ctx.const_set(:Game, script.game)
      ctx.const_set(:World, script.game.world)
      ctx.const_set(:ARGV, args)
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

    def self.keepalive!
      loop do sleep() end
    end
  end
end