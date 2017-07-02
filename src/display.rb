module Display

  include Terminal


  global :width,
         :height,
         :cell_width,
         :cell_height


  def self.open
    opts = G.terminal_options

    @width  = opts.width
    @height = opts.height

    @title         = opts.title
    @font_name     = opts.font_name
    @font_type     = opts.font_type
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
    for i in 0...width
      for j in 0...height
        yield i, j
      end
    end
  end


  def self.big?
    width * height > 3000
  end


  internal def self.update_font_size val
    @font_size = val

    if @font_type == 'ttf'
      Terminal.set "font: #{ ROOT }/assets/#{ @font_name }.ttf, size=#{ @font_size }"
    else
      Terminal.set "font: #{ ROOT }/assets/#{ @font_name }.#{ @font_type }, size=#{ @font_size }x#{ @font_size }, codepage=437"
    end

    Camera.set_dirty

    @cell_width  = Terminal.state TK_CELL_WIDTH
    @cell_height = Terminal.state TK_CELL_HEIGHT
  end

end
