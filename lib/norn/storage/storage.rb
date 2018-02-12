require 'fileutils'
module Norn
  module Storage
    NORN_DIR = File.expand_path("~/.norn")
    ##
    ## setup Norn local assets
    ##
    def self.setup()
      Storage.mkdir_p()
      Storage.mkdir_p("databases")
    end
    
    def self.path(*path)
      #puts File.join(*([NORN_DIR] + path))
      File.join(*([NORN_DIR] + path))
    end

    def self.exists?(*path)
      absolute_path = Storage.path(*path)
      File.exists?(absolute_path) or Dir.exists?(absolute_path) 
    end

    def self.mkdir_p(*path)
      FileUtils.mkdir_p(
        Storage.path(*path))
    end

    def self.open(file, &block)
      File.open(path(file), 'a', &block)
    end

    def self.write_json(file, data)
      open(file) do |f|
        JSON.dump(data)
      end
    end

    setup()
  end
end