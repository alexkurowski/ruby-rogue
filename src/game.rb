module Game

  global :debug


  def self.play
    @debug = true

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
      World.render

      frame_finish

    end
  end


  internal def self.frame_start
    @frame_start_time = Time.now
  end


  internal def self.frame_finish
    fps_target = 30

    elapsed = Time.now - @frame_start_time
    time_to_sleep = 1.0 / fps_target - elapsed
    Terminal.delay time_to_sleep

    return unless @debug
    if time_to_sleep <= 0
      puts "FPS: #{ ( fps_target / elapsed / fps_target ).floor } / #{ fps_target }"
    end
  end

end
