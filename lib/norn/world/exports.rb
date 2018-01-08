module Norn
  class Exports
    include Enumerable

    def self.get_namespace(resource)
      var = if resource.is_a?(Class) or resource.is_a?(Module)
       resource.name
      else
        resource.class.name
      end
      var.split("::")[1..-1].join("::").to_sym
    end

    attr_accessor :modules
    def initialize()
      @modules = Hash.new
    end

    def each(&block)
      @modules.each(&block)
    end

    def keys
      @modules.keys
    end

    def import(name)
      @modules.fetch(name)
    end

    def define(resource)
      @modules[Exports.get_namespace(resource)] = resource
    end
  end
end