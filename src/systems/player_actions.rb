def System.player_actions
  return unless Input.action

  entity = Entities.find_by_component :player

  case Input.action
  when :go_west       then move entity, -1,  0
  when :go_east       then move entity, +1,  0
  when :go_north      then move entity,  0, -1
  when :go_south      then move entity,  0, +1
  when :go_north_west then move entity, -1, -1
  when :go_north_east then move entity, +1, -1
  when :go_south_west then move entity, -1, +1
  when :go_south_east then move entity, +1, +1
  when :fire          then fire entity
  when :fire!         then mouse_fire entity
  when :cancel        then cancel entity
  end
end


def move entity, dx, dy
  case entity.player.mode
  when :normal
    move_entity entity, dx, dy
  when :fire
    move_aim entity, dx, dy
  end
end


def move_entity entity, dx, dy
  if can_move entity, dx, dy
    entity.position[:x] += dx
    entity.position[:y] += dy

    entity.sprite[:dx] -= Display.cell_width  * dx
    entity.sprite[:dy] -= Display.cell_height * dy

    Input.disable_for 1
  end
end


def can_move entity, dx, dy
  Map.can_walk? entity.position.x + dx, entity.position.y + dy
end


def move_aim entity, dx, dy
  entity.player[:aim_x] += dx
  entity.player[:aim_y] += dy
end


def fire entity
  case entity.player.mode
  when :normal
    entity.player[:aim_x] = entity.position.x
    entity.player[:aim_y] = entity.position.y
    entity.player[:mode] = :fire

  when :fire
    shoot entity
    entity.player[:mode] = :normal
  end
end


def mouse_fire entity
  if entity.player.mode == :normal
    entity.player[:aim_x] = Input.mouse_x + Camera.x
    entity.player[:aim_y] = Input.mouse_y + Camera.y
    shoot entity
  end
end


def shoot entity
  puts "PEW from #{entity.position.x}:#{entity.position.y} at #{entity.player.aim_x}:#{entity.player.aim_y}"
  Input.disable_for 1
end


def cancel entity
  entity.player[:mode] = :normal
end
