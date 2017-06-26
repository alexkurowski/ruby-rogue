class Game


  def initialize
    @target_fps = 1000 / 60

    @x     = 20
    @y     = 20
    @dx    = 0
    @dy    = 0

    Display.initialize
    run
    quit
  end


  def run
    loop do
      frame_start

      Input.read
      World.update
      Display.render

      frame_end

      break if Input.quit
    end

    #   if @dx.abs.floor != 0 or @dy.abs.floor != 0
    #     @take_input = false
    #     @dx *= 0.6
    #     @dy *= 0.6
    #     Terminal.put_ext @x, @y, @dx, @dy, '@'.ord
    #     Terminal.refresh
    #   else
    #     @take_input = true
    #   end
  end


private


  def input
    return unless Terminal.has_input?

    @input = Terminal.read

    return unless @take_input

    case @input
    when Terminal::TK_CLOSE,
         Terminal::TK_ESCAPE
      @quit = true

    when Terminal::TK_H
      @x -= 1
      @dx = @font_size

    when Terminal::TK_J
      @y += 1
      @dy = -@font_size

    when Terminal::TK_K
      @y -= 1
      @dy = @font_size

    when Terminal::TK_L
      @x += 1
      @dx = -@font_size

    when Terminal::TK_KP_MINUS
      add_font_size -1

    when Terminal::TK_KP_PLUS
      add_font_size +1

    when Terminal::TK_RESIZED
      @width  = Terminal.state Terminal::TK_WIDTH
      @height = Terminal.state Terminal::TK_HEIGHT

    else
      puts "Unknown unput: #{ @input }"

    end
  end


  def print
    Terminal.clear
    @width.times do |i|
      @height.times do |j|
        Terminal.put i, j, '.'.ord
      end
    end
    Terminal.put_ext @x, @y, @dx, @dy, '@'.ord
    Terminal.refresh
  end


  def add_font_size val
    set_font_size @font_size + val
  end


  def set_font_size val
    @font_size = val
    Terminal.set "font: #{ROOT}/assets/#{@font}.ttf, size=#{@font_size}"
  end


  def frame_start
    @frame_start = Time.now
  end


  def frame_end
    elapsed = Time.now - @frame_start
    time_to_sleep = @target_fps - elapsed
    Terminal.delay time_to_sleep
  end


  def quit
    Terminal.close
  end


end
