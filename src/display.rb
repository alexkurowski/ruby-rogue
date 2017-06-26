module Display


  mattr_accessor :width,
                 :height,
                 :cell_width,
                 :cell_height,
                 :title,
                 :font,
                 :font_size,
                 :max_font_size,
                 :min_font_size


  def self.initialize
    self.width     = 60
    self.height    = 40
    self.title     = 'roguelike'
    self.font      = 'teko'
    self.font_size = 12
    self.max_font_size = 18
    self.min_font_size = 8

    Terminal.open

    Terminal.set """
    window: size=#{ self.width }x#{ self.height },
            title='#{ self.title }',
            resizeable=true;

    input: filter=[keyboard, mouse, properties];
    """

    update_font_size self.font_size
  end


  def self.render
    Terminal.clear
    Terminal.put 3, 2, '@'.ord
    Terminal.put_ext 2, 2, self.cell_width, self.cell_height, '@'.ord
    Terminal.refresh
  end


  def self.increase_font_size
    if self.font_size < self.max_font_size
      update_font_size self.font_size + 1
    end
  end


  def self.decrease_font_size
    if self.font_size > self.min_font_size
      update_font_size self.font_size - 1
    end
  end


  def self.update_font_size val
    Terminal.set "font: #{ROOT}/assets/#{ self.font }.ttf, size=#{ val }"

    self.font_size   = val
    self.cell_width  = Terminal.state Terminal::TK_CELL_WIDTH
    self.cell_height = Terminal.state Terminal::TK_CELL_HEIGHT

    render
  end


  def self.window_resize width, height
    self.width  = width
    self.height = height
  end


end
