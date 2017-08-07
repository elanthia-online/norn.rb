module Generator
  module Bounty
    TYPES = [
      :none,
      :succeeded,
    ]

    def self.generate
      type = TYPES.sample
      OpenStruct.new(
        type: type,
        string: send(type)
      )
    end

    def self.none
      "You are not currently assigned a task."
    end

    def self.succeeded
      "You have succeeded in your task and can return to the Adventurer's Guild"
    end
  end
end