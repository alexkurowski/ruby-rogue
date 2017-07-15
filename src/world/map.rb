module Map

  global :width,
         :height


  def self.init
    opts = CONFIG.map_options

    @width  = opts.width
    @height = opts.height

    define_tile_types TILES.tile_types, TILES.tile_statuses

    generate
  end


  def self.set_tile x, y, type, status = :normal
    type = "#{status}_#{type}".to_sym
    variant = @types[type].sample
    @tiles[x][y] = variant
  end


  def self.set_status x, y, status
    return if out_of_bounds? x, y

    type = @tiles[x][y].to_s[@tiles[x][y].to_s.index('_')..-1]
    @tiles[x][y] = "#{status}#{type}".to_sym
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


  internal def self.define_tile_types tiles, statuses
    default_color = '255 255 255'

    @types = {}

    tiles.each do |key, type|
      statuses.each do |status, overrides|

        status_key = "#{ status }_#{ key }".to_sym
        count = 0
        @types[status_key] = []

        chars  = [ overrides&.char || type.char ].flatten
        colors = define_tile_colors overrides&.color || type.color || default_color
        can    = define_tile_can overrides&.can || type.can

        chars.each do |char|
          colors.each do |color|
            variant = "#{ status_key }_#{ count }".to_sym

            @types[status_key] << variant
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
  end


  internal def self.define_tile_colors colors
    [ colors ].flatten.inject([]) do |result, color|
      r, g, b, x = 'ff', 'ff', 'ff', '80'

      if color.is_a? String
        r, g, b = *color.split(' ').map(&:to_i)
        x = (r + g + b) / 12

        r = r.to_s(16).rjust 2, '0'
        g = g.to_s(16).rjust 2, '0'
        b = b.to_s(16).rjust 2, '0'
        x = x.to_s(16).rjust 2, '0'
      end

      result << {
        full: "ff#{r}#{g}#{b}",
        half: "ff#{x}#{x}#{x}"
      }
    end
  end


  internal def self.define_tile_can can
    {
      walk: can&.include?('walk'),
      fly:  can&.include?('fly'),
      see:  can&.include?('see')
    }
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
