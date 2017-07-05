module Fov

  def self.init
    opts = CONFIG.fov_options

    set_radius opts.normal_radius

    @width      = Map.width
    @height     = Map.height
    @dirty      = true
    @center     = new_vector
    @old_center = new_vector

    @map = Array.new(@width) { Array.new(@height) { :none } }
  end


  def self.update
    entity = Entities.find_by_component :player

    @old_center[:x] = @center.x
    @old_center[:y] = @center.y

    @center[:x] = entity.position.x
    @center[:y] = entity.position.y

    @dirty = @force_dirty ||
             @center.x != @old_center.x ||
             @center.y != @old_center.y
    @force_dirty = false

    update_map
  end


  def self.set_radius new_radius
    @radius    = new_radius
    @radius_sq = new_radius * new_radius
  end


  def self.set_dirty
    @force_dirty = true
  end


  def self.at x, y
    if x < 0 or x > @width - 1 or
       y < 0 or y > @height - 1
      :none
    else
      @map[x][y]
    end
  end


  def self.check_line x1, y1, x2, y2, radius = nil
    radius ||= @radius

    return false if x1 < 0 or x1 >= @width or
                    y1 < 0 or y1 >= @height or
                    x2 < 0 or x2 >= @width or
                    y2 < 0 or y2 >= @height

    distance = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
    return false if distance >= radius * radius

    return true if x1 == x2 and y1 == y2

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

        break if blocked? x1 + x_relative, y1 + y_relative
      end

      if swapped_axis
        return true if y_offset == y_relative
      else
        return true if x_offset == x_relative
      end
    end

    return false
  end


  internal def self.update_map
    return unless @dirty

    hide_old_fov
    calculate_new_fov
  end


  internal def self.hide_old_fov
    x1 = [ @old_center.x - @radius, 0 ].max.floor
    x2 = [ @old_center.x + @radius, @width - 1 ].min.floor
    y1 = [ @old_center.y - @radius, 0 ].max.floor
    y2 = [ @old_center.y + @radius, @height - 1 ].min.floor

    for x in x1..x2
      for y in y1..y2
        @map[x][y] = :half if @map[x][y] == :full
      end
    end
  end


  internal def self.calculate_new_fov
    light @center.x, @center.y

    min_extent_x = [@center.x, @radius].min
    max_extent_x = [@width - @center.x - 1, @radius].min
    min_extent_y = [@center.y, @radius].min
    max_extent_y = [@height - @center.y - 1, @radius].min

    check_quadrant +1, +1, max_extent_x, max_extent_y
    check_quadrant +1, -1, max_extent_x, min_extent_y
    check_quadrant -1, -1, min_extent_x, min_extent_y
    check_quadrant -1, +1, min_extent_x, max_extent_y
  end


  internal def self.light x, y
    if x >= 0 and x < @width and
       y >= 0 and y < @height
      @map[x][y] = :full
    end
  end


  internal def self.blocked? x, y
    not Map.can_see? x, y
  end


  internal def self.check_quadrant dx, dy, extent_x, extent_y
    active_views = []
    shallow_line = Line.new 0, 1, extent_x, 0
    steep_line   = Line.new 1, 0, 0, extent_y

    active_views << View.new(shallow_line, steep_line)
    view_index = 0

    # Visit the tiles diagonally and going outwards
    i     = 1
    max_i = extent_x + extent_y
    while i <= max_i and active_views.size > 0
      j     = [0, i - extent_x].max
      max_j = [i, extent_y].min
      while j <= max_j and view_index < active_views.size
        x = i - j
        y = j
        visit_coord x, y, dx, dy, view_index, active_views
        j += 1
      end
      i += 1
    end
  end


  internal def self.visit_coord x, y, dx, dy, view_index, active_views
    # The top left and bottom right corners of the current coordinate
    top_left     = [x, y + 1]
    bottom_right = [x + 1, y]

    while view_index < active_views.size and
      active_views[view_index].steep_line.below_or_collinear?(*bottom_right)
      # Co-ord is above the current view and can be ignored (steeper fields may need it though)
      view_index += 1
    end

    if view_index == active_views.size or
      active_views[view_index].shallow_line.above_or_collinear?(*top_left)
      # Either current co-ord is above all the fields, or it is below all the fields
      return
    end

    # Current co-ord must be between the steep and shallow lines of the current view
    # The real quadrant co-ordinates:
    real_x  = x * dx
    real_y  = y * dy
    coord_x = @center.x + real_x
    coord_y = @center.y + real_y

    # Don't light tiles beyond circular radius specified
    if real_x * real_x + real_y * real_y < @radius_sq
      light coord_x, coord_y
    end

    # If this co-ord does not block sight, it has no effect on the view
    return unless blocked? coord_x, coord_y

    view = active_views[view_index]
    if view.shallow_line.above?(*bottom_right) and view.steep_line.below?(*top_left)
      # Co-ord is intersected by both lines in current view, and is completely blocked
      active_views.delete(view)
    elsif view.shallow_line.above?(*bottom_right)
      # Co-ord is intersected by shallow line; raise the line
      add_shallow_bump top_left[0], top_left[1], view
      check_view active_views, view_index
    elsif view.steep_line.below?(*top_left)
      # Co-ord is intersected by steep line; lower the line
      add_steep_bump bottom_right[0], bottom_right[1], view
      check_view active_views, view_index
    else
      # Co-ord is completely between the two lines of the current view. Split the
      # current view into two views above and below the current co-ord.
      shallow_view_index = view_index
      steep_view_index   = view_index += 1
      active_views.insert shallow_view_index, active_views[shallow_view_index].deep_copy
      add_steep_bump bottom_right[0], bottom_right[1], active_views[shallow_view_index]

      unless check_view active_views, shallow_view_index
        view_index -= 1
        steep_view_index -= 1
      end

      add_shallow_bump top_left[0], top_left[1], active_views[steep_view_index]
      check_view active_views, steep_view_index
    end
  end


  internal def self.add_shallow_bump x, y, view
    view.shallow_line.xf = x
    view.shallow_line.yf = y
    view.shallow_bump = ViewBump.new x, y, view.shallow_bump

    cur_bump = view.steep_bump
    while not cur_bump.nil?
      if view.shallow_line.above? cur_bump.x, cur_bump.y
        view.shallow_line.xi = cur_bump.x
        view.shallow_line.yi = cur_bump.y
      end
      cur_bump = cur_bump.parent
    end
  end


  internal def self.add_steep_bump x, y, view
    view.steep_line.xf = x
    view.steep_line.yf = y
    view.steep_bump = ViewBump.new x, y, view.steep_bump

    cur_bump = view.shallow_bump
    while not cur_bump.nil?
      if view.steep_line.below? cur_bump.x, cur_bump.y
        view.steep_line.xi = cur_bump.x
        view.steep_line.yi = cur_bump.y
      end
      cur_bump = cur_bump.parent
    end
  end


  # Removes the view in active_views at index view_index if:
  # * The two lines are collinear
  # * The lines pass through either extremity
  internal def self.check_view active_views, view_index
    shallow_line = active_views[view_index].shallow_line
    steep_line   = active_views[view_index].steep_line
    if shallow_line.line_collinear? steep_line and
       (shallow_line.collinear?(0, 1) or shallow_line.collinear?(1, 0))
      active_views.delete_at view_index
      return false
    end
    return true
  end

end


class Fov::Line < Struct.new :xi, :yi, :xf, :yf

  # Macros to make slope comparisons clearer
  {
    below:              '>',
    below_or_collinear: '>=',
    above:              '<',
    above_or_collinear: '<=',
    collinear:          '=='
  }.each do |name, fn|
    eval "def #{name.to_s}?(x, y) relative_slope(x, y) #{fn} 0 end"
  end


  def dx; xf - xi end
  def dy; yf - yi end


  def line_collinear?(line)
    collinear? line.xi, line.yi and
    collinear? line.xf, line.yf
  end


  def relative_slope(x, y)
    (dy * (xf - x)) - (dx * (yf - y))
  end

end


class Fov::ViewBump < Struct.new :x, :y, :parent

  def deep_copy
    Fov::ViewBump.new(x, y, parent.nil? ? nil : parent.deep_copy)
  end

end


class Fov::View < Struct.new :shallow_line, :steep_line

  attr_accessor :shallow_bump, :steep_bump


  def deep_copy
    copy = Fov::View.new shallow_line.dup, steep_line.dup
    copy.shallow_bump = shallow_bump.nil? ? nil : shallow_bump.deep_copy
    copy.steep_bump   = steep_bump.nil? ? nil : steep_bump.deep_copy
    return copy
  end

end
