require "cgi"
require "norn/util/memory-store"
require "norn/util/worker"
Dir[File.dirname(__FILE__) + '/../world/**/*.rb'].each do |file| require file end

class Script < Thread
  def self.label(*prefixes)
    "[" + prefixes.flatten.compact.map(&:to_s)
      .join(".")
      .gsub(/\s+/, "") + "]"
  end

  attr_reader :name, :code, :mode, :callbacks
  attr_accessor :result, :package, :game
  
  def initialize(game, name, mode: :normal, args: [])
    @game      = game
    @name      = name
    @callbacks = []
    @mode      = mode
    @code      = 0
    @start     = Time.now
    script     = self
    game.scripts.register(@name, self)
    super do
      work = Try.new do
        yield self
      end
      @code = 1 if work.failed?
      Try.dump(script, work)
      teardown
    end
  end

  def add_callbacks(obj)
    @callbacks << obj
    @game.world.callbacks << obj
  end

  def delete_callbacks(obj)
    @callbacks.delete(obj)
    @game.world.callbacks.delete(obj)
  end

  def exit_info
    log(%{<Exit status:#{@code} time:#{self.uptime}s>}) unless silent?
  end

  def teardown
    @callbacks.each do |service|
      delete_callbacks service
    end
    exit_info
  end

  def debug?
    mode == :debug
  end

  def silent?
    mode == :silent
  end

  def siblings
    @game.scripts.values.reject do |script|
      script == self
    end
  end

  def ok?
    @code = 0
  end

  def die!
    @code = 1
    teardown
    kill
  end

  def await
    sleep 0.1 while alive?
    @result
  end

  def view(obj, label: nil)
    left_col = Script.label(@name, label)
    escaped  = obj.to_s.gsub(/(<|>&)/) do CGI.escape_html $1 end
    [left_col, escaped].join(" ")
  end
  ##
  ## send a string to a client
  ##
  def safe_log(*lines, label: nil)
    return if @game.nil?
    return if lines.empty?
    @game.clients.each do |client|
      unless client.is_a?(Downstream::Receiver) or client.is_a?(Downstream::Mutator)
        lines.each do |line|
          client.puts view(line, label: label)
        end
      end
    end
  end

  alias_method :log, :safe_log
  alias_method :inspect, :safe_log
  
  def dead?
    !alive?
  end
  
  def keepalive!
    loop do sleep() end
  end

  def to_s
    "<Script:#{@name} @uptime=#{uptime.as_time}>"
  end

  def uptime
    Time.now - @start
  end
end