module Input

  include Terminal


  global :action,
         :quit


  def self.read
    @action = nil

    return unless Terminal.has_input?

    @key = Terminal.read

    return if @disabled

    special_keys
    interprete_action
  end


  def self.enable;  @disabled = false end
  def self.disable; @disabled = true end


  def self.special_keys
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


  def self.interprete_action
    @action = case @key
      when TK_H then :go_west
      when TK_J then :go_south
      when TK_K then :go_north
      when TK_L then :go_east
      else nil
    end
  end

end
