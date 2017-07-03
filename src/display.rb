module Display

  include Terminal


  global :width,
         :height,
         :cell_width,
         :cell_height


  def self.open
    opts = CONF.terminal_options

    @width  = opts.width
    @height = opts.height

    @title         = opts.title
    @mode          = opts.mode
    @tile_name     = opts.tile_name
    @tile_size     = opts.tile_size
    @font_name     = opts.font_name
    @font_size     = opts.font_size
    @min_font_size = opts.min_font_size
    @max_font_size = opts.max_font_size

    Terminal.open

    Terminal.set """
    window: size=#{ @width }x#{ @height },
            title='#{ @title }',
            resizeable=true;

    input: filter=[keyboard, mouse, properties];
    """

    update_font_size @font_size

    Terminal.refresh
  end


  def self.close
    Terminal.close
  end


  def self.render
    World.render
    Terminal.refresh
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


  def self.window_resize width, height
    @width  = width
    @height = height
  end


  def self.map
    for i in 1...width
      for j in 1...height
        yield i, j
      end
    end
  end


  def self.big?
    width * height > 4000
  end


  internal def self.update_font_size val
    @font_size = val

    if @mode == 'font'
      Terminal.set "font: #{ ROOT }/assets/#{ @font_name }.ttf, size=#{ @font_size }"
    else
      Terminal.set "font: #{ ROOT }/assets/#{ @tile_name }.png, size=#{ @tile_size }x#{ @tile_size }, codepage=437"
    end

    Camera.set_dirty

    @cell_width  = Terminal.state TK_CELL_WIDTH
    @cell_height = Terminal.state TK_CELL_HEIGHT
  end

end
