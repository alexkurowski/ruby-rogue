module World

  global :player_x,
         :player_y


  def self.init
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
    for i in 0...Display.width
      for j in 0...Display.height
        Terminal.put i, j, Map.tile(i, j).char
      end
    end

    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |e|
      unless e.sprite.char.empty?
        Terminal.put_ext(
          e.position.x,
          e.position.y,
          e.sprite.dx,
          e.sprite.dy,
          e.sprite.char.ord
        )
      end
    end
  end

end
