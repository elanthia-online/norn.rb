class ThreadPool < MemoryStore
  attr_reader :supervisor

  def initialize
    super()
    pool = self
    @supervisor = Norn::Worker.new(:script_supervisor) do   
      pool.each do |name, script, store|
        unless script.alive?
          store.delete(name)
        end
      end
    end
  end

  def running?(name)
    fetch(name) && fetch(name).alive?
  end

  def running
    fetch
  end

  def register(name, script)
    put(name, script)
    self
  end

  def kill(name)
    fetch(name).die!
    delete(name)
    self
  end

  def current
    fetch.values.find do |script|
      Thread.current == script
    end
  end
end