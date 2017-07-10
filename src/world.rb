module World

  global :player_x,
         :player_y


  def self.init
    Map.init
    Entities.init
    Camera.init
    Fov.init

    Entities.prefab :player do |e|
      e.position[:x] = @player_x.floor
      e.position[:y] = @player_y.floor
      e.sprite[:char] = '@'

      Camera.jump_to e.position.x, e.position.y - 10
    end

    @active_systems = [
      :player_actions,
      :sprite_movement
    ]
  end


  def self.update
    @active_systems.each do |system_name|
      System.send system_name
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
                    entity.include? :player

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

    entity = Entities.find_by_component :player

    if entity.player.mode == :fire or
       entity.player.mode == :examine
    then draw_cursor entity
    else draw_mouse_cursor
    end
  end


  internal def self.draw_cursor entity
    x     = entity.player.cx - Camera.x
    y     = entity.player.cy - Camera.y
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
