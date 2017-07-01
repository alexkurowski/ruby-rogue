module World

  global :player_x,
         :player_y


  def self.init
    Camera.init
    Entities.init
    Map.generate

    Entities.prefab :player do |e|
      e.position[:x] = Display.width  / 2
      e.position[:y] = Display.height / 2
      e.sprite[:char] = '@'
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

    render_tiles
    render_entities
  end


  def self.render_tiles
    Display.map do |i, j|

      cell_x = Camera.left_cell + i
      cell_y = Camera.top_cell  + j

      dx = cell_x * Display.cell_width  - Camera.dx
      dy = cell_y * Display.cell_height - Camera.dy
      tile = Map.tile(cell_x, cell_y).char

      Terminal.put_ext 0, 0, dx, dy, tile

    end
  end


  def self.render_entities
    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |entity|
      if entity_is_on_screen? entity

        dx = entity.position.x * Display.cell_width  - Camera.dx + entity.sprite.dx
        dy = entity.position.y * Display.cell_height - Camera.dy + entity.sprite.dy
        char = entity.sprite.char.ord

        Terminal.put_ext 0, 0, dx, dy, char

      end
    end
  end


  def self.entity_is_on_screen? entity
    not entity.sprite.char.empty? &&
    entity.position.x >= Camera.left_cell &&
    entity.position.y >= Camera.top_cell &&
    entity.position.x < Camera.left_cell + Display.width &&
    entity.position.y < Camera.top_cell  + Display.height
  end

end
