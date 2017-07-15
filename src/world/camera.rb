module Camera

  global :position,
         :offset


  def self.init
    @position = Vector.new
    @offset   = Vector.new

    @coords = Vector.new
    @target = Vector.new
    @dirty  = true
  end


  def self.update
    entity = World.player

    @target.x = entity.position.x - Display.width  * 0.5 + 1
    @target.y = entity.position.y - Display.height * 0.5 + 1

    old_coords_x = @coords.x
    old_coords_y = @coords.y

    @coords.x += (@target.x - @coords.x) * drag
    @coords.y += (@target.y - @coords.y) * drag

    @coords.x = @target.x if ( @target.x - @coords.x ).abs <= min_difference
    @coords.y = @target.y if ( @target.y - @coords.y ).abs <= min_difference

    @dirty = @force_dirty ||
             @coords.x != old_coords_x ||
             @coords.y != old_coords_y
    @force_dirty = false

    @position.x = @target.x.floor
    @position.y = @target.y.floor
    @offset.x = ( @coords.x - @target.x ) * Display.cell_width
    @offset.y = ( @coords.y - @target.y ) * Display.cell_height
  end


  def self.jump_to x, y
    @coords.x = @target.x = x - Display.width  * 0.5 + 1
    @coords.y = @target.y = y - Display.height * 0.5 + 1
  end


  def self.set_dirty
    @force_dirty = true
  end


  def self.dirty?
    @dirty
  end


  internal def self.max_target_distance
    0
  end


  internal def self.min_difference
    0.1
  end


  internal def self.drag
    if Display.big?
    then 1
    else 0.1
    end
  end

end
