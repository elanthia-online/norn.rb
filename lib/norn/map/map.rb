require "norn/util/lookup"
require "norn/storage/storage"
require "json"

module Norn
  module Map
    MAP_FILE = Storage.path("data/map.json")
    BY_ID    = Hash.new
    LOCK     = Mutex.new
    LOOKUPS  = {
      title:       Lookup.new(:title),
      description: Lookup.new(:description),
      tags:        Lookup.new(:tags),
      location:    Lookup.new(:location),
      paths:       Lookup.new(:paths),
    }

    def self.size
      BY_ID.keys.size
    end
    
    def self.id(num)
      LOCK.synchronize do
        room = BY_ID.fetch(num.to_i, nil)
        if room.nil?
          room
        else
          OpenStruct.new(room)
        end
      end
    end

    def self.empty?
      BY_ID.empty?
    end

    def self.find(*args)
      id = by(*args).first
      return id if id.nil?
      return Map.id(id)
    end

    def self.by(type, key)
      LOCK.synchronize do
        type = type.to_sym
        unless LOOKUPS.has_key?(type)
          raise Exception.new %{unknown Map table #{type}}
        else
          LOOKUPS.fetch(type).fetch(key, [])
        end
      end
    end

    def self.load()
      Map.lazy_load() if Map.empty?
      self
    end

    def self.lazy_load()
      LOCK.synchronize do
        return :noop unless empty?
        JSON.load(File.read(MAP_FILE)).each do |room|
          room = room.symbolize
          index_room(room)
        end
        :ok
      end
    end

    def self.index_room(room)
      BY_ID[room[:id]] = room
      LOOKUPS.each do |key, table|
        index_by_key(table, key, room)
      end
    end

    def self.index_by_key(table, key, room)
      values = room.fetch(key, [])
      # cast to iterable
      values = [values] if values.is_a?(String)
      # skip non-iterables
      return :noop unless values.is_a?(Array)
      values.each do |val|
        table.push(val, room[:id])
      end
    end

    class Path
      include Enumerable
      def self.to_room_number(from, to)
        return to      if to.is_a?(Integer)
        return to.to_i if to.is_a?(String) and to.is_i?
        # tag based lookup
        return Map.find_nearest_tag(from, to)
      end

      attr_reader :from, :to, :rooms, :i

      def initialize(from, to)
        @from  = from.to_i
        @to    = Path.to_room_number(@from, to)
        @rooms = [@from] + Map.path_between(@from, @to)
      end

      def empty?
        @rooms.nil? or @rooms.empty?
      end

      def size
        @rooms.size
      end

      def at(idx)
        current_room = Map.id(@rooms[idx])
        next_room_id = @rooms[idx+1]
        next_room    = if next_room_id.nil? then Map.id(@to) else  Map.id(next_room_id) end
        wayto        = current_room.wayto[next_room.id.to_s]
        [current_room, next_room, wayto]
      end

      def each
        rooms.each_with_index do |id, idx|
          yield(*at(idx))
        end
      end

      def to_a
        rooms
      end
    end

    def self.dijkstra(source, destination)
      return :err if source.nil? or destination.nil?
      Map.load() if Map.empty?      
      begin
        destination = [destination] if destination.is_a?(String)
        destination = [destination] if destination.is_a?(Integer)
        destination.map!(&:to_i)
        visited            = Array.new
        shortest_distances = Array.new
        previous           = Array.new
        pq = [ source ]
        pq_push = Proc.new do |val|
          for i in 0...pq.size
            if shortest_distances[val] <= shortest_distances[pq[i]]
              pq.insert(i, val)
              break
            end
          end
          pq.push(val) if i.nil? or (i == pq.size-1)
        end
        visited[source] = true
        shortest_distances[source] = 0
        until pq.size == 0
          v = pq.shift
          break if destination.include?(v)
          visited[v] = true
          Map.id(v)&.wayto&.keys&.each do |adj_room|
            adj_room_i = adj_room.to_i
            unless visited[adj_room_i] 
              nd = Map.id(v).timeto[adj_room]
              if nd.is_a?(Array)
                # System.log(nd, label: :binary_path_cost)
                # TODO: fix this so
                # TODO: scripts know state
                nd = nil
              end
                
              if nd
                nd += shortest_distances[v]
                if shortest_distances[adj_room_i].nil? or (shortest_distances[adj_room_i] > nd)
                  shortest_distances[adj_room_i] = nd
                  previous[adj_room_i] = v
                  pq_push.call(adj_room_i)
                end
              end
            end
          end
        end
        return previous, shortest_distances
      rescue Exception => e
        System.log e, label: :dijkstra_error
        :err
      end
    end

    def self.path_between(source, destination)
      destination = destination.to_i
      previous, shortest_distances = Map.dijkstra(source, destination)
      return nil unless previous[destination]
      path = [ destination ]
      path.push(previous[path[-1]]) until previous[path[-1]] == source
      path.reverse!
      return path
    end

    def self.find_nearest(from, rooms)
      rooms = rooms.collect { |num| num.to_i }
      return from if rooms.include?(from)
        
      previous, shortest_distances = Map.dijkstra(from, rooms)
      rooms.delete_if do |room_num| 
        shortest_distances[room_num].nil? 
      end
      rooms.sort do |a,b| 
        shortest_distances[a] <=> shortest_distances[b] 
      end.first 
    end

    def self.find_nearest_tag(from, tag)
      find_nearest(from, 
        Map.by(:tags, tag))
    end
  end
end