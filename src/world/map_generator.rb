module Map::Generator

  def self.generate width, height
    tiles = Island.generate width, height
    tiles = Facility.generate width, height, tiles

    tiles = fix_walls width, height, tiles

    tiles
  end


  internal def self.fix_walls width, height, original_tiles
    tiles = Array.new(width) { |i|  Array.new(height) { |j| original_tiles[i][j] } }

    for i in 1...width - 1
      for j in 1...height - 1

        next unless original_tiles[i][j] == :wall

        north = original_tiles[i][j - 1] == :wall
        south = original_tiles[i][j + 1] == :wall
        east  = original_tiles[i + 1][j] == :wall
        west  = original_tiles[i - 1][j] == :wall

        next if north and south and east and west

        new_tile =
        if north and east and south
          :wall_triangle_nes
        elsif north and west and south
          :wall_triangle_nws
        elsif east and south and west
          :wall_triangle_wse
        elsif east and north and west
          :wall_triangle_wne
        elsif north and west
          :wall_corner_nw
        elsif north and east
          :wall_corner_ne
        elsif south and west
          :wall_corner_sw
        elsif south and east
          :wall_corner_se
        elsif west and east
          :wall_horizontal
        elsif north and south
          :wall_vertical
        else
          :wall
        end

        tiles[i][j] = new_tile

      end
    end

    tiles
  end

end
