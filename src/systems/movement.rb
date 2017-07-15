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
    x = entity.position.x + dx
    y = entity.position.y + dy

    return false unless Map.can_walk? x, y

    e = Entities.find_at x, y

    return e.nil? || !e.physical&.blocking
  end

end
