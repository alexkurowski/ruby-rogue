def System.sprite_movement
  entities = Entities.filter_by_component :sprite

  entities.each do |entity|
    if entity.sprite.dx.abs > 0.1
      entity.sprite[:dx] *= drag
    end

    if entity.sprite.dy.abs > 0.1
      entity.sprite[:dy] *= drag
    end
  end
end


def drag
  0.8
end
