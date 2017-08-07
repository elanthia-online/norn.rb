class ParametrizedTrait < Module

  def initialize(blank_trait, args)
    @args = args
    @macro = blank_trait.instance_variable_get(:@modularity_macro)
    include(blank_trait)
  end

  def included(base)
    base.class_exec(*@args, &@macro)
  end

end

module Trait
  def with_traits(&macro)

    @modularity_macro = macro

    def self.included(base)
      unless base.is_a?(ParametrizedTrait)
        base.class_exec(&@modularity_macro)
      end

    end

    def self.[](args, &block)
      blank_trait = self
      ParametrizedTrait.new(blank_trait, args.to_struct)
    end

  end

end

Module.send(:include, Trait)
