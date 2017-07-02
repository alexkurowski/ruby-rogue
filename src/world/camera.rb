module Camera

  global :left_cell,
         :top_cell,
         :dx,
         :dy


  def self.init
    @offset      = { x: 0, y: 0 }
    @target_cell = { x: 0, y: 0 }
    @target      = { x: 0, y: 0 }
  end


  def self.update
    entity = Entities.find_by_component :player

    distance = Math.sqrt ( entity.position.x - @target_cell.x ) *
                         ( entity.position.x - @target_cell.x ) +
                         ( entity.position.y - @target_cell.y ) *
                         ( entity.position.y - @target_cell.y )
    moving = entity.sprite.dx.abs > 1 || entity.sprite.dy.abs > 1

    if distance > max_target_distance or not moving
      @target_cell[:x] = entity.position.x
      @target_cell[:y] = entity.position.y
    end

    @target[:x] = @target_cell.x * Display.cell_width  - Display.width  * Display.cell_width  * 0.5
    @target[:y] = @target_cell.y * Display.cell_height - Display.height * Display.cell_height * 0.5

    @offset[:x] += (@target.x - @offset.x) * drag
    @offset[:y] += (@target.y - @offset.y) * drag

    if ( @target.x - @offset.x ).abs <= min_difference
      @offset[:x] = @target.x
    end

    if ( @target.y - @offset.y ).abs <= min_difference
      @offset[:y] = @target.y
    end

    @left_cell = ( @offset.x / Display.cell_width  ).round
    @top_cell  = ( @offset.y / Display.cell_height ).round
    @dx = @offset.x + Display.cell_width  * 0.5
    @dy = @offset.y + Display.cell_height * 0.5
  end


  internal def self.max_target_distance
    0
  end


  internal def self.min_difference
    0.1
  end


  internal def self.drag
    0.1
  end

end
