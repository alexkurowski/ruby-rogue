module Game

  def self.play
    Input.init
    Display.open
    World.init

    main_game_loop

    Display.close
  end


  def self.main_game_loop
    until Input.quit

      frame_start

      Input.read
      World.update
      Display.render

      frame_end

    end
  end


  def self.frame_start
    @frame_start_time = Time.now
  end


  def self.frame_end
    elapsed = Time.now - @frame_start_time
    time_to_sleep = 1 / 60 - elapsed
    Terminal.delay time_to_sleep
  end

end
