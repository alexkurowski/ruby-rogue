module World

  global :player_x,
         :player_y


  def self.init
    Map.generate
    Entities.init

    Entities.add(
      :position,
      :sprite,
      :player
    ) do |e|
      e.position[:x] = Display.width  / 2
      e.position[:y] = Display.height / 2
      e.sprite[:char] = '@'
    end
  end


  def self.update
    System.player_movement
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
        Terminal.put e.position.x, e.position.y, e.sprite.char.ord
      end
    end
  end

end
