module Los

  def self.init
    @width  = Map.width
    @height = Map.height
  end


  def self.check_line from:, to:, radius:, permissive: false
    x1 = from.x
    y1 = from.y
    x2 = to.x
    y2 = to.y

    return false if x1 < 0 or x1 >= @width or
                    y1 < 0 or y1 >= @height or
                    x2 < 0 or x2 >= @width or
                    y2 < 0 or y2 >= @height

    distance = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
    return false if distance >= radius * radius

    return true if x1 == x2 and y1 == y2

    if permissive
    then check_line_permissive x1, y1, x2, y2, radius, true
    else check_line_simple x1, y1, x2, y2, radius, true
    end
  end


  internal def self.check_line_simple x1, y1, x2, y2, radius, sight
    steep = ((y2 - y1).abs) > ((x2 - x1).abs)
    if steep
      x1, y1 = y1, x1
      x2, y2 = y2, x2
    end
    if x1 > x2
      x1, x2 = x2, x1
      y1, y2 = y2, y1
    end
    dx = x2 - x1
    dy = (y2 - y1).abs
    error = (dx / 2).to_i
    y = y1
    ystep = nil
    if y1 < y2
      ystep = 1
    else
      ystep = -1
    end
    for x in x1..x2
      if steep
        return false if blocked? y, x, sight
      else
        return false if blocked? x, y, sight
      end
      error -= dy
      if error < 0
        y += ystep
        error += dx
      end
    end

    return true
  end


  internal def self.check_line_permissive x1, y1, x2, y2, radius, sight
    x_offset     = x2 - x1
    y_offset     = y2 - y1
    alt_x_offset = x_offset.abs
    alt_y_offset = y_offset.abs

    x_normal = ( x_offset == 0 ? 1 : x_offset / alt_x_offset ).round
    y_normal = ( y_offset == 0 ? 1 : y_offset / alt_y_offset ).round

    swapped_axis = false

    if alt_x_offset < alt_y_offset
      swapped_axis = true
      alt_x_offset, alt_y_offset = alt_y_offset, alt_x_offset
    end

    x_unit = alt_x_offset / alt_x_offset.gcd(alt_y_offset)
    y_unit = alt_y_offset / alt_x_offset.gcd(alt_y_offset)

    x_unit = x_unit.round
    y_unit = y_unit.round

    for starting_eps in 0...x_unit.floor
      eps        = starting_eps
      x_relative = 0
      y_relative = 0

      alt_x_offset.floor.times do
        eps += y_unit

        if (eps >= x_unit)
          eps        -= x_unit
          x_relative += x_normal
          y_relative += y_normal
        else
          if swapped_axis
          then y_relative += y_normal
          else x_relative += x_normal
          end
        end

        break if blocked? x1 + x_relative, y1 + y_relative, sight
      end

      if swapped_axis
        return true if y_offset == y_relative
      else
        return true if x_offset == x_relative
      end
    end

    return false
  end


  def self.line_of_fire from:, to:, radius:
    result, _ = line_of_fire_and_target from: from, to: to, radius: radius
    return result
  end


  def self.line_of_fire_and_target from:, to:, radius:
    permissive = from == World.player.position
    @origin_position = from

    x1 = from.x
    y1 = from.y
    x2 = to.x
    y2 = to.y

    dx = x2 - x1
    dy = y2 - y1

    lines = []
    lines << get_ray(x1, y1, x2, y2, radius)
    if permissive
      horizontal = dx.abs < dy.abs
      vertical   = dx.abs > dy.abs

      if horizontal
        lines << get_ray(x1 + 1, y1, x2, y2, radius) if dx > 0 and not blocked? x1 + 1, y1, false
        lines << get_ray(x1 - 1, y1, x2, y2, radius) if dx < 0 and not blocked? x1 - 1, y1, false
      elsif vertical
        lines << get_ray(x1, y1 + 1, x2, y2, radius) if dy > 0 and not blocked? x1, y1 + 1, false
        lines << get_ray(x1, y1 - 1, x2, y2, radius) if dy < 0 and not blocked? x1, y1 - 1, false
      end
    end

    lines = get_first_entity_and_cut lines
    entities = lines.map(&:entity).compact

    line = if entities.count > 0
    then find_line_with_closest_entity lines
    else find_longest_line lines
    end

    return line.line, line.entity
  end


  internal def self.get_ray x1, y1, x2, y2, length
    dx = x2 - x1
    dy = y2 - y1
    mag = Math.sqrt dx * dx + dy * dy
    unless mag == 0
      dx /= mag
      dy /= mag
    end

    x2 = ( x1 + dx * length ).round
    y2 = ( y1 + dy * length ).round

    get_line x1, y1, x2, y2
  end


  internal def self.get_line x1, y1, x2, y2
    px = x1
    py = y1

    points = []

    steep = ((y2 - y1).abs) > ((x2 - x1).abs)
    if steep
      x1, y1 = y1, x1
      x2, y2 = y2, x2
    end
    if x1 > x2
      x1, x2 = x2, x1
      y1, y2 = y2, y1
    end
    dx = x2 - x1
    dy = (y2 - y1).abs
    error = (dx / 2).to_i
    y = y1
    ystep = nil
    if y1 < y2
      ystep = 1
    else
      ystep = -1
    end
    for x in x1..x2
      if steep
        points << Vector.new(y, x)
      else
        points << Vector.new(x, y)
      end
      error -= dy
      if error < 0
        y += ystep
        error += dx
      end
    end

    points.sort do |a, b|
      (a.x - px) * (a.x - px) + (a.y - py) * (a.y - py) <=>
      (b.x - px) * (b.x - px) + (b.y - py) * (b.y - py)
    end
  end


  internal def self.get_first_entity_and_cut lines
    newLines = []

    lines.each_with_index do |line, i|
      entity, cut_at = find_first_entity line
      cut_at += 1

      newLines[i] = {
        line: line[0...cut_at],
        entity: entity
      }

      break if i == 0 and not entity.nil?
    end

    return newLines
  end


  internal def self.find_first_entity line
    line.each_with_index do |point, i|
      if blocked? point.x, point.y, false
        return nil, i
      else
        Entities.filter_at(point).each do |entity|
          next if entity.position == @origin_position or
                  not entity.physical&.blocking
          return entity, i
        end
      end
    end

    return nil, line.count - 1
  end


  internal def self.find_line_with_closest_entity lines
    closest_distance   = nil
    closest_line_index = nil

    lines.each_with_index do |line, i|
      next if line.entity.nil?
      distance = line.entity.position.x *
                 line.entity.position.x +
                 line.entity.position.y *
                 line.entity.position.y

      if closest_distance.nil? or distance < closest_distance
        closest_distance   = distance
        closest_line_index = i
      end
    end

    return lines[ closest_line_index ]
  end


  internal def self.find_longest_line lines
    lines.sort_by { |line| line.line.count }
         .last
  end


  internal def self.blocked? x, y, sight = true
    if sight
      return !Map.can_see?(x, y)
    else
      return !Map.can_fly?(x, y)
    end
  end

end
