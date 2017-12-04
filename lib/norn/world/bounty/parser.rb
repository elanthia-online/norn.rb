require "norn/world/bounty/bounty"
##
## thank you Kragdruk
##
class Bounty
  module Parser
    require 'ostruct'
    @@task_assignment_regexs = {
        /It appears they have a creature problem they'd like you to solve/           => :cull,
        /It appears they need your help in tracking down some kind of lost heirloom/ => :heirloom,
        /The local furrier .+ has an order to fill and wants our help/               => :skins,
        /The local gem dealer, [^,]+, has an order to fill and wants our help/       => :gem,
#        /to provide a protective escort/                                             => :escort,
        /Hmm, I've got a task here from the town of ([^.]+?).  The local [^,]+?, [^,]+, has asked for our aid.  Head over there and see what you can do.  Be sure to ASK about BOUNTIES./ => :herb,
        /It appears that a local resident urgently needs our help in some matter/    => :rescue,
        /It appears they have a bandit problem they'd like you to solve/             => :bandit,
    }

    @@task_completed_regexs = {
        /^You have succeeded in your task and can return to the Adventurer's Guild/  => :taskmaster,
        /^You have located (?:an?|some) (.+) and should bring it back to (?:one of the (.*) gate guards|the dwarven militia sergeant near the (Kharam-Dzu) town gates|one of the guardsmen just inside the (Ta'Illistim) City Gate|Quin Telaren of (Wehnimer's Landing))\.$/                    => :heirloom,
        /^You succeeded in your task and should report back to (?:one of the (.*) gate guards|the dwarven militia sergeant near the (Kharam-Dzu) town gates|one of the guardsmen just inside the (Ta'Illistim) City Gate|Quin Telaren of (Wehnimer's Landing))\.$/                      => :dangerous,
    }

    @@task_triggered_regexs = {
        /^You have made contact with the child you are to rescue and you must get (?:him|her) back alive to one of the (?:guardsmen) just inside ([^.]+)\.$/  => :rescue,
        /^You have been tasked to hunt down and kill a particularly dangerous ([^.]+) that has established a territory [oi]n (?:the\s+)?([^.]+?)(?: near [^.]+)?\.  You have provoked (?:his|her|its) attention and now you must(?: return to where you left (?:him|her|it) and)? kill (?:him|her|it)!$/ => :dangerous,
    }

    @@task_description_regexs = {
        /^You have been tasked to(?: help \w+)? suppress (bandit) activity (?:on|in) (?:the\s+)?([^.]+?)(?:\s+near [^.]+)?\.  You need to kill (\d+) (?:more\s+)?of them to complete your task\.$/ => :bandit,
        /^You have been tasked to(?: help \w+)? suppress ([^.]+) activity (?:on|in) (?:the\s+)?([^.]+?)(?:\s+near [^.]+)?\.  You need to kill (\d+) (?:more\s+)?of them to complete your task\.$/  => :cull,
        /^You have been tasked to recover (?:an?|some) ([^.]+) that an unfortunate citizen lost after being attacked by an? ([^.]+?) (?:near|[oi]n) (?:the\s+)?([^.]+?)(?:\s+near [^.]+)?\.  The heirloom can be identified by the initials \w+ engraved upon it\.  [^.]*?(LOOT|SEARCH)[^.]+\.$/ => :heirloom,
        /^You have been tasked to retrieve (\d+) ([^.]+?)s? of at least ([^.]+) quality for [^.]+ in ([^.]+?)\.  You can SKIN them off the corpse of an? ([^.]+) or purchase them from another adventurer\.  You can SELL the skins to the furrier as you collect them\."$/ => :skins,
        /^The gem dealer in ([^,]+), [^,]+, has received orders from multiple customers requesting (?:an?|some) ([^.]+)\.  You have been tasked to retrieve (\d+) (?:more\s+)?of them\.  You can SELL them to the gem dealer as you find them\.$/ => :gem,
        /^(?:The taskmaster told you:  ")?I've got a special mission for you\.  A certain client has hired us to provide a protective escort on (?:his|her) upcoming journey\.  Go to ([^.]+) and WAIT for (?:him|her) to meet you there\.  You must guarantee (?:his|her) safety to ([^.]+) as soon as you can, being ready for any dangers that the two of you may face\.  Good luck!"?$/ => :escort,
        /^The .+? in ([^,]+?), [^,]+?, is working on a concoction that requires (?:an?|some) ([^.]+?) found [oi]n (?:the\s+)?([^.]+?)(?:\s+near [^.]+)?\.  These samples must be in pristine condition\.  You have been tasked to retrieve (\d+) (?:more\s+)?samples?\.$/ => :herb,
        /^You have been tasked to (?: help \w+|hunt down and) kill a (?:particularly )?dangerous ([^.]+) that has established a territory [oi]n (?:the\s+)?([^.]+?)(?: near [^.]+)?\.  You can get its attention by killing other creatures of the same type in its territory\.$/ => :dangerous,
        /^You have been tasked to rescue the young (?:runaway|kidnapped) (?:son|daughter) of a local citizen\.  A local divinist has had visions of the child fleeing from an? ([^.]+) [oi]n (?:the\s+)?([^.]+?)(?:\s+near [^.]+)?\.  Find the area where the child was last seen and clear out the creatures that have been tormenting (?:him|her) in order to bring (?:him|her) out of hiding\.$/ => :rescue,
    }

    @@regex_for_task_description_of = @@task_description_regexs.invert
    @@regex_for_trigger_description_of = @@task_triggered_regexs.invert
    @@regex_for_assignment_of       = @@task_assignment_regexs.invert
    @@regex_for_completed           = @@task_completed_regexs.invert

    @@requirement_labels_for_task = {
        :cull       => [ :creature, :area, :number ],
        :heirloom   => [ :item, :creature, :area, :action ],
        :skins      => [ :number, :skin, :quality, :town, :creature ],
        :gem       => [ :town, :jewel, :number ],
        :escort     => [ :start, :destination ],
        :herb      => [ :town, :herb, :area, :number ],
        :rescue     => [ :creature, :area ],
        :dangerous  => [ :creature, :area ],
        :bandit    => [ :creature, :area, :number ],
    }

    @@task_failed_regexs = {
        /^You have failed in your task/ => :taskmaster,
        /^The child you were tasked to rescue is gone and your task is failed.  Report this failure to the Adventurer's Guild./ => :taskmaster,
    }

    def self.parse(desc)
        return nil if desc.nil? or desc.empty?
        @description    = desc
        @requirements   = nil #Hash.new
        @task           = nil
        @status         = nil

        # Figure task type and status from description
        if @description =~ /^You are not currently assigned a task/
            @task = :taskmaster
        elsif check_task_description( desc )
            @status       = :unfinished
            @task         = check_task_description( desc )
            @requirements = Hash.new
        elsif check_task_assignment( desc )
            @status = :assigned
            @task   = check_task_assignment( desc )
            if [:herb].include? @task
              match_data = @@regex_for_assignment_of[@task].match( @description )
              @requirements = { town: match_data[1] }
            end
        elsif check_task_completed( desc )
            @status = :done
            @task   = check_task_completed( desc )

            if :heirloom == @task
              match_data = @@regex_for_completed[@task].match( @description )
              @requirements = {
                :item => match_data[1],
                :town => match_data.captures.compact.last,
              }
            else
              if match_data = @@regex_for_completed[@task].match( @description )
                @requirements = {
                  :town => match_data.captures.compact.last,
                }
              end
            end
        elsif check_task_failed( desc )
            @status = :failed
            @task   = check_task_failed( desc )
        elsif check_task_triggered( desc )
            @status = :triggered
            @task   = check_task_triggered( desc )
            @requirements = Hash.new

            if :dangerous == @task
                if @description =~ @@regex_for_trigger_description_of[@task]
                    match_data = @@regex_for_trigger_description_of[@task].match( @description ).to_a.flatten
                    match_data.shift
                    @@requirement_labels_for_task[@task].each_with_index { |label, index|
                        @requirements[label] = match_data[index]
                    }
                else
                    echo "ERROR: couldn't parse triggered dangerous task requirements"
                end
            elsif :heirloom == @task and defined? @@last_heirloom_item and not @@last_heirloom_item.nil?
                @requirements = { :item => @@last_heirloom_item }
            end
        else
            #echo "ERROR: did not recognize bounty description:"
            #echo desc
            return nil
        end

        if @task.nil?
            # we don't have a bounty, so it doesn't have any requirements
        elsif :unfinished == @status and @description =~ @@regex_for_task_description_of[@task]
            match_data = @@regex_for_task_description_of[@task].match( @description ).to_a.flatten
            match_data.shift
            @@requirement_labels_for_task[@task].each_with_index { |label, index|
                if :action == label
                    @requirements[label] = match_data[index].downcase
                elsif :number == label
                    @requirements[label] = match_data[index].to_i
                elsif :creature == label
                    # Clean up creature value if we need to remove extra adjectives (eg beings, centaurs)
                    critter = match_data[index]
                    critter = 'being' if critter =~ /^\w+ being$/
                    @requirements[label] = critter
                else
                    @requirements[label] = match_data[index]
                end
            }
            if :heirloom == @task
                @@last_heirloom_item = @requirements[:item]
            end
        elsif :unfinished == @status
            echo "ERROR: couldn't parse requirements from description"
        end

        return ({ desc: @description, task: @task, status: @status }).merge(@requirements || {})
    end


    def self.check_task_description(desc)
      return nil if desc.nil? or desc.empty?
      for regex in @@task_description_regexs.keys
        if desc =~ regex
          return :bandit if desc =~ /bandit/
            return @@task_description_regexs[regex]
        end
      end
      return nil
    end

    def self.check_task_assignment(desc)
      return nil if desc.nil? or desc.empty?
      for regex in @@task_assignment_regexs.keys
        return @@task_assignment_regexs[regex] if desc =~ regex
      end
      return nil
    end

    def self.check_task_completed(desc)
      return nil if desc.nil? or desc.empty?
      for regex in @@task_completed_regexs.keys
        return @@task_completed_regexs[regex] if desc =~ regex
      end
      return nil
    end

    def self.check_task_failed(desc)
      return nil if desc.nil? or desc.empty?
      for regex in @@task_failed_regexs.keys
        return @@task_failed_regexs[regex] if desc =~ regex
      end
      return nil
    end

    def self.check_task_triggered(desc)
      return nil if desc.nil? or desc.empty?
      for regex in @@task_triggered_regexs.keys
        return @@task_triggered_regexs[regex] if desc =~ regex
      end
      return nil
    end
  end
end