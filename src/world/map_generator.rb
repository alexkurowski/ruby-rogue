module Map::Generator

  def self.generate width, height
    @width  = width
    @height = height

    @island_size = @width * 0.2

    seed         = Time.now.to_i % 1000
    persistence  = 0.3
    octaves      = 16
    @noise = Perlin::Generator.new seed, persistence, octaves

    @tiles = Array.new(width) { Array.new(height) { :empty } }

    generate_island
    # generate_facility
    # clean_up

    World.player_x = 20
    World.player_y = 20

    @tiles
  end


  def self.generate_island
    chunk = @noise.chunk 0, 0, @width, @height, 0.05

    for i in 0...@width
      for j in 0...@height
        @tiles[i][j] = island_tile chunk[i][j], i, j
      end
    end
  end

  def self.island_tile noise, x, y
    cx       = ( @width  * 0.5 - x ).abs
    cy       = ( @height * 0.5 - y ).abs
    mask     = [cx, cy].max # square mask
    delta    = mask / @island_size * 0.5
    gradient = delta * delta

    noise = ( noise + 1 ) / 2
    noise *= [0, 1.25 - gradient].max

    if noise < 0.1
      :water
    elsif noise < 0.15
      :sand
    else
      :grass
    end
  end

end
