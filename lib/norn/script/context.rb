class Script
  ##
  ## dynamically generates
  ## the context of a Script
  ## execution
  ##
  class Context
    def self.of(script)
      ctx = Class.new(Context)
      ctx.const_set :This,   script
      ctx.const_set :World,  script.game.world 
      ctx.const_set :Room,   script.game.world.room
      ctx.const_set :Status, script.game.world.status
      ctx.const_set :Containers, script.game.world.containers
      ctx
    end
  end
end