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
    ##
    ## broadcast an error to all clients
    ##
    def self._broadcast_error(game, error)
      game.clients.each do |client|
        client.puts %{[script.error] #{error}}
      end
    end
    ##
    ## tells all of the clients
    ## that a script is already started
    ##
    def self._already_running_error(game, name)
      _broadcast_error(game, %{#{name} is already running})
    end
    ##
    ## sends a script an Array(Argument)
    ## to consume
    ##
    def self._send_script_commands(game, name, args)
      game.scripts.fetch(name) do |script|
        if script.commands.empty?
          _broadcast_error(%{#{name} does not accept commands})
        else
          System.log("issuing command (#{args}) to #{name}", label: %i{script commands})
          script.commands << args
        end
      end
    end
    ##
    ## starts a script
    ##
    def self._start(game, name, args)
      Script.new(game, name) do |script|
        code, metadata = Loader.compile(name)
        script.package = metadata
        script.result  = Context.of(script, args).class_eval <<-SCRIPT, metadata.file
          #{code}
        SCRIPT
      end
    end

    def self._any_has_command?(command, scripts)
      scripts.values.find do |script|
        script.commands.has?(command.to_sym)
      end
    end

    def self._run_command_hook(script, command, args)
      script.commands.run(command, *args)
    end

    def self.run(game, name, args: [])
      hooks = _any_has_command?(name, game.scripts)
      # check and run existing command hooks
      # only the first script to register a command
      # will be able to intercept arguments for it
      return _run_command_hook(hooks, name, args) unless hooks.nil?
      # error on starting scripts that are running
      return _already_running_error(game, name) if game.scripts.running?(name)
      # star the script
      return _start(game, name, args)
    end
  end
end