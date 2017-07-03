module Fov

  def self.init
    opts = CONF.fov_options

    @radius     = opts.normal_radius
    @dirty      = true
    @center     = new_vector
    @old_center = new_vector

    @map = Array.new(Map.width) { Array.new(Map.height) { :none } }
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


  def self.at x, y
    # :full, :half or :none
    # for 'in sight', 'seen' and 'not seen'
    @map[x][y]
  end


  def self.set_dirty
    @force_dirty = true
  end


  internal def self.update_map
    return unless @dirty

    hide_old_fov
    calculate_new_fov
  end


  internal def self.hide_old_fov
    x1 = ( @old_center.x - @radius ).floor
    x2 = ( @old_center.x + @radius ).ceil
    y1 = ( @old_center.y - @radius ).floor
    y2 = ( @old_center.y + @radius ).ceil

    for x in x1..x2
      for y in y1..y2
        @map[x][y] = :half if @map[x][y] == :full
      end
    end
  end


  internal def self.calculate_new_fov
    x1 = ( @center.x - @radius ).floor
    x2 = ( @center.x + @radius ).ceil
    y1 = ( @center.y - @radius ).floor
    y2 = ( @center.y + @radius ).ceil

    for x in x1..x2
      for y in y1..y2
        distance = Math.sqrt (@center.x - x) * (@center.x - x) + (@center.y - y) * (@center.y - y)

        @map[x][y] = :full if distance < @radius
      end
    end
  end

end
