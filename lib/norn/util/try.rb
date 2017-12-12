class Try
  attr_accessor :result, :task
  
  def self.of(&task)
    Proc.new do 
      Try.new task
    end
  end

  def self.dump(ctx, try)
    return unless ctx.respond_to?(:log) && try.failed?
    begin
      ctx.log try.result.message
      try.result.backtrace.each do |line|
         ctx.log line
      end
    rescue => exception
      System.log(try.result, label: "Try.dump")
      System.log(exception,  label: "Try.dump")
    end
  end

  def initialize(&task)
    @task = task
    run!
  end

  private def run!
    begin
      result = @task.call
      # handle recursives
      if result.is_a?(Try)
        @result = result.result
      else
        @result = result
      end
    rescue Exception => e
      @result = e
    end
  end

  def failed?
    @result.class.ancestors.include? Exception
  end

  def success?
    !failed?
  end

  def recover
    Try.new { yield @result } if failed?
  end

  def then
    Try.new { yield @result } if success?
  end

  def match?(exp)
    if failed?
      @result.message.match(exp)
    elsif @result.respond_to?(:match)
      @result.match(exp)
    else
      raise Exception.new "cannot match class #{@result.class}"
    end
  end
end