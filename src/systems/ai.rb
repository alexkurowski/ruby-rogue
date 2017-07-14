module System::AI

  def self.run
    return unless World.turn == :npc

    entities = Entities.filter_by_components :npc

    entities.map do |entity|
      next if entity.creature.dead

      case entity.npc.ai
      when 'mutant' then Mutant.ai entity
      end
    end

    World.turn = :player
  end

end
