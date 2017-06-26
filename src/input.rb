module Input

  include Terminal


  global :action,
         :quit


  def self.read
    @action = nil

    return unless Terminal.has_input?

    @key = Terminal.read
    @chr = Terminal.state(TK_CHAR).chr

    return if @disabled

    special_actions
    @action = interprete_chr || interprete_key
  end


  def self.enable;  @disabled = false end
  def self.disable; @disabled = true end


  def self.special_actions
    case @key
    when TK_CLOSE,
         TK_ESCAPE
      @quit = true

    when TK_KP_MINUS
      Display.decrease_font_size

    when TK_KP_PLUS
      Display.increase_font_size

    when TK_RESIZED
      width  = Terminal.state TK_WIDTH
      height = Terminal.state TK_HEIGHT
      Display.window_resize width, height

    end
  end


  def self.interprete_chr
    case @chr
    when 'h' then :go_west
    when 'j' then :go_south
    when 'k' then :go_north
    when 'l' then :go_east
    else nil
    end
  end


  def self.interprete_key
    case @key
    when TK_LEFT  then :go_west
    when TK_DOWN  then :go_south
    when TK_UP    then :go_north
    when TK_RIGHT then :go_east
    else nil
    end
  end


  def self.shift?;   Terminal.state(TK_SHIFT)   == 1 end
  def self.control?; Terminal.state(TK_CONTROL) == 1 end
  def self.alt?;     Terminal.state(TK_ALT)     == 1 end

end
