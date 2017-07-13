module World

  global :player,
         :turn,
         :initial_pc_state,
         :initial_npc_state


  def self.init
    Map.init
    Entities.init
    Camera.init
    Fov.init
    Los.init

    place_player
    place_npc

    @turn = :player

    @active_systems = [
      System::PcActions,
      System::NpcActions,
      System::SpriteMovement
    ]
  end


  internal def self.place_player
    return if @initial_pc_state.nil?

    Entities.prefab :player do |entity|
      entity.position.x = @initial_pc_state.x
      entity.position.y = @initial_pc_state.y

      @player = entity

      Camera.jump_to entity.position.x, entity.position.y - 10
    end
  end


  internal def self.place_npc
    return if @initial_npc_state.nil?

    @initial_npc_state.each do |npc|
      Entities.prefab npc.type do |entity|
        entity.position.x = npc.position.x
        entity.position.y = npc.position.y
      end
    end
  end


  def self.update
    @active_systems.each do |system_name|
      system_name.send :run
    end
  end


  def self.render
    Camera.update
    Fov.update

    Display.render_start

    render_tiles
    render_entities
    render_ui

    Display.render_finish
  end


  internal def self.render_tiles
    return unless Camera.dirty?

    Display.clear_tiles

    offset_x = -Camera.dx.floor
    offset_y = -Camera.dy.floor
    Display.set_tile_offset offset_x, offset_y

    for j in 0...Display.height
      for i in 0...Display.width

        x   = Camera.x + i
        y   = Camera.y + j
        fov = Fov.at x, y

        if fov == :none
          Display.add_empty_tile
          next
        end

        tile  = Map.tile x, y
        char  = tile.char
        color = tile.color[fov]

        Display.add_tile char, color

      end

      Display.add_newline_tile
    end

    Display.draw_tiles
  end


  internal def self.render_entities
    Display.clear_entities

    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |entity|
      if entity_is_on_screen? entity

        fov = Fov.at entity.position.x, entity.position.y

        next unless fov == :full or
                    entity.player?

        x     = entity.position.x - Camera.x
        y     = entity.position.y - Camera.y
        dx    = entity.sprite.dx - Camera.dx
        dy    = entity.sprite.dy - Camera.dy
        char  = entity.sprite.char.ord
        color = entity.sprite.color

        Display.draw_entity x, y, dx, dy, char, color

      end
    end
  end


  internal def self.entity_is_on_screen? entity
    not entity.sprite.char.empty? &&
    entity.position.x >= Camera.x &&
    entity.position.y >= Camera.y &&
    entity.position.x < Camera.x + Display.width &&
    entity.position.y < Camera.y + Display.height
  end


  internal def self.render_ui
    Display.clear_ui

    entity = @player

    if entity.player.mode == :fire
      draw_line_of_fire entity
    end

    if entity.player.mode == :fire or
       entity.player.mode == :examine
    then draw_cursor entity
    else draw_mouse_cursor
    end

    if Game.debug
      Terminal.print 0, 0, "Player: #{entity.position.x}:#{entity.position.y}"
      Terminal.print 0, 1, "Cursor: #{Input.mouse_x + Camera.x}:#{Input.mouse_y + Camera.y}"
    end
  end


  internal def self.draw_line_of_fire entity
    line = Los.line_of_fire(
      from: entity.position,
      to: entity.player.cursor,
      radius: entity.creature.sight
    ).reject do |point|
      Fov.at(point.x, point.y) != :full ||
      point.x == entity.position.x &&
      point.y == entity.position.y
    end.map do |point|
      { x: point.x - Camera.x, y: point.y - Camera.y }
    end

    char  = '¿'.ord
    color = '#aaff0000'

    Display.draw_ui_set line, char, color
  end


  internal def self.draw_cursor entity
    x     = entity.player.cursor.x - Camera.x
    y     = entity.player.cursor.y - Camera.y
    char  = '¿'.ord
    color = Terminal.color_from_name 'white'

    Display.draw_ui x, y, char, color
  end


  internal def self.draw_mouse_cursor
    x     = Input.mouse_x
    y     = Input.mouse_y
    char  = '¿'.ord
    color = Terminal.color_from_name 'white'

    Display.draw_ui x, y, char, color
  end

end
