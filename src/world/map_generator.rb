module Map::Generator

  def self.generate width, height
    tiles = Island.generate width, height
    tiles = Facility.generate width, height, tiles
    tiles
  end

end
