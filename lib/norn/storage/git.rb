require "rugged"
require "norn/system"
require "norn/storage/storage"

module Norn
  module Git
    DATA_REPO  = %{https://github.com/elanthia-online/data.git}
    LOCAL_PATH = Storage.path("data")

    include Rugged

    @updater = Thread.new do
      unless File.exists?(LOCAL_PATH)
        Repository.clone_at(DATA_REPO, LOCAL_PATH)
        System.log("cloned #{DATA_REPO}", label: :git)
      else
        Git.repo().fetch("origin")
        System.log("updated from #{DATA_REPO}", label: :git)
      end
    end

    def self.repo()
      Repository.new(LOCAL_PATH)
    end

    def self.await_update()
      sleep 0.1 while @updater.alive?
    end
  end
end