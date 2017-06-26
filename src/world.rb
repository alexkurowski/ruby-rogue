module World

  global :player_x,
         :player_y


  def self.init
    @player_x = Display.width  / 2
    @player_y = Display.height / 2
  end


  def self.update
    @player_x -= 1 if Input.action == :go_west
    @player_x += 1 if Input.action == :go_east
    @player_y -= 1 if Input.action == :go_north
    @player_y += 1 if Input.action == :go_south
  end

end
