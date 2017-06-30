def System.player_movement
  return unless Input.action

  e = Entities.find_by_component :player

  case Input.action
  when :go_west
    e.position[:x] -= 1

  when :go_east
    e.position[:x] += 1

  when :go_north
    e.position[:y] -= 1

  when :go_south
    e.position[:y] += 1

  when :go_north_west
    e.position[:x] -= 1
    e.position[:y] -= 1

  when :go_north_east
    e.position[:x] += 1
    e.position[:y] -= 1

  when :go_south_west
    e.position[:x] -= 1
    e.position[:y] += 1

  when :go_south_east
    e.position[:x] += 1
    e.position[:y] += 1

  end
end
