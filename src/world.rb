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

    render_tiles
    render_entities
  end


  internal def self.render_tiles
    return unless Camera.dirty?

    offset_x = -Camera.dx.floor
    offset_y = -Camera.dy.floor
    bkcolor  = Display.background

    output = ""
    output << "[offset=#{ offset_x },#{ offset_y }]"
    output << "[bkcolor=##{ bkcolor }]"

    for j in 0...Display.height
      for i in 0...Display.width

        x   = Camera.x + i
        y   = Camera.y + j
        fov = Fov.at x, y

        if fov == :none or i == 0 or j == 0
          output << ' '
          next
        end

        tile = Map.tile x, y

        output << "[color=#{ tile.color[fov] }]"
        output << tile.char

      end
      output << "\n"
    end

    Terminal.print 0, 0, output
  end


  internal def self.render_entities
    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |entity|
      if entity_is_on_screen? entity

        fov = Fov.at entity.position.x, entity.position.y

        next unless fov == :full or
                    entity.include? :player

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
