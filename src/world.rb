module World

  global :player_x,
         :player_y


  def self.init
    Map.generate

    @player_x = Display.width  / 2
    @player_y = Display.height / 2
  end


  def self.update
    @player_x -= 1 if Input.action == :go_west
    @player_x += 1 if Input.action == :go_east
    @player_y -= 1 if Input.action == :go_north
    @player_y += 1 if Input.action == :go_south
  end

  def self.render
    for i in 0...Display.width
      for j in 0...Display.height
        Terminal.put i, j, Map.tile(i, j).char
      end
    end

    Terminal.put player_x, player_y, '@'.ord
  end

end
