module Command
  module DSL
    ## the global norn scripting command regex
    COMMAND     = /^(\/|;)/
    ## dot commands to interact with a Norninstance
    DOT_COMMAND = /^\./
    ## silence exec script
    SILENT      = "e"
    ## verbose exec script
    ## eg: /i 1+1 => 2
    INTERACTIVE = "i"
  end

  def self.match?(str)
    !!str.match(DSL::COMMAND)
  end

  def self.code(cmd)
    cmd.slice(1, cmd.length).chars.take_while do |char| 
      char !~ %r{\s} 
    end.join("")
  end

  def self.partition(cmd)
    op = Command.code(cmd)

    [op, 
      cmd.strip.slice(op.size + 1, cmd.size)]
  end

  def self.parse(game, cmd)
    begin
      script, args = partition(cmd)
      case script
      when DSL::SILENT
        return Script::Exec.run(game, args, mode: :silent)
      when DSL::INTERACTIVE
        return Script::Exec.run(game, args, mode: :verbose)
      else
        return Script::UserScript.run(game, script, args: args.strip.split(" "))
      end
    rescue => exception
      System.log(exception, label: :command_error)
    end
  end
end