module Map::Generator::Facility

  def self.generate width, height, tiles
    @width  = width
    @height = height

    @tiles  = Array.new(width) { |i|  Array.new(height) { |j| tiles[i][j] } }

    @node_min_size = 10
    @node_max_size = 40
    @room_min_size = ( @node_min_size * 0.7 ).floor
    @room_max_size = ( @node_max_size * 0.7 ).floor
    @smoothing     = 1
    @filling       = 3
    @facility_size = @width * 0.3

    root = new_node @width  * 0.5 - @facility_size,
                    @height * 0.5 - @facility_size,
                    @facility_size * 2,
                    @facility_size * 2
    @rooms = []

    fill_with_walls root
    split_nodes root
    create_rooms root
    clean_up
    find_entrance
    fix_wall_tiles

    return @tiles
  end


  internal def self.new_node x, y, w, h
    {
      x: x,
      y: y,
      w: w,
      h: h,
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


  internal def self.split_nodes root
    nodes = [root]

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


  internal def self.fill_with_walls node
    x1 = node.x.floor
    x2 = ( node.x + node.w ).floor
    y1 = node.y.floor
    y2 = ( node.y + node.h ).floor

    for x in x1..x2
      for y in y1..y2
        @tiles[x][y] = :wall
      end
    end
  end


  internal def self.create_rooms node
    if node.child1 or node.child2
      create_rooms node.child1 unless node.child1.nil?
      create_rooms node.child2 unless node.child2.nil?
      create_hall node.child1, node.child2
    else

      w = random @room_min_size, [ @room_max_size, node.w - 1 ].min
      h = random @room_min_size, [ @room_max_size, node.h - 1 ].min
      x = random node.x, node.x + (node.w - 1) - w
      y = random node.y, node.y + (node.h - 1) - h
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

      if ( 0 < drunkard.x + dx and drunkard.x + dx < @width  - 1 ) and
         ( 0 < drunkard.y + dy and drunkard.y + dy < @height - 1 )
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


  internal def self.clean_up
    3.times do
      for x in 1...( @width - 1 )
        for y in 1...( @height - 1 )

          walls = adjust_walls x, y

          if @tiles[x][y] != :floor and walls <= @smoothing
            @tiles[x][y] = :floor
          end

        end
      end
    end
  end


  internal def self.adjust_walls x, y
    count = 0
    count += 1 if @tiles[x - 1][y] != :floor
    count += 1 if @tiles[x + 1][y] != :floor
    count += 1 if @tiles[x][y - 1] != :floor
    count += 1 if @tiles[x][y + 1] != :floor
    count
  end


  internal def self.find_entrance
    rx = @width
    ry = @height

    @rooms.each do |room|
      if room.x1 < rx and room.y1 < ry
        rx = room.x1
        ry = room.y1
      end
    end

    for x in ( rx + 1 )..( rx + 4 )
      for y in 0..ry
        @tiles[x][y] = :floor if @tiles[x][y] == :wall
      end
    end


    cx = @width  * 0.5 - @facility_size + 5
    cy = @height * 0.5 - @facility_size - 5

    while @tiles[cx][cy] != :grass
      cy -= 1
    end

    World.player_x = cx
    World.player_y = cy
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
        elsif west or east
          :wall_horizontal
        elsif north or south
          :wall_vertical
        else
          :wall
        end

        tiles[i][j] = new_tile

      end
    end

    @tiles = tiles
  end

end
