def System.sprite_movement
  entities = Entities.filter_by_component :sprite

  entities.each do |entity|
    if entity.sprite.dx.abs > min_difference
      entity.sprite[:dx] *= drag
    end

    if entity.sprite.dy.abs > min_difference
      entity.sprite[:dy] *= drag
    end

    if entity.sprite.dx.abs <= min_difference
      entity.sprite[:dx] = 0
    end

    if entity.sprite.dy.abs <= min_difference
      entity.sprite[:dy] = 0
    end
  end
end


def min_difference
  0.1
end


def drag
  if Display.big?
  then 0
  else 0.6
  end
end
