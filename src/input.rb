module Input

  include Terminal


  global :action,
         :mouse,
         :cursor,
         :quit


  def self.init
    @mouse       = Vector.new
    @mouse_moved = false
    @cursor      = Vector.new
    @delay       = 0
  end


  def self.read
    @action = nil

    old_mouse_x = @mouse.x
    old_mouse_y = @mouse.y

    @mouse.x = Terminal.state TK_MOUSE_X
    @mouse.y = Terminal.state TK_MOUSE_Y

    @mouse_moved = @mouse.x != old_mouse_x ||
                   @mouse.y != old_mouse_y

    @cursor.x = @mouse.x + Camera.position.x
    @cursor.y = @mouse.y + Camera.position.y

    return unless Terminal.has_input?

    @key = Terminal.read
    @chr = Terminal.state(TK_CHAR).chr

    special_actions

    if @disabled
      @delay -= 1
      enable if @delay <= 0
    end

    return if @disabled

    @chr = convert_key
    @action = interprete_chr
  end


  def self.enable;  @disabled = false end
  def self.disable; @disabled = true end

  def self.enabled?;  @disabled == false end
  def self.disabled?; @disabled == true end


  def self.disable_for delay
    @delay = delay
    disable
  end


  def self.mouse_moved?
    @mouse_moved
  end


  def self.shift?;   Terminal.state(TK_SHIFT)   == 1 end
  def self.control?; Terminal.state(TK_CONTROL) == 1 end
  def self.alt?;     Terminal.state(TK_ALT)     == 1 end


  internal def self.special_actions
    case @key
    when TK_CLOSE
      @quit = true

    when TK_RESIZED
      width  = Terminal.state TK_WIDTH
      height = Terminal.state TK_HEIGHT
      Display.window_resize width, height

    end
  end


  internal def self.convert_key
    case @key
    when TK_LEFT        then shift?? 'y' : control?? 'b' : 'h'
    when TK_DOWN        then 'j'
    when TK_UP          then 'k'
    when TK_RIGHT       then shift?? 'u' : control?? 'n' : 'l'
    when TK_KP_4        then 'h'
    when TK_KP_2        then 'j'
    when TK_KP_8        then 'k'
    when TK_KP_6        then 'l'
    when TK_KP_7        then 'y'
    when TK_KP_9        then 'u'
    when TK_KP_1        then 'b'
    when TK_KP_3        then 'n'
    when TK_KP_6        then '.'
    when TK_MOUSE_RIGHT then 'f!'
    when TK_ESCAPE      then '^C'
    else @chr
    end
  end


  internal def self.interprete_chr
    case @chr
    when 'h'  then :go_west
    when 'j'  then :go_south
    when 'k'  then :go_north
    when 'l'  then :go_east
    when 'y'  then :go_north_west
    when 'u'  then :go_north_east
    when 'b'  then :go_south_west
    when 'n'  then :go_south_east
    when 'x'  then :examine
    when 'f'  then :fire
    when '.'  then :wait
    when 'f!' then :fire!
    when '^C' then :cancel
    else nil
    end
  end

end
