module Map

  global :width,
         :height


  def self.generate
    opts = G.map_options

    @width  = opts.width
    @height = opts.height

    @types = define_tile_types opts.tile_types
    @tiles = Array.new(@width) { Array.new(@height) { :floor } }
  end


  def self.tile x, y
    if out_of_bounds? x, y
    then @types[:empty]
    else @types[ @tiles[x][y] ]
    end
  end


  def self.out_of_bounds? x, y
    x < 0 || x >= Map.width ||
    y < 0 || y >= Map.height
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


  def self.define_tile_types tiles
    tiles.inject({}) do |types, (key, type)|
      types[key.to_sym] = {
        char: type.char.ord,
        walk: type.can&.include?('walk'),
        fly:  type.can&.include?('fly'),
        see:  type.can&.include?('see')
      }
      types
    end
  end

end
