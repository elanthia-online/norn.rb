require 'fileutils'
module Norn
  module Storage
    NORN_DIR = File.join Dir.home, ".norn"
    ##
    ## setup Norn local assets
    ##
    def self.setup()
      Storage.mkdir_p()
      Storage.mkdir_p("databases")
    end
    
    def self.norn_path(*path)
      File.join *([NORN_DIR] + path)
    end

    def self.mkdir_p(*path)
      FileUtils.mkdir_p norn_path(*path)
    end

    def self.open(file, &block)
      File.open(norn_path(file), 'a', &block)
    end

    def self.write_json(file, data)
      open(file) do |f|
        JSON.dump(data)
      end
    end

    def self.read(file)
      open(file) do |file|
        yield
      end
    end

    setup()
  end
end