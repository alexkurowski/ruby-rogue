module System::Movement

  def self.move entity, dx, dy
    return false unless can_move? entity, dx, dy

    entity.position.x += dx
    entity.position.y += dy

    if entity.sprite?
      entity.sprite.offset.x -= Display.cell_width  * dx
      entity.sprite.offset.y -= Display.cell_height * dy
    end

    true
  end


  def self.can_move? entity, dx, dy
    e = Entities.find_at(entity.position.x + dx, entity.position.y + dy)

    Map.can_walk?(entity.position.x + dx, entity.position.y + dy) &&
    ( e.nil? || !e.position.blocking )
  end

end
