module Generator
  module Status
    STATUSES = [
      "STUNNED",
      "PRONE",
      "KNEELING",
      "SITTING",
      "WEBBED",
      "GROUPED",
    ]

    STATES = [
      "y",
      "n",
    ]

    def self.generate
      kind    = STATUSES.sample
      visible = STATES.sample
      OpenStruct.new( 
        string:  "<indicator id='Icon#{kind}' visible='#{visible}'/>",
        visible: visible,
        kind:    kind,
      )
    end
  end
end