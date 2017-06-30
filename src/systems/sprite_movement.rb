def System.sprite_movement
  es = Entities.filter_by_component :sprite

  es.each do |e|
    if e.sprite.dx.abs > 0.1
      e.sprite[:dx] *= drag
    end

    if e.sprite.dy.abs > 0.1
      e.sprite[:dy] *= drag
    end

    if e.include? :player
      if e.sprite.dx.abs.floor < 1 and
         e.sprite.dy.abs.floor < 1
        Input.enable
      end
    end
  end
end


def drag
  0.8
end
