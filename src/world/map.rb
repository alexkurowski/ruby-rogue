module Map

  global :width,
         :height


  def self.init
    opts = CONFIG.map_options

    @width  = opts.width
    @height = opts.height

    define_tile_types TILES.tile_types

    generate
  end


  def self.set_tile x, y, type
    variant = @types[type].sample
    @tiles[x][y] = variant
  end


  def self.tile x, y
    if out_of_bounds? x, y
    then @types[:empty_0]
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
    default_color = '255 255 255'

    @types = {}

    tiles.each do |key, type|

      key    = key.to_sym
      chars  = [ type.char ].flatten
      colors = define_tile_colors type.color || default_color
      can = {
        walk:  type.can&.include?('walk'),
        fly:   type.can&.include?('fly'),
        see:   type.can&.include?('see')
      }
      count = 0
      @types[key] = []

      chars.each do |char|
        colors.each do |color|
          variant = "#{ key }_#{ count }".to_sym

          @types[key] << variant
          @types[variant] = {
            char:  char,
            color: color,
            walk:  can.walk,
            fly:   can.fly,
            see:   can.see
          }

          count += 1
        end
      end

    end
  end


  internal def self.define_tile_colors colors
    [ colors ].flatten.inject([]) do |result, color|
      r, g, b = 255, 255, 255

      if color.is_a? String
        r, g, b = color.split(' ').map do |c|
          c.to_i.to_s(16).rjust 2, '0'
        end
      end

      result << {
        full: "ff#{r}#{g}#{b}",
        half: "30#{r}#{g}#{b}"
      }
    end
  end


  internal def self.generate
    tiles = Generator::Ruins.generate

    @tiles = Array.new(@width) { Array.new(@height) { :empty_0 } }

    for x in 0...@width
      for y in 0...@height
        set_tile x, y, tiles[x][y]
      end
    end
  end

end


module Map::Generator; end
