module World

  global :player_x,
         :player_y


  def self.init
    Map.generate
    Entities.init

    Entities.prefab :player do |e|
      e.position[:x] = Display.width  / 2
      e.position[:y] = Display.height / 2
      e.sprite[:char] = '@'
    end

    @active_systems = [ :player_actions ]
  end


  def self.update
    @active_systems.each do |system|
      System.send system
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
        Terminal.put e.position.x, e.position.y, e.sprite.char.ord
      end
    end
  end

end
