require "norn/parser/tag"
module Norn
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

      def to_s
        "<World::Callbacks>"
      end

      alias_method :inspect, :to_s
      ##
      ## general catch-all for debugging
      ##
      def on_unhandled(tag)
        System.log(tag, label: %{unhandled_#{tag.name}})
      end
      ##
      ## silenced callbacks
      ##
      def silence(tag); end
      alias_method :on_dialogdata_mapviewmain, :silence
      alias_method :on_exposecontainer, :silence
      alias_method :on_opendialog_mapmaster, :silence
      alias_method :on_opendialog_quick_simu, :silence
      alias_method :on_opendialog_injuries, :silence
      alias_method :on_opendialog_combat, :silence
      alias_method :on_opendialog_espmasterdialog, :silence
      alias_method :on_opendialog_minivitals, :silence
      alias_method :on_opendialog_quick, :silence
      alias_method :on_opendialog_quick_combat, :silence
      alias_method :on_opendialog_activespells, :silence
      alias_method :on_opendialog_befriend, :silence
      alias_method :on_opendialog, :silence
      alias_method :on_mono, :silence
      ##
      ## openDialog
      ##
      ## encumberance info
      def on_opendialog_encum(root)
        root.children.each do |tag|
          on_dialogdata_encum Tag.find(tag, :dialogdata)
        end
      end
      ## experience info
      def on_opendialog_expr(tag)
        Tag.find(tag, :dialogdata).children.each do |tag|
          case tag.id
          when :yourlvl
            @world.char.put(:level, tag.fetch(:value).split(" ").last.to_i)
          when :mindstate
            on_mindstate(tag)
          when :nextlvlpb
            @world.char.put(:next_level, tag.fetch(:text).split(" ").first.to_i)
          end
        end
      end
      ## proxy to dialogdata callback
      def on_opendialog_stance(tag)
        on_dialogdata_stance Tag.find(tag, :dialogdata)
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

      def on_casttime(tag)
        @world.roundtime.put(:casttime,
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

      def on_streamwindow(window)
        if window.fetch(:title).downcase.to_sym.eql?(:room)
          title = window.fetch(:subtitle)
          title = title.slice(3, title.size)
          return if @world.room.title.eql?(title)
          @world.room.inc
          @world.room.put(:title,
            title)
        end
      end

      def on_stream_society(task)
        # TODO save society task
      end

      def on_stream_bounty(task)
        world.bounty.sync **Bounty.parse(task.text)
      end

      def on_stream_spells(spells)
        spells.children.each do |known|
          unless known.fetch(:noun).empty?
            num  = known.fetch(:noun)
            ##
            ## sometimes the Stream text is formatted
            ## like "501 Sleep"
            ##
            name = known.text.strip.gsub(num + " ", "")
            @world.spells.learn(num.to_i, name)
          end
        end
      end

      def on_stream_inv(tag)
        @world.inv.put *(tag.children.map.map do |tag| 
          Item.new(**tag.to_gameobj) 
        end)
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
            unless tag.text.nil?
              @world.room.put(:desc, 
                Room::Description.of(tag))
            end
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
        # silence is golden
      end

      def on_style_roomdesc(tag)
        # silence is golden
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
      ## Spell Info
      ##
      def on_dialogdata_activespells(spells)
        @world.spells.flush!
        Tag.by_name(spells, :label).map do |spell|
          if spell.fetch(:anchor_right, nil)
            @world.spells.add *[spell.fetch(:anchor_right), 
              *spell.fetch(:value).strip.split(":").map(&:to_i)]
          end
        end
      end
      ## spell about to be cast
      def on_spell(tag)
        @world.spells.prepare(tag.text)
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
          @world.char.put(:stow_container_id, id)
        end
      end

      ## clear a container
      def on_clearcontainer(tag)
        @world.containers.delete(tag.id)
      end
      alias_method :on_deletecontainer, :on_clearcontainer

      ## add item to container
      def on_inv(tag)
        id = tag.id.eql?(:stow) ? @world.char.fetch(:stow_container_id) : tag.id
        ##
        ## delete empty containers?
        ##
        if tag.children.empty?
          container = @world.containers.fetch(id, nil)
          return if container.nil?
          return @world.containers.delete(id)
        end
        ##
        ## the first <inv> tag is a wrapper for the container
        ##
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
        @world.stance.put(:remaining, 
          current.fetch(:value).to_i)
        @world.stance.put(:current,
          current.fetch(:text).split(" ").first.to_sym)
      end

      def on_dialogdata_injuries(root)
        root.children.each do |tag|
          case tag.name
          # holds injury/scar info
          when :image
            area  = Injuries.decode_area(tag.id)
            state = tag.fetch(:name).downcase.to_sym
            ## order of operations is important here
            ## Scars only appear in the XML after 
            ## the injury is healed
            op, severity = Injuries.decode(state) || Scars.decode(state) || [:none, 0]
            case op
            when :none
              @world.injuries.put(area, severity)
              @world.scars.put(area, severity)
            when :scar
              @world.scars.put(area, severity)
            when :injury
              @world.injuries.put(area, severity)
            end
          # holds health info
          when :progressbar
            if tag.id.eql?(:health2)
              _, remaining, max = decode_progress_bar(tag)
              @world.health.put(:remaining, remaining)
              @world.health.put(:max, max)
            end
          else
            # Silence is golden
          end
        end
      end

      def on_dialogdata_minivitals(tag)
        tag.children.each do |tag|
          if tag.is?(:progressbar)
            type, remaining, max = decode_progress_bar(tag)
            ctx = @world.get_context_for(type)

            unless ctx.nil?
              ctx
                .put(:max, max)
                .put(:remaining, remaining)
            else
              System.log(tag, label: :vitals)
            end
          end
        end
      end

      def on_dialogdata_expr(tag)
        tag.children.each do |tag|
          case tag.id
          when :mtps
            ## update mental TPs
            @world.char.put(:mental_tps, 
              tag.fetch(:value).split(" ").first.to_i)
          when :ptps
            ## update physical TPs
            @world.char.put(:physical_tps, 
              tag.fetch(:value).split(" ").first.to_i)
          when :mindstate
            on_mindstate(tag)
          end
        end
      end

      def on_dialogdata_encum(root)
        root.children.each do |tag|
          case tag.id
          when :encumlevel
            @world.encumb.put(:percent, 
              tag.fetch(:value).to_i)
            @world.encumb.put(:level,
              tag.fetch(:text).downcase.gsub(" ", "_").to_sym)
          when :encumblurb
            # silence
          end
        end
      end

      def on_mindstate(tag)
        @world.mind.put(:current,
          Mind.decode(tag.fetch(:text)))
        @world.mind.put(:percent,
          tag.fetch(:value).to_i)
      end
      ##
      ## decode a progress bar into a Tuple<Attr, Current, Max>
      ##
      def decode_progress_bar(bar)
        [bar.id, 
          *bar.fetch(:text).split(" ").last.split("/").map(&:to_i)]
      end
    end
  end
end