module Renderer::UI

  def self.before
    Display.clear_ui
    Display.composition true

    Log.submit
    @cursor_hidden = false if @cursor_hidden and Input.mouse_moved?
  end


  def self.render
    entity = World.player

    @cursor_hidden = true if Input.disabled?

    draw_line_of_fire entity
    draw_examine entity
    draw_cursor entity

    draw_log

    if Game.debug
      str1 = "Player: #{entity.position.x}:#{entity.position.y}"
      str2 = "Cursor: #{Input.cursor.x}:#{Input.cursor.y}"
      Display.print_log str1, Display.width - str1.length, 0
      Display.print_log str2, Display.width - str2.length, 1
    end
  end


  internal def self.draw_line_of_fire entity
    return if World.turn != :player

    return if entity.sprite.offset.x != 0 or
              entity.sprite.offset.y != 0

    return if @cursor_hidden and
              entity.player.mode != :fire

    return if entity.player.mode != :normal and
              entity.player.mode != :fire

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

    color = if entity.player.mode == :fire
            then '#aaaa0000'
            else '#aa00aa00'
            end

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


  internal def self.draw_log
    count = 5
    lines = Log.last count
    Display.print_log_lines lines, 0, Display.height - 1, direction: :up
  end


  internal def self.draw_examine entity
    target =
    if entity.player.mode == :examine
    then entity.player.cursor
    else Input.mouse + Camera.position
    end

    return unless Fov.at(target) == :full

    lines = []

    Entities.filter_at(target).each do |entity|
      if entity.player?
        lines << 'Yourself'
      elsif entity.npc?
        lines << entity.npc.ai.to_s.capitalize
      end
    end

    tile_type, tile_status = Map.get_tile target.x, target.y

    lines <<
    if tile_status == 'normal'
    then tile_type
    else tile_status + ' ' + tile_type
    end.capitalize

    lines = "You see: #{lines.join ', '}"
    Display.print_log_lines [lines], 0, 0
  end


  def self.after
    Display.composition false
  end

end
