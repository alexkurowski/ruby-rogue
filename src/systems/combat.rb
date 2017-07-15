module System::Combat

  def self.kick entity, target
    deal_damage entity, target
  end


  def self.kick_at entity, target_point
    target = Entities.find_at target_point

    deal_damage entity, target
  end


  def self.shoot_at entity, target_point
    line, target = Los.line_of_fire_and_target(
      from: entity.position,
      to: target_point,
      radius: entity.creature.sight
    )

    if target.nil?
      x1 = line.first.x
      y1 = line.first.y
      x2 = line.last.x
      y2 = line.last.y

      Log.add "but hit nothing."

      puts "No mojo. Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
    else
      x1 = line.first.x
      y1 = line.first.y
      x2 = line.last.x
      y2 = line.last.y

      direct = line.first.x == entity.position.x &&
               line.first.y == entity.position.y

      Log.add "and you hit a #{ target.npc.ai.to_s.capitalize }#{ direct ? '!' : '.' }"

      deal_damage entity, target

      puts "#{direct ? 'Direct hit!' : 'Hit.'} Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
    end
  end


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
    dx = (dx / distance).round * 2
    dy = (dy / distance).round * 2

    if Map.can_walk? target.position.x - dx, target.position.y - dy
      target.position.x -= dx
      target.position.y -= dy
      target.sprite.offset.x += Display.cell_width  * dx
      target.sprite.offset.y += Display.cell_height * dy
    end

    create_bloodstain target.position

    if target.player?
      target.creature.dead = true
      target.sprite.color  = '#ffaa0000'

      Log.add "You die..."
    else

      Entities.remove target

      Log.add "#{ target.npc.ai.to_s.capitalize } dies."
    end
  end


  internal def self.create_bloodstain position
    for x in -1..1
      for y in -1..1
        if rand < 0.4

          Map.set_status position.x + x, position.y + y, :bloody

        end
      end
    end
  end

end
