module System::PcActions

  def self.run
    entity = World.player

    Input.action = :wait if entity.creature.dead == true

    return unless Input.action
    return unless World.turn == :player

    case Input.action
    when :go_west       then move entity, -1,  0
    when :go_east       then move entity, +1,  0
    when :go_north      then move entity,  0, -1
    when :go_south      then move entity,  0, +1
    when :go_north_west then move entity, -1, -1
    when :go_north_east then move entity, +1, -1
    when :go_south_west then move entity, -1, +1
    when :go_south_east then move entity, +1, +1
    when :examine       then examine entity
    when :fire          then fire entity
    when :fire!         then mouse_fire entity
    when :wait          then wait
    when :cancel        then cancel entity
    end
  end


  internal def self.move entity, dx, dy
    case entity.player.mode
    when :normal
      move_entity entity, dx, dy
    when :fire, :examine
      move_cursor entity, dx, dy
    end
  end


  internal def self.move_entity entity, dx, dy
    moved = System::Movement.move entity, dx, dy
    end_turn 1 if moved
  end


  internal def self.move_cursor entity, dx, dy
    entity.player.cursor.x += dx unless entity.player.cursor.x + dx < Camera.position.x or
                                        entity.player.cursor.x + dx > Camera.position.x + Display.width - 1
    entity.player.cursor.y += dy unless entity.player.cursor.y + dy < Camera.position.y or
                                        entity.player.cursor.y + dy > Camera.position.y + Display.height - 1
  end


  internal def self.examine entity
    case entity.player.mode
    when :normal
      set_cursor_mode entity, :examine

    when :examine
      entity.player.mode = :normal
    end
  end


  internal def self.fire entity
    case entity.player.mode
    when :normal
      set_cursor_mode entity, :fire

    when :fire
      shoot entity
      entity.player.mode = :normal
    end
  end


  internal def self.set_cursor_mode entity, mode
    entity.player.cursor.x = entity.position.x
    entity.player.cursor.y = entity.position.y
    entity.player.mode = mode
  end


  internal def self.mouse_fire entity
    if entity.player.mode == :normal
      entity.player.cursor.x = Input.cursor.x
      entity.player.cursor.y = Input.cursor.y
      shoot entity
    end
  end


  internal def self.shoot entity
    return if entity.player.cursor.x == entity.position.x and
              entity.player.cursor.y == entity.position.y

    System::Combat.shoot_at entity, entity.player.cursor
    end_turn 1
  end


  internal def self.cancel entity
    entity.player.mode = :normal if entity.player.mode == :fire or
                                    entity.player.mode == :examine
  end


  internal def self.wait
    end_turn 1
  end


  internal def self.end_turn input_delay
    World.turn = :npc
    Input.disable_for input_delay
    Camera.set_dirty
  end

end
