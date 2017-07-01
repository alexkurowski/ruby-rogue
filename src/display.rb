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

    Terminal.composition TK_ON

    update_font_size @font_size

    Terminal.refresh
  end


  def self.close
    Terminal.close
  end


  def self.render
    Terminal.clear

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


  def self.update_font_size val
    @font_size = val

    Terminal.set "font: #{ ROOT }/assets/#{ @font_name }.ttf, size=#{ @font_size }"

    @cell_width  = Terminal.state TK_CELL_WIDTH
    @cell_height = Terminal.state TK_CELL_HEIGHT
  end


  def self.window_resize width, height
    @width  = width
    @height = height
  end

end
