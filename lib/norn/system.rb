module System
  def self.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def self.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def self.unix?
    !self.windows?
  end

  def self.linux?
    self.unix? and not self.mac?
  end

  def self.pattern
    debug = ENV.fetch("DEBUG", false)
    debug = %r{#{debug}} if debug
    debug
  end

  def self.log(message, label: :debug)
    if label.is_a?(Array)
      label = label.map(&:to_s).join(".")
    end

    return self unless p = pattern
    return self unless label.to_s.match(p)
    if message.is_a?(Exception)
      message = [
        message.message,
        message.backtrace.join("\n"),
      ].join
    end
    label = "Norn.#{label}".rjust(30)
    $stdout.puts "[#{label}] #{message}"
  end
end