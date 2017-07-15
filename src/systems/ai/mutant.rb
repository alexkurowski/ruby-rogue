module System::AI::Mutant

  def self.ai entity
    player = World.player

    los = Los.check_line(
      from: entity.position,
      to: player.position,
      radius: entity.creature.sight
    )

    entity.npc.hostile = !player.creature.dead && los

    if entity.npc.hostile
      follow entity, player
    else
      wander entity
    end
  end


  internal def self.follow entity, player
    dx = player.position.x - entity.position.x
    dy = player.position.y - entity.position.y
    distance = Math.sqrt dx * dx + dy * dy

    if distance >= 2
      dx = (dx / distance).round
      dy = (dy / distance).round

      System::Movement.move entity, dx, 0
      System::Movement.move entity, 0, dy

    else

      attack entity, player
    end
  end


  internal def self.wander entity
    return if rand < 0.5

    dx = random -1, 2
    dy = random -1, 2

    System::Movement.move entity, dx, 0
    System::Movement.move entity, 0, dy
  end


  internal def self.attack entity, player
    System::Combat.kick entity, player
  end

end
