require './lib/BearLibTerminal'


class Game

  def initialize
    Terminal.open
    set_font_size 16
    print
    run
  end


  def run
    loop do
      input
      print
      break if @quit
    end
    quit
  end


private


  def input
    @input = Terminal.read

    case @input
    when Terminal::TK_CLOSE,
         Terminal::TK_ESCAPE
      @quit = true

    when Terminal::TK_KP_MINUS
      add_font_size -1

    when Terminal::TK_KP_PLUS
      add_font_size +1

    else
      puts "Unknown unput: #{ @input }"

    end
  end


  def print
    Terminal.print 1, 1, 'Hello World!'
    Terminal.refresh
  end


  def set_font_size val
    @font_size = val
    Terminal.set "font: assets/ubuntu.ttf, size=#{@font_size}"
  end


  def add_font_size val
    @font_size += val
    Terminal.set "font: assets/ubuntu.ttf, size=#{@font_size}"
  end


  def quit
    Terminal.close
  end

end
