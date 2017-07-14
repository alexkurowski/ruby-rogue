module Combat

  def self.deal_damage entity, target
    return if not entity.creature? or not target.creature?

    target.creature.hp -= 1

    die entity, target if target.creature.hp <= 0
  end


  def self.die entity, target
    return if not entity.creature? or not target.creature?

    dx = entity.position.x - target.position.x
    dy = entity.position.y - target.position.y
    distance = Math.sqrt dx * dx + dy * dy
    dx = (dx / distance).round
    dy = (dy / distance).round

    if Map.can_walk? target.position.x - dx, target.position.y - dy
      target.position.x -= dx
      target.position.y -= dy
      target.sprite.offset.x += Display.cell_width  * dx
      target.sprite.offset.y += Display.cell_height * dy
    end

    target.creature.dead = true
    target.sprite.color = "#80#{target.sprite.color[3..-1]}"
    target.position.blocking = false
  end

end
