module Map::Generator::Ruins

  def self.generate level = 0
    @width  = Map.width
    @height = Map.height
    @level  = level

    @tiles  = Array.new(@width) { |i| Array.new(@height) { |j| :empty } }

    @node_min_size = 20
    @node_max_size = 40
    @room_min_size = 5
    @room_max_size = 20
    @smoothing     = 1
    @filling       = 3

    @min_enemy_ratio = 0.4
    @max_enemy_ratio = 0.8

    @pad   = 1
    @root  = new_node @pad, @pad, @width - @pad * 2, @height - @pad * 2
    @rooms = []

    split_nodes
    create_rooms @root
    clean_up
    fill_with_walls
    place_player
    place_enemies
    place_exit
    fix_wall_tiles

    return @tiles
  end


  internal def self.new_node x, y, w, h
    {
      x: x.floor,
      y: y.floor,
      w: w.floor,
      h: h.floor,
      child1: nil,
      child2: nil,
      room:   nil
    }
  end


  internal def self.new_room x, y, w, h
    {
      x1: x.floor,
      y1: y.floor,
      x2: ( x + w ).floor,
      y2: ( y + h ).floor
    }
  end


  internal def self.clear_from_walls node, newTile
    x1 = node.x.floor
    x2 = ( node.x + node.w - 1 ).floor
    y1 = node.y.floor
    y2 = ( node.y + node.h - 1 ).floor

    for x in x1..x2
      for y in y1..y2
        @tiles[x][y] = newTile if @tiles[x][y] == :wall
      end
    end
  end


  internal def self.split_nodes
    nodes = [ @root ]

    split = true
    while split
      split = false
      nodes.each do |node|
        if node.child1.nil? and node.child2.nil?
          if node.w > @node_max_size or
             node.h > @node_max_size or
             rand > 0.8
            if split_node node
              nodes << node.child1
              nodes << node.child2
              split = true
            end
          end
        end
      end
    end
  end


  internal def self.split_node node
    return false unless node.child1.nil? and
                        node.child2.nil?

    split = determine_split node

    max = if split == :horizontal
          then node.h - @node_min_size
          else node.w - @node_min_size
          end

    return false if max <= @node_min_size

    s = random @node_min_size, max

    case split
    when :horizontal
      node[:child1] = new_node node.x, node.y, node.w, s
      node[:child2] = new_node node.x, node.y + s, node.w, node.h - s
    when :vertical
      node[:child1] = new_node node.x, node.y, s, node.h
      node[:child2] = new_node node.x + s, node.y, node.w - s, node.h
    end

    true
  end


  internal def self.determine_split node
    if node.w / node.h >= 1.25
      :vertical
    elsif node.h / node.w >= 1.25
      :horizontal
    else
      [:horizontal, :vertical][rand 2]
    end
  end


  internal def self.create_rooms node
    return if node.nil?

    if node.child1 or node.child2
      create_rooms node.child1
      create_rooms node.child2
      create_hall node.child1, node.child2
    else

      w = random @room_min_size, [ @room_max_size, node.w - 1 ].min
      h = random @room_min_size, [ @room_max_size, node.h - 1 ].min
      x = random node.x + @pad, node.x + (node.w - 1) - w - @pad * 2
      y = random node.y + @pad, node.y + (node.h - 1) - h - @pad * 2
      node[:room] = new_room x, y, w, h
      @rooms << node.room
      put_room node.room
    end
  end


  internal def self.create_hall node1, node2
    return if node1.nil? or node2.nil?

    put_hall get_room(node1), get_room(node2)
  end


  internal def self.put_room room
    for i in (room.x1 + 1)..(room.x2)
      for j in (room.y1 + 1)..(room.y2)
        @tiles[i][j] = :floor
      end
    end
  end


  internal def self.put_hall room1, room2
    drunkard = room_random_point room2
    goal     = room_random_point room1

    while not inside_room? room1, drunkard
      north  = 1.0
      south  = 1.0
      east   = 1.0
      west   = 1.0
      weight = 1

      if drunkard.x < goal.x
        east += weight
      elsif drunkard.x > goal.x
        west += weight
      elsif drunkard.y < goal.y
        south += weight
      elsif drunkard.y > goal.y
        north += weight
      end

      total = north + south + east + west
      north /= total
      south /= total
      east  /= total
      west  /= total

      choice = rand
      dx, dy = 0, 0
      if choice < north
        dy = -1
      elsif choice < north + south
        dy = +1
      elsif choice < north + south + east
        dx = +1
      else
        dx = -1
      end

      if inside_node? @root, drunkard.x + dx, drunkard.y + dy
        drunkard[:x] += dx
        drunkard[:y] += dy
        @tiles[drunkard.x][drunkard.y] = :floor
      end
    end
  end


  internal def self.get_room node
    return node.room if node.room

    node[:room1] = get_room node.child1 unless node.child1.nil?
    node[:room2] = get_room node.child2 unless node.child2.nil?

    return nil if node.child1.nil? and node.child2.nil?

    return node.room2 if node.room1.nil?
    return node.room1 if node.room2.nil?

    if rand > 0.5
    then node.room1
    else node.room2
    end
  end


  internal def self.room_center room
    {
      x: ( room.x1 + room.x2 ) / 2,
      y: ( room.y1 + room.y2 ) / 2
    }
  end


  internal def self.room_random_point room
    {
      x: random( room.x1, room.x2 ),
      y: random( room.y1, room.y2 )
    }
  end


  internal def self.inside_room? room, point
    point.x > room.x1 and point.x < room.x2 and
    point.y > room.y1 and point.y < room.y2
  end


  internal def self.inside_node? node, x, y
    x > node.x and x < node.x + node.w - 1 and
    y > node.y and y < node.y + node.h - 1
  end


  internal def self.clear_some_nodes node
    if node.child1.nil? and node.child2.nil?
      clearance_chance = 0.1
      newTile = :floor

      if node.x == @root.x or
         node.y == @root.y or
         node.x + node.w == @root.x + @root.w or
         node.y + node.h == @root.y + @root.h
        clearance_chance = 0.15
        newTile = :sand
      end

      if rand < clearance_chance
        clear_from_walls node, newTile
      end

    else
      clear_some_nodes node.child1 unless node.child1.nil?
      clear_some_nodes node.child2 unless node.child2.nil?
    end
  end


  internal def self.clean_up
    3.times do
      for x in 1...( @width - 1 )
        for y in 1...( @height - 1 )

          walls = count_adjusted_walls x, y

          if @tiles[x][y] != :floor and walls <= @smoothing
            @tiles[x][y] = :floor
          end

        end
      end
    end
  end


  internal def self.fill_with_walls
    for x in 1...( @width - 1 )
      for y in 1...( @height - 1 )
        @tiles[x][y] = :wall if @tiles[x][y] == :empty and any_adjusted_floors? x, y
      end
    end
  end


  internal def self.any_adjusted_floors? x, y
    @tiles[x - 1][y - 1] == :floor ||
    @tiles[x    ][y - 1] == :floor ||
    @tiles[x + 1][y - 1] == :floor ||
    @tiles[x - 1][y    ] == :floor ||
    @tiles[x + 1][y    ] == :floor ||
    @tiles[x - 1][y + 1] == :floor ||
    @tiles[x    ][y + 1] == :floor ||
    @tiles[x + 1][y + 1] == :floor
  end


  internal def self.count_adjusted_walls x, y
    count = 0
    count += 1 if @tiles[x - 1][y] != :floor
    count += 1 if @tiles[x + 1][y] != :floor
    count += 1 if @tiles[x][y - 1] != :floor
    count += 1 if @tiles[x][y + 1] != :floor
    count
  end


  internal def self.place_player
    @player_room = @rooms.sample

    center = room_center @player_room
    x = center.x + 1
    y = center.y + 1

    World.initial_player_position = new_vector x, y
  end


  internal def self.place_enemies
    enemies  = []
    room     = nil
    type     = nil
    position = nil

    enemy_count = random @rooms.count * @min_enemy_ratio, @rooms.count * @max_enemy_ratio

    enemy_count.floor.times do
      loop do
        room = @rooms.sample
        break unless room == @player_room
      end

      type = :mob
      position = new_vector
      position[:x] = random room.x1, room.x2
      position[:y] = random room.y1, room.y2

      enemies << {
        type:     type,
        position: position
      }
    end

    World.initial_enemies = enemies
  end


  internal def self.place_exit
    loop do
      room = @rooms.sample
      break unless room == @player_room
    end
  end


  internal def self.get_leftmost_room node
    if node.child1.nil?
      node
    else
      get_leftmost_room node.child1
    end
  end


  internal def self.get_rightmost_room node
    if node.child2.nil?
      node
    else
      get_leftmost_room node.child2
    end
  end


  internal def self.fix_wall_tiles
    tiles = Array.new(@width) { |i| Array.new(@height) { |j| @tiles[i][j] } }

    for i in 1...@width - 1
      for j in 1...@height - 1

        next unless @tiles[i][j] == :wall

        north = @tiles[i][j - 1] == :wall
        south = @tiles[i][j + 1] == :wall
        east  = @tiles[i + 1][j] == :wall
        west  = @tiles[i - 1][j] == :wall

        next if north and south and east and west

        new_tile =
        if north and east and south
          :wall_nes
        elsif north and west and south
          :wall_nws
        elsif east and south and west
          :wall_wse
        elsif east and north and west
          :wall_wne
        elsif north and west
          :wall_nw
        elsif north and east
          :wall_ne
        elsif south and west
          :wall_sw
        elsif south and east
          :wall_se
        elsif west and east
          :wall_we
        elsif north and south
          :wall_ns
        elsif north
          :wall_n
        elsif south
          :wall_s
        elsif east
          :wall_e
        elsif west
          :wall_w
        else
          :wall
        end

        tiles[i][j] = new_tile

      end
    end

    @tiles = tiles
  end

end
