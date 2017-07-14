module Renderer::Tiles

  def self.before
    Display.clear_tiles

    @output = ''

    x = -Camera.offset.x.floor
    y = -Camera.offset.y.floor

    return if x == 0 and y == 0

    offset = Display.print_offset x, y

    @output << offset
  end


  def self.render
    for j in 0...Display.height
      for i in 0...Display.width

        x   = Camera.position.x + i
        y   = Camera.position.y + j
        fov = Fov.at x, y

        if fov == :none
          @output << ' '
          next
        end

        tile  = Map.tile x, y
        color = Display.print_color tile.color[fov]
        char  = tile.char

        @output << color
        @output << char

      end

      @output << "\n"
    end
  end


  def self.after
    Display.print @output
  end

end
