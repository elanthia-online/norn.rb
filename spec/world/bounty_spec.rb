require 'spec_helper'

describe Norn::Bounty, "#parse" do
  it "can tell when we don't have a task" do
    bounty = described_class.new.sync described_class.parse "You are not currently assigned a task."
    expect(bounty.task).to eq :taskmaster
    expect(bounty.status).to be_nil
  end

  context "when assigned a task" do
    it "can tell we were assigned a cull task" do
      bounty = described_class.new.sync described_class.parse "It appears they have a creature problem they'd like you to solve"
      expect(bounty.task).to eq :cull
      expect(bounty.status).to eq :assigned
    end

    it "can tell we were assigned an heirloom task" do
      bounty = described_class.new.sync described_class.parse "It appears they need your help in tracking down some kind of lost heirloom"
      expect(bounty.task).to eq :heirloom
      expect(bounty.status).to eq :assigned
    end

    it "can tell we were assigned a skins task" do
      bounty = described_class.new.sync described_class.parse "The local furrier Furrier has an order to fill and wants our help"
      expect(bounty.task).to eq :skins
      expect(bounty.status).to eq :assigned
    end

    it "can tell we were assigned a gem task" do
      bounty = described_class.new.sync described_class.parse "The local gem dealer, GemTrader, has an order to fill and wants our help"
      expect(bounty.task).to eq :gem
      expect(bounty.status).to eq :assigned
    end


    it "can tell we were assigned a herb task" do
      bounty = described_class.new.sync described_class.parse "Hmm, I've got a task here from the town of Ta'Illistim.  The local herbalist's assistant, Jhiseth, has asked for our aid.  Head over there and see what you can do.  Be sure to ASK about BOUNTIES."
      expect(bounty.task).to eq :herb
      expect(bounty.status).to eq :assigned
      expect(bounty).to have_attributes({
        town: "Ta'Illistim",
      })
    end

    it "can tell we were assigned a rescue task" do
      bounty = described_class.new.sync described_class.parse "It appears that a local resident urgently needs our help in some matter"
      expect(bounty.task).to eq :rescue
      expect(bounty.status).to eq :assigned
    end

    it "can tell we were assigned a bandit task" do
      bounty = described_class.new.sync described_class.parse "The taskmaster told you:  \"Hmm, I've got a task here from the town of Ta'Illistim.  It appears they have a bandit problem they'd like you to solve.  Go report to one of the guardsmen just inside the Ta'Illistim City Gate to find out more.  Be sure to ASK about BOUNTIES.\""
      expect(bounty.task).to eq :bandit
      expect(bounty.status).to eq :assigned
    end
  end

  context "completed a task" do
    it "can tell we have completed a taskmaster task" do
      bounty = described_class.new.sync described_class.parse "You have succeeded in your task and can return to the Adventurer's Guild"
      expect(bounty.task).to eq :taskmaster
      expect(bounty.status).to eq :done
    end

    it "knows the heirloom item name for a completed heirloom task" do
      bounty = described_class.new.sync described_class.parse "You have located an elegantly carved jade tiara and should bring it back to one of the guardsmen just inside the Ta'Illistim City Gate."
      expect(bounty.task).to eq :heirloom
      expect(bounty.status).to eq :done
      expect(bounty.item).to eq "elegantly carved jade tiara"
      expect(bounty.town).to eq "Ta'Illistim"
    end

    it "knows the heirloom item name for a completed heirloom task" do
      bounty = described_class.new.sync described_class.parse "You have located some moonstone inset mithril earrings and should bring it back to one of the guardsmen just inside the Ta'Illistim City Gate."
      expect(bounty.task).to eq :heirloom
      expect(bounty.status).to eq :done
      expect(bounty.item).to eq "moonstone inset mithril earrings"
      expect(bounty.town).to eq "Ta'Illistim"
    end

    it "a completed heirloom task in the Landing" do
      bounty = described_class.new.sync described_class.parse "You have located a bloodstone studded hair pin and should bring it back to Quin Telaren of Wehnimer's Landing."
      expect(bounty.task).to eq :heirloom
      expect(bounty.status).to eq :done
      expect(bounty.item).to eq "bloodstone studded hair pin"
      expect(bounty.town).to eq "Wehnimer's Landing"
    end


    {
      "Ta'Illistim" => "You succeeded in your task and should report back to one of the guardsmen just inside the Ta'Illistim City Gate.",
      "Icemule Trace" => "You succeeded in your task and should report back to one of the Icemule Trace gate guards.",
      "Ta'Vaalor" => "You succeeded in your task and should report back to one of the Ta'Vaalor gate guards.",
      "Vornavis"  => "You succeeded in your task and should report back to one of the Vornavis gate guards.",
      "Wehnimer's Landing" => "You succeeded in your task and should report back to Quin Telaren of Wehnimer's Landing.",
      "Kharam-Dzu" => "You succeeded in your task and should report back to the dwarven militia sergeant near the Kharam-Dzu town gates.",
    }.each do |(town, task_desc)|
      it "in #{town}" do
        bounty = described_class.new.sync described_class.parse task_desc
        expect(bounty.task).to eq :dangerous
        expect(bounty.status).to eq :done
        expect(bounty.town).to eq town
      end
    end
  end

  context "triggered a task" do
      it "can tell we have triggered a rescue task for a male child" do
        bounty = described_class.new.sync described_class.parse "You have made contact with the child you are to rescue and you must get him back alive to one of the guardsmen just inside the Sapphire Gate."
        expect(bounty.task).to eq :rescue
        expect(bounty.status).to eq :triggered
      end

      it "can tell we have triggered a rescue task for a female child" do
        bounty = described_class.new.sync described_class.parse "You have made contact with the child you are to rescue and you must get her back alive to one of the guardsmen just inside the gate."
        expect(bounty.task).to eq :rescue
        expect(bounty.status).to eq :triggered
      end

      it "can tell we have triggered a dangerous task (male critter)" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to hunt down and kill a particularly dangerous CRITTER that has established a territory in near A PLACE.  You have provoked his attention and now you must kill him!"
        expect(bounty.task).to eq :dangerous
        expect(bounty.status).to eq :triggered
      end

      it "can tell we have triggered a dangerous task (female critter)" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to hunt down and kill a particularly dangerous CRITTER that has established a territory in near A PLACE.  You have provoked her attention and now you must kill her!"
        expect(bounty.task).to eq :dangerous
        expect(bounty.status).to eq :triggered
      end

      it "can tell we have triggered a dangerous task (unsexed critter)" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to hunt down and kill a particularly dangerous CRITTER that has established a territory in near A PLACE.  You have provoked its attention and now you must kill it!"
        expect(bounty.task).to eq :dangerous
        expect(bounty.status).to eq :triggered
    end

      it "can tell we have triggered a dangerous task (return to area)" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to hunt down and kill a particularly dangerous CRITTER that has established a territory in near A PLACE.  You have provoked her attention and now you must return to where you left her and kill her!"
        expect(bounty.task).to eq :dangerous
        expect(bounty.status).to eq :triggered
      end
  end

  context "have an unfinished task" do
    it "can tell we have an unfinished bandit task" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to suppress bandit activity on Sylvarraend Road near Ta'Illistim.  You need to kill 20 of them to complete your task."
      expect(bounty.task).to eq :bandit
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ area: "Sylvarraend Road", number: 20, creature: 'bandit' })
    end

    it "can tell we have an unfinished cull task" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to suppress glacial morph activity in Gossamer Valley near Ta'Illistim.  You need to kill 24 of them to complete your task."
      expect(bounty.task).to eq :cull
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ creature: "glacial morph", area: "Gossamer Valley", number: 24 })
    end

    it "can tell we have an unfinished cull task (ASSIST)" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to help Brikus suppress war griffin activity in Old Ta'Faendryl.  You need to kill 14 of them to complete your task."
      expect(bounty.task).to eq :cull
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ creature: "war griffin", area: "Old Ta'Faendryl", number: 14 })
    end

    context "can tell we have an unfinished heirloom task" do
      it "can parse a loot task" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to recover a dainty pearl string bracelet that an unfortunate citizen lost after being attacked by a festering taint in Old Ta'Faendryl.  The heirloom can be identified by the initials VF engraved upon it.  Hunt down the creature and LOOT the item from its corpse."
        expect(bounty.task).to eq :heirloom
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          action: "loot", area: "Old Ta'Faendryl", 
          creature: "festering taint",
          item: "dainty pearl string bracelet"
        })
      end

      it "can parse a loot task" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to recover an onyx-inset copper torc that an unfortunate citizen lost after being attacked by a centaur near Darkstone Castle near Wehnimer's Landing.  The heirloom can be identified by the initials ZK engraved upon it.  Hunt down the creature and LOOT the item from its corpse."
        expect(bounty.task).to eq :heirloom
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          action: "loot", area: "Darkstone Castle", creature: "centaur",
          item: "onyx-inset copper torc"
        })
      end

      it "can parse a search task" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to recover an interlaced gold and ora ring that an unfortunate citizen lost after being attacked by a black forest viper in the Blighted Forest near Ta'Illistim.  The heirloom can be identified by the initials MS engraved upon it.  SEARCH the area until you find it."
        expect(bounty.task).to eq :heirloom
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          action: "search", area: "Blighted Forest", creature: "black forest viper",
          item: "interlaced gold and ora ring"
        })
      end
    end

    context "can tell we have an unfinished skins task" do
      it "with a one word town name" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to retrieve 8 madrinol skins of at least fair quality for Gaedrein in Ta'Illistim.  You can SKIN them off the corpse of a snow madrinol or purchase them from another adventurer.  You can SELL the skins to the furrier as you collect them.\""
        expect(bounty.task).to eq :skins
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          creature: "snow madrinol",
          quality: "fair",
          number: 8,
          skin: "madrinol skin",
          town: "Ta'Illistim",
        })
      end

      it "with a multipart town name" do
        bounty = described_class.new.sync described_class.parse "You have been tasked to retrieve 5 thrak tails of at least exceptional quality for the furrier in the Company Store in Kharam-Dzu.  You can SKIN them off the corpse of a red-scaled thrak or purchase them from another adventurer.  You can SELL the skins to the furrier as you collect them.\""
        expect(bounty.task).to eq :skins
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          creature: "red-scaled thrak",
          quality: "exceptional",
          number: 5,
          skin: "thrak tail",
          town: "Kharam-Dzu",
        })
      end
    end

    it "can tell we have an unfinished gem task" do
      bounty = described_class.new.sync described_class.parse "The gem dealer in Ta'Illistim, Tanzania, has received orders from multiple customers requesting an azure blazestar.  You have been tasked to retrieve 10 of them.  You can SELL them to the gem dealer as you find them."
      expect(bounty.task).to eq :gem
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ jewel: "azure blazestar", number: 10, town: "Ta'Illistim" })
    end

    it "can tell we have an unfinished escort task" do
      bounty = described_class.new.sync described_class.parse "The taskmaster told you:  \"I've got a special mission for you.  A certain client has hired us to provide a protective escort on his upcoming journey.  Go to the area just inside the Sapphire Gate and WAIT for him to meet you there.  You must guarantee his safety to Zul Logoth as soon as you can, being ready for any dangers that the two of you may face.  Good luck!\""
      expect(bounty.task).to eq :escort
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ destination: "Zul Logoth", start: "the area just inside the Sapphire Gate" })
    end

    it "can tell we have an unfinished escort task" do
      bounty = described_class.new.sync described_class.parse "I've got a special mission for you.  A certain client has hired us to provide a protective escort on her upcoming journey.  Go to the south end of North Market and WAIT for her to meet you there.  You must guarantee her safety to Zul Logoth as soon as you can, being ready for any dangers that the two of you may face.  Good luck!"
      expect(bounty.task).to eq :escort
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ destination: "Zul Logoth", start: "the south end of North Market" })
    end

    context 'for herbs' do
      it "can tell we have an unfinished herb task" do
        bounty = described_class.new.sync described_class.parse "The herbalist's assistant in Ta'Illistim, Jhiseth, is working on a concoction that requires a sprig of holly found in Griffin's Keen near Ta'Illistim.  These samples must be in pristine condition.  You have been tasked to retrieve 6 samples."
        expect(bounty.task).to eq :herb
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          herb: "sprig of holly",
          area: "Griffin's Keen",
          number: 6,
          town: "Ta'Illistim",
        })
      end

      it 'can parse an Icemule herb task' do
        bounty = described_class.new.sync described_class.parse "The healer in Icemule Trace, Mirtag, is working on a concoction that requires a withered deathblossom found in the Rift.  These samples must be in pristine condition.  You have been tasked to retrieve 7 samples."
        expect(bounty.task).to eq :herb
        expect(bounty.status).to eq :unfinished
        expect(bounty).to have_attributes({
          herb: "withered deathblossom",
          area: "Rift",
          number: 7,
          town: "Icemule Trace",
        })
      end
    end

    it "can tell we have an unfinished dangerous task" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to hunt down and kill a particularly dangerous gnarled being that has established a territory in Old Ta'Faendryl.  You can get its attention by killing other creatures of the same type in its territory."
      expect(bounty.task).to eq :dangerous
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ creature: "being", area: "Old Ta'Faendryl" })
    end

    it "can tell we have an unfinished rescue task" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to rescue the young runaway son of a local citizen.  A local divinist has had visions of the child fleeing from a black forest ogre in the Blighted Forest near Ta'Illistim.  Find the area where the child was last seen and clear out the creatures that have been tormenting him in order to bring him out of hiding."
      expect(bounty.task).to eq :rescue
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ area: "Blighted Forest", creature: "black forest ogre" })
    end

    it "can tell we have an unfinished rescue task" do
      bounty = described_class.new.sync described_class.parse "You have been tasked to rescue the young kidnapped daughter of a local citizen.  A local divinist has had visions of the child fleeing from a stone sentinel in Darkstone Castle near Wehnimer's Landing.  Find the area where the child was last seen and clear out the creatures that have been tormenting her in order to bring her out of hiding."
      expect(bounty.task).to eq :rescue
      expect(bounty.status).to eq :unfinished
      expect(bounty).to have_attributes({ area: "Darkstone Castle", creature: "stone sentinel" })
    end
  end

  it "can recognize a failed bounty" do
    bounty = described_class.new.sync described_class.parse "You have failed in your task.  Return to the Adventurer's Guild for further instructions."
    expect(bounty.status).to eq :failed
    expect(bounty.task).to eq :taskmaster
  end

  it 'can recognize a failed rescue task' do
    bounty = described_class.new.sync described_class.parse "The child you were tasked to rescue is gone and your task is failed.  Report this failure to the Adventurer's Guild."
    expect(bounty.status).to eq :failed
    expect(bounty.task).to eq :taskmaster
  end
end