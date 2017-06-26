module Game

  def self.play
    Display.open
    World.init

    run_game_loop

    Display.close
  end


  def self.run_game_loop
    loop do
      Display.frame_start

      Input.read
      World.update
      Display.render

      Display.frame_end

      break if Input.quit
    end
  end

end
