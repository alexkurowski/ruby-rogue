module Display

  include Terminal


  global :width,
         :height,
         :cell_width,
         :cell_height,
         :log_width,
         :log_height


  def self.open
    opts = CONFIG.terminal_options

    @width  = opts.width
    @height = opts.height

    title       = opts.title
    tile_name   = opts.tile_name
    tile_size   = opts.tile_size
    log_name    = opts.log_name
    log_size    = opts.log_size
    @background = Terminal.color_from_argb 255, 6, 8, 14

    @cell_width  = tile_size.split('x').map(&:to_i).first
    @cell_height = tile_size.split('x').map(&:to_i).last
    @log_width   = log_size.split('x').map(&:to_i).first
    @log_height  = log_size.split('x').map(&:to_i).last

    @layers = {
      tiles:    0,
      entities: 1,
      ui:       2
    }

    Terminal.open

    Terminal.set """
    window: size=#{ @width }x#{ @height },
            title='#{ title }',
            resizeable=true;

    input: filter=[keyboard, mouse, properties];

    font: #{ ROOT }/assets/tiles/#{ tile_name }.png, size=#{ tile_size }, codepage=437;
    log font: #{ ROOT }/assets/tiles/#{ log_name }.png, size=#{ log_size }, codepage=437;
    """

    Camera.set_dirty

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


  def self.print_at x, y, string
    Terminal.print x, y, string
  end


  def self.print_log x, y, string, color = '#ffffffff'
    diff_x = -(@cell_width - @log_width)
    diff_y = (@cell_height - @log_height) / 2
    offset = 0

    string.chars.each_slice @width do |chars|

      log = ''
      i = 0
      chars.each do |ch|
        log << "[offset=#{ diff_x * i + offset },#{ diff_y }]" << ch
        i += 1
      end
      offset += @log_width * i

      Display.print_at x, y, "[font=log][color=#{ color }]#{ log }[/font]"

    end
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


  def self.composition val = false
    Terminal.composition val ? TK_ON : TK_OFF
  end


  def self.window_resize width, height
    @width  = width
    @height = height
  end


  def self.big?
    width * height > 5000
  end

end
