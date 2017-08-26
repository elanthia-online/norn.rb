require "ostruct"
require "norn/util/buffer"
require "norn/util/memory-store"
require "norn/util/trait"
require "norn/dsl/tags"

module Decoder
  DECODERS = []

  IDENTITY = Proc.new do |t|
    [:ok, t]
  end

  def self.each
    DECODERS.each do |decoder|
      yield decoder
    end
  end

  with_traits do |args|
    DECODERS << self

    @wants   = args.wants
    @cast    = args.cast  || IDENTITY
    @attrs   = args.attrs || [:id]
    
    def self.cast(tag)
      @cast.call *(@attrs.map do |attr| tag.fetch(attr) end + [tag, tag.children])
    end

    def self.wants?(type)
      @wants.include?(type)
    end

    def self.debug(message, label)
      Norn.log message, %{#{self.name}.#{label}}.to_sym
    end
  end
end