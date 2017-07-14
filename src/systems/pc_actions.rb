module System::PcActions

  def self.run
    return unless Input.action
    return unless World.turn == :player

    entity = World.player

    case Input.action
    when :go_west       then move entity, -1,  0
    when :go_east       then move entity, +1,  0
    when :go_north      then move entity,  0, -1
    when :go_south      then move entity,  0, +1
    when :go_north_west then move entity, -1, -1
    when :go_north_east then move entity, +1, -1
    when :go_south_west then move entity, -1, +1
    when :go_south_east then move entity, +1, +1
    when :wait          then wait
    when :examine       then examine entity
    when :fire          then fire entity
    when :fire!         then mouse_fire entity
    when :cancel        then cancel entity
    end
  end


  def self.move entity, dx, dy
    case entity.player.mode
    when :normal
      move_entity entity, dx, dy
    when :fire, :examine
      move_cursor entity, dx, dy
    end
  end


  def self.move_entity entity, dx, dy
    moved = System::Movement.move entity, dx, dy
    end_turn 1 if moved
  end


  def self.can_move? entity, dx, dy
    e = Entities.find_at(entity.position.x + dx, entity.position.y + dy)

    Map.can_walk?(entity.position.x + dx, entity.position.y + dy) &&
    ( e.nil? || !e.position.blocking )
  end


  def self.move_cursor entity, dx, dy
    entity.player.cursor.x += dx unless entity.player.cursor.x + dx < Camera.x or
                                        entity.player.cursor.x + dx > Camera.x + Display.width - 1
    entity.player.cursor.y += dy unless entity.player.cursor.y + dy < Camera.y or
                                        entity.player.cursor.y + dy > Camera.y + Display.height - 1
  end


  def self.examine entity
    case entity.player.mode
    when :normal
      set_cursor_mode entity, :examine

    when :examine
      entity.player.mode = :normal
    end
  end


  def self.fire entity
    case entity.player.mode
    when :normal
      set_cursor_mode entity, :fire

    when :fire
      shoot entity
      entity.player.mode = :normal
    end
  end


  def self.mouse_fire entity
    if entity.player.mode == :normal
      entity.player.cursor.x = Input.cursor.x
      entity.player.cursor.y = Input.cursor.y
      shoot entity
    end
  end


  def self.shoot entity
    return if entity.player.cursor.x == entity.position.x and
              entity.player.cursor.y == entity.position.y

    line, target = Los.line_of_fire_and_target(
      from: entity.position,
      to: entity.player.cursor,
      radius: entity.creature.sight
    )

    if target.nil?
      x1 = line.first.x
      y1 = line.first.y
      x2 = line.last.x
      y2 = line.last.y

      puts "No mojo. Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
    else
      x1 = line.first.x
      y1 = line.first.y
      x2 = line.last.x
      y2 = line.last.y

      direct = line.first.x == entity.position.x &&
               line.first.y == entity.position.y

      Combat.deal_damage entity, target

      puts "#{direct ? 'Direct hit!' : 'Hit.'} Create a bullet from #{x1}:#{y1} to #{x2}:#{y2}"
    end

    end_turn 1
  end


  def self.set_cursor_mode entity, mode
    entity.player.cursor.x = entity.position.x
    entity.player.cursor.y = entity.position.y
    entity.player.mode = mode
  end


  def self.cancel entity
    entity.player.mode = :normal if entity.player.mode == :fire or
                                    entity.player.mode == :examine
  end


  def self.wait
    end_turn 1
  end


  def self.end_turn input_delay
    World.turn = :npc
    Input.disable_for input_delay
    Camera.set_dirty
  end

end
