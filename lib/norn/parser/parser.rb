require "oga"
require "norn/parser/tag"
require "norn/util/worker"
require "norn/parser/callbacks"
require "norn/parser/normalizer"

module Norn
  ##
  ## non-blocking thread-safe resistant 
  ## wrapper around Oga 
  ## most performant XML parser in Rubyland
  ##   
  class Parser
    ##
    ## blacklist used to filter edge nodes 
    ## from parser callbacks since they 
    ## have no context within Norn
    ##
    EDGE_NODES   = %i{a monster resource d streamwindow output opendialog nav updateverbs}
    ## attrs
    attr_reader :worker, :reader, :writer, 
                :oga, :lock, :sax_callbacks
    ##
    ## create our parser
    ##        
    def initialize(world_callbacks)
      ## create a Thru IO objects
      @reader, @writer = IO.pipe
      @lock = Mutex.new
      ## create an instance for Callbacks
      @sax_callbacks = Callbacks.new(world_callbacks)
      ## put the parser in it's own error-safe
      ## Thread
      @worker = Worker.new do |worker|
        @oga = Oga.sax_parse_html(@sax_callbacks, @reader)
      end
    end
    ##
    ## normalize GS-nonsense
    ## write to the underlying IO
    ## 
    def puts(incoming)
      @lock.synchronize do
        incoming = Normalizer.apply(incoming)
        # Norn.log(incoming, :incoming)
        @writer.puts incoming
      end
    end
  end
end