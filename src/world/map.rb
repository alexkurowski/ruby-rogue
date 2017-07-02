module Map

  global :width,
         :height


  def self.generate
    opts = G.map_options

    @width  = opts.width
    @height = opts.height

    @types = define_tile_types opts.tile_types
    @tiles = Array.new(@width) { Array.new(@height) { :empty } }

    generate_map
  end


  def self.tile x, y
    if out_of_bounds? x, y
    then @types[:empty]
    else @types[ @tiles[x][y] ]
    end
  end


  def self.can_walk? x, y
    tile(x, y).walk
  end


  def self.can_fly? x, y
    tile(x, y).fly
  end


  def self.can_see? x, y
    tile(x, y).see
  end


  internal def self.out_of_bounds? x, y
    x < 0 || x >= @width ||
    y < 0 || y >= @height
  end


  internal def self.define_tile_types tiles
    tiles.inject({}) do |types, (key, type)|
      types[key.to_sym] = {
        char:  type.char.ord,
        color: define_tile_color(type.color),
        walk:  type.can&.include?('walk'),
        fly:   type.can&.include?('fly'),
        see:   type.can&.include?('see')
      }
      types
    end
  end


  internal def self.define_tile_color color
    r, g, b = 255, 255, 255

    if color.is_a? String
      r, g, b = color.split(' ').map(&:to_i)
    end

    {
      full: Terminal.color_from_argb(255, r, g, b),
      half: Terminal.color_from_argb(120, r, g, b)
    }
  end


  internal def self.generate_map
    generate_room 30, 10, 20, 12
  end


  internal def self.generate_room x, y, w, h
    w += 1
    h += 1

    for i in (x) .. (x + w)
      for j in (y) .. (y + h)
        if i == x or i == x + w
          put_tile i, j, :wall_vertical
        elsif j == y or j == y + h
          put_tile i, j, :wall_horizontal
        else
          put_tile i, j, :floor
        end
      end
    end

    put_tile x,     y,     :wall_corner_nw
    put_tile x + w, y,     :wall_corner_ne
    put_tile x,     y + h, :wall_corner_sw
    put_tile x + w, y + h, :wall_corner_se
  end


  internal def self.put_tile x, y, tile
    @tiles[x][y] = tile
  end

end
