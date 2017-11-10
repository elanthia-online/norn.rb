require "norn/parser/tag"

class World
  ## alias Tag util
  Tag = Norn::Parser::Tag
  class Callbacks
    attr_reader :world
    ##
    ## create our world callbacks
    ## with a reference to the world
    ## so we can synchronize the state
    ## from the raw tags
    ##
    def initialize(world)
      @world = world
    end
    ##
    ## general catch-all for debugging
    ##
    def on_unhandled(tag)
      Norn.log(tag, %{unhandled_#{tag.name}})
    end
    ##
    ## silenced callbacks
    ##
    def on_dialogdata_mapviewmain(tag) 
    end
    def on_exposecontainer(tag)
    end
    ##
    ## general info about the Game
    ## specific to a Character
    ##
    def on_app(tag)
      @world.char.merge(tag.attrs)
    end
    ##
    ## <prompt> update server-time offset
    ##
    def on_prompt(tag)
      @world.roundtime.offset(
        tag.fetch(:time))
    end
    ##
    ## hard roundtime
    ##
    def on_roundtime(tag)
      @world.roundtime.put(:roundtime,
        tag.fetch(:value))
    end
    ##
    ## cast roundtime
    ##
    def on_castroundtime(tag)
      @world.roundtime.put(:casttime,
        tag.fetch(:value))
    end
    ##
    ## <indicator>
    ##
    def on_indicator(tag)
      @world.status.put(tag.id,
        tag.fetch(:visible))
    end
    ##
    ## handle Streams
    ##
    def on_clearstream(stream)
      # TODO flush stream
    end

    def on_stream_society(task)
      # TODO save society task
    end

    def on_stream_bounty(task)
      # TODO save bounty
    end

    def on_stream_spells(spells)
      # TODO save spells
    end
    ##
    ## Room callbacks
    ##
    def on_stream_room(stream)
      stream.children.each do |tag|
        case tag.id
        when :room_players
          on_component_room_players(tag)
        when :room_desc
          on_style_roomdesc(tag)
        when :room_exits
          on_compass(tag)
        when :room_objs
          on_component_room_objs(tag)
        when :sprite
          :noop
        else
          raise Exception.new %{
            unhandled stream tag:

            #{tag}
          }
        end
      end
    end

    def on_style_roomname(tag)
      @world.room.put(:title,
        tag.text)
    end

    def on_style_roomdesc(tag)
      return if tag.text.nil?
      @world.room.put(:desc, 
        Room::Description.of(tag))
    end

    def on_compass(tag)
      @world.room.put(:exits, tag.children.map do |tag| 
        Room::Exit.of(tag)
      end)
    end

    def on_component_room_objs(tag)
      @world.room.put(:objs, 
        Room.to_monsters_or_items(tag.children))
    end

    def on_component_room_players(tag)
      return @world.room.put(:players, []) if tag.children.empty?
      @world.room.put(:players, tag.children.map do |tag|
        Player.new(**tag.to_gameobj)
      end)
    end
    ##
    ## inventory callbacks
    ##
    def on_stream_inv(tag)
      # TODO
    end
    ##
    ## Spell Info
    ##
    def on_dialogdata_activespells(tag)
      # TODO
    end
    ## spell about to be cast
    def on_spell(tag)
      # TODO
    end
    ##
    ## Hand callbacks
    ##
    def on_right(tag)
      on_hand(:right, tag)
    end

    def on_left(tag)
      on_hand(:left, tag)
    end

    def on_hand(hand, tag)
      if tag.fetch(:exist, nil)
        @world.hands.put(hand, 
          Item.new(**tag.to_gameobj))
      else
        @world.hands.put(hand, nil)
      end
    end
    ##
    ## containers
    ##
    def on_container(tag)
      target = tag.fetch(:target)
      # drop hash from #<id>
      id = target.slice(1, target.size)
      @world.containers.put(id, [])
      if tag.id.eql?(:stow)
        @world.containers.put(:real_stow_id, id)
      end
    end
    ## clear a container
    def on_clearcontainer(tag)
      @world.containers.delete(tag.id)
    end

    ## add item to container
    def on_inv(tag)
      id = tag.id.eql?(:stow) ? @world.containers.fetch(:real_stow_id) : tag.id
      
      if tag.children.empty?
        container = @world.containers.fetch(id, nil)
        return if container.nil?
        return @world.containers.delete(id)
      end

      child = tag.children.first
     
      return if child.fetch(:exist, nil).eql?(id)

      @world.containers.put(id,
        @world.containers.fetch(id, []) + [Item.new(**child.to_gameobj)])
    end
    ##
    ## friends
    ##
    def on_dialogdata_befriend(tag)
      # TODO
    end
    ##
    ## combat
    ##
    def on_dialogdata_combat(root)
      root.children.each do |child|
        case child.id
        when :pbarstance
          on_dialogdata_stance(child)
        else
          # silence is golden
        end
      end
    end

    def on_dialogdata_stance(tag)
      current = Tag.find(tag, :progressbar)
      @world.stance.put(:percent, 
        current.fetch(:value).to_i)
      @world.stance.put(:current,
        current.fetch(:text).split(" ").first.to_sym)
    end

    def on_dialogdata_injuries(root)
      root.children.each do |tag|
        Norn.log(tag.attrs, :injury)
      end
    end

    def on_dialogdata_minivitals(tag)
      # TODO
    end

    def on_dialogdata_expr(tag)
      # TODO
    end
  end
end