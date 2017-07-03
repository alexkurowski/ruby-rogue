module World

  global :player_x,
         :player_y


  def self.init
    Camera.init
    Entities.init
    Map.generate

    Entities.prefab :player do |e|
      e.position[:x] = @player_x
      e.position[:y] = @player_y
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

    Terminal.bkcolor Terminal.color_from_argb 255, 6, 8, 14

    render_tiles
    render_entities
  end


  internal def self.render_tiles
    return unless Camera.dirty?

    Display.map do |i, j|

      x    = Camera.x + i
      y    = Camera.y + j
      dx   = -Camera.dx
      dy   = -Camera.dy
      tile = Map.tile x, y

      Terminal.color tile.color.full
      Terminal.put_ext i, j, dx, dy, tile.char

    end
  end


  internal def self.render_entities
    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |entity|
      if entity_is_on_screen? entity

        x    = entity.position.x - Camera.x
        y    = entity.position.y - Camera.y
        dx   = entity.sprite.dx - Camera.dx
        dy   = entity.sprite.dy - Camera.dy
        char = entity.sprite.char.ord

        Terminal.color entity.sprite.color
        Terminal.put_ext x, y, dx, dy, char

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

end
