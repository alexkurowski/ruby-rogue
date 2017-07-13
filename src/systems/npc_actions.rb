module System::NpcActions
  def self.run
    return unless World.turn == :npc

    entities = Entities.filter_by_component :npc
    player   = World.player

    entities.map do |entity|
      zombie_ai entity, player if entity.creature?
    end

    World.turn = :player
  end


  def self.zombie_ai entity, player
    los = Los.check_line(
      from: entity.position,
      to: player.position,
      radius: entity.creature.sight
    )

    entity.npc.hostile = los

    if entity.npc.hostile
      follow entity, player
    else
      wander entity, player
    end
  end


  def self.follow entity, player
    dx = player.position.x - entity.position.x
    dy = player.position.y - entity.position.y
    distance = Math.sqrt dx * dx + dy * dy

    dx = (dx / distance).round
    dy = (dy / distance).round

    move entity, dx, dy
  end


  def self.wander entity, player
    return if rand < 0.5

    dx = random -1, 2
    dy = random -1, 2

    move entity, dx, dy
  end


  def self.move entity, dx, dy
    if can_move? entity, dx, 0
      entity.position.x += dx
      entity.sprite.dx -= Display.cell_width * dx
    end

    if can_move? entity, 0, dy
      entity.position.y += dy
      entity.sprite.dy -= Display.cell_height * dy
    end
  end


  def self.can_move? entity, dx, dy
    Map.can_walk?(entity.position.x + dx, entity.position.y + dy) &&
    Entities.find_at(entity.position.x + dx, entity.position.y + dy).nil?
  end
end
