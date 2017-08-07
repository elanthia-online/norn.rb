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

  def self.current
    fetch.values.find do |script|
      Thread.current == script
    end
  end

  attr_reader :name, :thread
  attr_accessor :result
  
  def initialize(name)
    @name   = name
    @start  = Time.now
    super do
      work = Try.new do
        yield self
      end
      if work.failed?
        write work.result.message
        write work.backtrace.join("\n")
      end
      Script.kill(@name)
    end
    Script.register(@name, self)
  end

  def view(t)
    "#{@name}>" + t.to_s.gsub(/(<|>&)/) do 
      CGI.escape_html $1
    end
  end

  def await
    sleep 0.1 while alive?
    @result
  end

  def write(str)
    puts view str
    if Norn.game.nil?
      puts view str
    else
      Norn.game.write_to_clients view str
    end
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