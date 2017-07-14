module Renderer

  def self.render_tiles
    return unless Camera.dirty?

    Tiles.before
    Tiles.render
    Tiles.after
  end


  def self.render_entities
    Entities.before
    Entities.render
  end


  def self.render_ui
    UI.before
    UI.render
  end

end
