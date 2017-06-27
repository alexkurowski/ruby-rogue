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
    @types[ @tiles[x][y] || 0 ]
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
