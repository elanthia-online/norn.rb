require "norn/storage/storage"
require "norn/storage/git"

module Norn
  module Metadata
    require "tomlrb"
    require "ostruct"

    @@creatures = nil
    @@jewels    = nil
    @@skins     = nil
    @@patterns  = nil

    def self.toml(name)
      Tomlrb.load_file(Storage.path("data", "#{name}.toml"), symbolize_keys: true)
    end

    def self.unwrap(name)
      unwrapped = toml(name)[name]
      unwrapped.reduce(Hash.new) do |repo, row|
        yield(repo, row)
        repo
      end
    end

    def self.creatures
      load_creatures! if @@creatures.nil?
      @@creatures
    end

    def self.jewels
      load_jewels! if @@jewels.nil?
      @@jewels
    end

    def self.skins
      load_skins! if @@skins.nil?
      @@skins
    end

    def self.patterns
      @@patterns
    end

    def self.load_creatures!
      @@creatures = unwrap(:creatures) do |repo, creature|
        creature[:tags] = creature[:tags].map(&:to_sym)
        repo[creature[:name].downcase] = {
          level: creature[:level],
          tags: creature[:tags]
        }
      end
    end

    def self.load_jewels!
      @@jewels = unwrap(:gems) do |repo, jewel|
        repo[jewel[:name].downcase] = jewel
      end
    end

    def self.load_skins!
      @@skins = unwrap(:skins) do |repo, skin|
        creature = creatures.fetch(skin[:creature].downcase)
        creature[:skin]   = skin
        creature[:tags] << :skinnable
        repo[skin[:name]] = skin
      end
    end

    def self.load_patterns!
      @@patterns = toml(:patterns)
    end

    Git.await_update()
    load_creatures!
    load_skins!
    load_jewels!
    load_patterns!
  end
end
