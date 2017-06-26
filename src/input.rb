module Input


  include Terminal


  mattr_accessor :disabled,
                 :key,
                 :action,
                 :quit


  def self.read
    self.action = nil

    return unless Terminal.has_input?

    self.key = Terminal.read

    return if self.disabled

    case self.key
    when TK_CLOSE,
         TK_ESCAPE
      self.quit = true

    when TK_KP_MINUS
      Display.decrease_font_size

    when TK_KP_PLUS
      Display.increase_font_size

    when TK_RESIZED
      width  = Terminal.state TK_WIDTH
      height = Terminal.state TK_HEIGHT
      Display.window_resize width, height
    end

    self.interprete_action
  end


  def self.enable;  self.disabled = false end
  def self.disable; self.disabled = true end


  def self.interprete_action
    self.action = case self.key
      when TK_H then :go_west
      when TK_J then :go_south
      when TK_K then :go_north
      when TK_L then :go_east
      else nil
    end
  end
end
