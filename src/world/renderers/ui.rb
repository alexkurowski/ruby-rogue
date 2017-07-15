module Renderer::UI

  def self.before
    Display.clear_ui
  end


  def self.render
    entity = World.player

    draw_line_of_fire entity
    draw_cursor entity

    if Game.debug
      Terminal.print 0, 0, "Player: #{entity.position.x}:#{entity.position.y}"
      Terminal.print 0, 1, "Cursor: #{Input.cursor.x}:#{Input.cursor.y}"
    end
  end


  internal def self.draw_line_of_fire entity
    return if World.turn != :player
    return if entity.sprite.offset.length.abs > 0.1

    target = if entity.player.mode == :fire
             then entity.player.cursor
             else Input.cursor
             end

    return if Fov.at(target) != :full

    line = Los.line_of_fire(
      from: entity.position,
      to: target,
      radius: entity.creature.sight
    ).reject do |point|
      Fov.at(point) != :full ||
      point.x == entity.position.x &&
      point.y == entity.position.y
    end.map do |point|
      point - Camera.position
    end

    char  = '¿'.ord
    color = '#aaff0000'

    Display.draw_set line, char, color
  end


  internal def self.draw_cursor entity
    target =
    if entity.player.mode == :fire or entity.player.mode == :examine
    then entity.player.cursor - Camera.position
    else Input.mouse
    end

    char  = '¿'.ord
    color = Terminal.color_from_name 'white'

    Display.draw char, color, target
  end

end
