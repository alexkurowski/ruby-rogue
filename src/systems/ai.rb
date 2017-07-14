module System::AI

  def self.run
    return unless World.turn == :npc

    entities = Entities.filter_by_components :npc, :creature

    entities.map do |entity|
      next if entity.creature.dead

      Zombie.ai entity if entity.creature?
    end

    World.turn = :player
  end

end
