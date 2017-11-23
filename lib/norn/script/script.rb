require "cgi"
require "norn/util/memory-store"
require "norn/util/worker"
Dir[File.dirname(__FILE__) + '/../world/**/*.rb'].each do |file| require file end

class Script < Thread
  RUNNING = MemoryStore.new(:scripts)

  SUPERVISOR = Norn::Worker.new(:script_supervisor) do   
    RUNNING.each do |name, script, store|
      unless script.alive?
        store.delete(name)
      end
    end
  end

  def self.running?(name)
    fetch(name) && fetch(name).alive?
  end

  def self.running
    fetch
  end

  def self.fetch(name = nil)
    RUNNING.fetch(name)
  end

  def self.register(name, script)
    RUNNING.put(name, script)
    self
  end

  def self.kill(name)
    fetch(name).kill
    RUNNING.delete(name)
    self
  end

  def self.label(*labels)
    "[" + labels.flatten.compact.map(&:to_s)
      .join(".")
      .gsub(/\s+/, "") + "]"
  end

  def self.current
    fetch.values.find do |script|
      Thread.current == script
    end
  end

  attr_reader :name, :code, :mode
  attr_accessor :result, :package, :game
  
  def initialize(game, name, mode: :normal, args: [])
    @game   = game
    @name   = name
    @mode   = mode
    @code   = 0
    @start  = Time.now
    script  = self
    Script.register(@name, self)
    super do
      work = Try.new do
        yield self
      end
      @code = 1 if work.failed?
      Try.dump(script, work)
      script.write(%{<Exit status:#{script.code} time:#{script.uptime}s>}) unless silent?
    end
  end

  def debug?
    mode == :debug
  end

  def silent?
    mode == :silent
  end

  def siblings
    RUNNING.values.reject do |script|
      script == self
    end
  end

  def ok?
    @code = 0
  end

  def debug(*args, label: nil)
    return self unless debug?
    write(*args, 
      label: [:debug] + [label])
  end

  def view(obj, label: nil)
    left_col = Script.label(@name, label)
    escaped  = obj.to_s.gsub(/(<|>&)/) do CGI.escape_html $1 end
    [left_col, escaped].join(" ")
  end

  def await
    sleep 0.1 while alive?
    @result
  end

  def safe_write(*lines)
    return if @game.nil?
    return if lines.empty?
    @game.clients.each do |client|
      unless client.is_a?(Downstream::Receiver) or client.is_a?(Downstream::Mutator)
        lines.each do |line|
          client.puts(line)
        end
      end
    end
  end

  def write(*strs, label: nil)
    begin
      strs.each do |str|
        safe_write view(str, label: label)
      end
    rescue Exception => e
      safe_write(e.message)
      safe_write(e.backtrace.join("\n"))
      Try.dump(System, e)
    end
    self
  end

  def dead?
    !alive?
  end
  
  def to_s
    "<Script:#{@name} @uptime=#{uptime.as_time}>"
  end

  def uptime
    Time.now - @start
  end
end