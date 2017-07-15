module Display

  include Terminal


  global :width,
         :height,
         :cell_width,
         :cell_height


  def self.open
    opts = CONFIG.terminal_options

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
    @background    = Terminal.color_from_argb 255, 6, 8, 14

    @layers = {
      tiles:    0,
      entities: 1,
      ui:       2
    }

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


  def self.clear_tiles
    Terminal.layer @layers.tiles
    Terminal.bkcolor @background
    Terminal.clear
  end


  def self.clear_entities
    Terminal.layer @layers.entities
  end


  def self.clear_ui
    Terminal.layer @layers.ui
    Terminal.clear_area 0, 0, @width, @height
  end


  def self.print_offset dx, dy
    "[offset=#{ dx },#{ dy }]"
  end


  def self.print_color color
    "[color=##{ color }]"
  end


  def self.print string
    Terminal.print 0, 0, string
  end


  def self.draw char, color, position, offset = nil
    if offset.nil?
    then put char, color, position
    else put_ext char, color, position, offset
    end
  end


  def self.put char, color, position
    Terminal.color color
    Terminal.put position.x, position.y, char
  end


  def self.put_ext char, color, position, offset
    if char.chr == '@'
      p offset
    end
    Terminal.color color
    Terminal.put_ext position.x, position.y, offset.x, offset.y, char
  end


  def self.draw_set set, char, color
    Terminal.color color
    char = char.ord if char.is_a? String

    set.each do |point|
      Terminal.put point.x, point.y, char
    end
  end


  def self.refresh
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


  def self.big?
    width * height > 5000
  end


  internal def self.update_font_size val
    @font_size = val

    if @mode == 'font'
      Terminal.set "font: #{ ROOT }/assets/fonts/#{ @font_name }.ttf, size=#{ @font_size }"
    else
      Terminal.set "font: #{ ROOT }/assets/tiles/#{ @tile_name }.png, size=#{ @tile_size }x#{ @tile_size }, codepage=437"
    end

    Camera.set_dirty

    @cell_width  = Terminal.state TK_CELL_WIDTH
    @cell_height = Terminal.state TK_CELL_HEIGHT
  end

end
