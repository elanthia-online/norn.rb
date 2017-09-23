require 'fileutils'
module Norn
  module Storage
    NORN_DIR = File.join Dir.home, ".norn"
    ##
    ## setup app dir
    ##
    FileUtils.mkdir_p NORN_DIR

    def self.norn_path(*path)
      File.join *([NORN_DIR] + path)
    end

    def self.mkdir_p(dir)
      FileUtils.mkdir_p norn_path(dir)
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
  end
end