require "norn/util/memory-store"
require "ostruct"

class Bounty < OpenStruct
  module DSL
    NPCS = %r{
       guard|sergeant|Felinium|clerk|purser|taskmaster
      |gemcutter|jeweler|akrash|kris|Ghaerdish|Furryback
      |healer|dealer|Ragnoz|Maraene|Kelph
      |Areacne|Jhiseth|Gaedrein
    }x

    Herbalist = %r{
      illistim|vaalor|legendary rest|solhaven
    }x
  
    BOUNTIES = OpenStruct.new(
      creature_problem: /It appears they have a creature problem they\'d like you to solve/,
      report_to_guard:  /^You succeeded in your task and should report back to/,
      get_skin_bounty:  /The local furrier/,
      heirloom_found:   /^You have located the heirloom and should bring it back to/,
      cooldown:         /^You are not taskly assigned a task.  You will be eligible for new task assignment in about (?<minutes>.*?) minute(s)./,
      
      dangerous: /You have been tasked to hunt down and kill a particularly dangerous (?<creature>.*) that has established a territory (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
      succeeded: /^You have succeeded in your task and can return to the Adventurer's/,
      heirloom:  /^You have been tasked to recover (a|an|some) (?<heirloom>.*?) that an unfortunate citizen lost after being attacked by (a|an|some) (?<creature>.*?) (?:in|on|around|near|by) (?<area>.*?)(| near (?<realm>.*?))\./,


      get_rescue:      /It appears that a local resident urgently needs our help in some matter/,
      get_bandits:     /It appears they have a bandit problem they'd like you to solve./,
      get_heirloom:    /It appears they need your help in tracking down some kind of lost heirloom/,
      get_herb_bounty: /local herbalist|local healer|local alchemist/,
      get_gem_bounty:  /The local gem dealer, (?<npc>[a-zA-Z ]+), has an order to fill and wants our help/,

      herb:   /requires (?:a |an |)(?<herb>.*?) found (?:in|on|around|near) (?<area>.*?)(| (near|between) (?<realm>.*?)).  These samples must be in pristine condition.  You have been tasked to retrieve (?<number>[\d]+)/,
      escort: /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to (?<destination>.*?) as soon as/,
      gem:    /has received orders from multiple customers requesting (?:a|an|some) (?<gem>[a-zA-Z '-]+).  You have been tasked to retrieve (?<number>[0-9]+)/,

      cull:    /^You have been tasked to suppress (?<creature>(?!bandit).*) activity (?:in|on|around) (?<area>.*?)(| (near|between) (?<realm>.*?)).  You need to kill (?<number>[0-9]+)/,
      bandits: /^You have been tasked to suppress bandit activity (?:in|on|around) (?<area>.*?) (?:near|between|under) (?<realm>.*?).  You need to kill (?<number>[0-9]+)/,

      rescue:  /A local divinist has had visions of the child fleeing from (?:a|an) (?<creature>.*) (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
      failed:  /You have failed in your task/,
      none:    /You are not taskly assigned a task/,
      skin:    /^You have been tasked to retrieve (?<number>\d+) (?<skin>.*?) of at least (?<quality>.*?) quality for (?<buyer>.*?) in (?<realm>.*?)\.\s+You can SKIN them off the corpse of (a|an|some) (?<creature>.*?) or/,
      
      help_bandits: /You have been tasked to help (?<partner>.*?) suppress bandit activity (in|on|around) (?<area>.*?)(| near (?<realm>.*?)).  You need to kill (?<number>[0-9]+)/
    )
  end

  @@store = MemoryStore.new
  
  def Bounty.put(bounty)
    @@store.put(:bounty, 
      Bounty.match(bounty))
  end

  def Bounty.parse(bounty)
    type, patt = DSL::BOUNTIES.each_pair.find do |type, exp|
      exp.match bounty
    end
    return nil unless patt
    bounty = patt.match(bounty).to_struct.to_h
    bounty[:raw]  = str
    bounty[:type] = type
    Bounty.new **bounty
  end

  def Bounty.fetch(key = :bounty, default = nil)
    @@store.fetch(bounty, default)
  end

  def Bounty.done?
    succeeded?
  end

  def Bounty.method_missing(method)
    str = method.to_s

    if str.chars.last == "?"
      return Bounty.type == str.chars.take(str.length-1).join.to_sym
    end

    Bounty.fetch.send(method)
  end
end