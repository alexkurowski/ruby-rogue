module Display

  global :width,
         :height,
         :cell_width,
         :cell_height


  def self.open
    @width  = 60
    @height = 40

    @title         = 'roguelike'
    @font          = 'teko'
    @font_size     = 12
    @max_font_size = 18
    @min_font_size = 8
    @target_fps    = 1 / 60

    Terminal.open

    Terminal.set """
    window: size=#{ @width }x#{ @height },
            title='#{ @title }',
            resizeable=true;

    input: filter=[keyboard, mouse, properties];
    """

    update_font_size @font_size
  end


  def self.close
    Terminal.close
  end


  def self.render
    Terminal.clear
    Terminal.put 3, 2, '@'.ord
    Terminal.put_ext 2, 2, @cell_width, @cell_height, '@'.ord
    Terminal.refresh
  end


  def self.frame_start
    @frame_start_time = Time.now
  end


  def self.frame_end
    elapsed = Time.now - @frame_start_time
    time_to_sleep = @target_fps - elapsed
    Terminal.delay time_to_sleep
  end


  def self.increase_font_size
    if @font_size < @max_font_size
      update_font_size @font_size + 1
    end
  end


  def self.decrease_font_size
    if @font_size > @min_font_size
      update_font_size @font_size - 1
    end
  end


  def self.update_font_size val
    @font_size = val

    Terminal.set "font: #{ ROOT }/assets/#{ @font }.ttf, size=#{ @font_size }"

    @cell_width  = Terminal.state Terminal::TK_CELL_WIDTH
    @cell_height = Terminal.state Terminal::TK_CELL_HEIGHT

    render
  end


  def self.window_resize width, height
    @width  = width
    @height = height
  end

end
