def System.player_actions
  return unless Input.action

  e = Entities.find_by_component :player

  case Input.action
  when :go_west       then move e, -1,  0
  when :go_east       then move e, +1,  0
  when :go_north      then move e,  0, -1
  when :go_south      then move e,  0, +1
  when :go_north_west then move e, -1, -1
  when :go_north_east then move e, +1, -1
  when :go_south_west then move e, -1, +1
  when :go_south_east then move e, +1, +1
  end
end

def move entity, dx, dy
  if can_move entity, dx, dy
    entity.position[:x] += dx
    entity.position[:y] += dy
  end
end

def can_move entity, dx, dy
  Map.can_walk? entity.position.x + dx, entity.position.y + dy
end
