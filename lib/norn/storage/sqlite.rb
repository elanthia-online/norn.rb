require "sequel"
require "norn/storage/storage"

module Norn
  module Storage
    module DB
      def self.path(name)
        name = name.to_s
        name = name + ".db" unless name.end_with?(".db")
        Storage.norn_path("databases", name)
      end

      def self.open(name)
        Sequel.sqlite(
          Storage::DB.path(name))
      end
    end
  end
end