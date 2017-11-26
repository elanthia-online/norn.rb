require "yaml"
require "norn/util/try"
require "norn/script/script"
require "norn/storage/storage"
require "norn/script/context"

class Script
  class UserScript
    module Package
      class Metadata < OpenStruct
      end

      def self.metadata(path)
        data = YAML.load_file File.join(path, "package.yml")
        data[:absolute_entry_path] = File.join(path, data["main"])
        Metadata.new data
      end
    end

    module Loader
      DEFAULT = Norn::Storage.norn_path("scripts")
      SCRIPTS = ENV.fetch("NORN_SCRIPTS", 
        DEFAULT)

      if SCRIPTS.eql?(DEFAULT)
        Norn::Storage.mkdir_p SCRIPTS
      end

      def self.script_path(*path)
        File.join(SCRIPTS, path)
      end

      def self.rb_file(path)
        %{#{path}.rb}
      end

      def self.compile(name)
        path = script_path(name)
        if File.directory?(path)
          package path
        elsif File.exists?(rb_file(path))
          script path
        else
          raise Exception.new %{<Script::#{name}> was not found at #{path}}
        end
      end

      def self.package(path)
        metadata = Package.metadata(path)
        [File.open(metadata.absolute_entry_path, 'rb').read, metadata]
      end

      def self.script(path)
        entry = rb_file(path)
        [File.open(entry, 'rb').read, 
          OpenStruct.new(file: entry)]
      end
    end

    def self.run(game, name, args: [])
      if game.scripts.running?(name)
        game.clients.each do |client|
          client.puts %{[script.error] #{name} is already running}
        end
      else
        Script.new(game, name) do |script|
          code, metadata = Loader.compile(name)
          script.package = metadata
          script.result  = Context.of(script, args).class_eval <<-end_eval, metadata.file
            #{code}
          end_eval
        end
      end
    end
  end
end