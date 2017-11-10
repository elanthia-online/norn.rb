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

      def self.entry(metadata)

      end
    end

    module Loader
      SCRIPTS = "scripts"
      Norn::Storage.mkdir_p SCRIPTS

      def self.script_path(*path)
        Norn::Storage.norn_path *([SCRIPTS] + path)
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
          raise Exception.new "could not find #{name}"
        end
      end

      def self.package(path)
        Norn.log(path, :package)
        metadata = Package.metadata(path)
        [File.open(metadata.absolute_entry_path, 'rb').read, metadata]
      end

      def self.script(path)
        Norn.log(path, :script)
        [File.open(rb_file(path), 'rb').read, OpenStruct.new]
      end
    end

    def self.normalize(cmd)
      cmd
        .gsub(Norn::COMMAND, "")
        .without_line_breaks
        .strip
    end

    def self.run(cmd)
      name = normalize(cmd)
      Script.new(name) do |script|
        code, metadata = Loader.compile(name)
        script.package = metadata
        script.result  = Context.of(script).class_eval(code)
      end
    end
  end
end