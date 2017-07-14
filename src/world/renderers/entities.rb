module Renderer::Entities

  def self.before
    Display.clear_entities
  end


  def self.render
    Entities.filter_by_components(
      :position,
      :sprite
    ).each do |entity|
      if entity_is_on_screen? entity

        fov = Fov.at entity.position

        next unless fov == :full or
                    entity.player?

        position = entity.position - Camera.position
        offset   = entity.sprite.offset - Camera.offset
        char     = entity.sprite.char.ord
        color    = entity.sprite.color

        Display.draw char, color, position, offset

      end
    end
  end


  internal def self.entity_is_on_screen? entity
    not entity.sprite.char.empty? &&
    entity.position.x >= Camera.position.x &&
    entity.position.y >= Camera.position.y &&
    entity.position.x < Camera.position.x + Display.width &&
    entity.position.y < Camera.position.y + Display.height
  end

end
