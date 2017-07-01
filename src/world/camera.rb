module Camera

  global :left_cell,
         :top_cell,
         :dx,
         :dy


  def self.init
    @offset = { x: 0, y: 0 }
    @target = { x: 0, y: 0 }
  end


  def self.update
    target = Entities.find_by_component :player

    @target[:x] = target.position.x * Display.cell_width  - Display.width  * Display.cell_width  * 0.5
    @target[:y] = target.position.y * Display.cell_height - Display.height * Display.cell_height * 0.5

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


  internal def self.min_difference
    0.1
  end


  internal def self.drag
    0.1
  end

end
