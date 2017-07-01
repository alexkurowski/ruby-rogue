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
  end
end


def move entity, dx, dy
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
