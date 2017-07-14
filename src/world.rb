module World

  global :player,
         :turn,
         :initial_pc_state,
         :initial_npc_state


  def self.init
    Map.init
    Entities.init
    Camera.init
    Fov.init
    Los.init

    place_player
    place_npc

    @turn = :player

    @active_systems = [
      System::PcActions,
      System::AI,
      System::SpriteMovement
    ]
  end


  internal def self.place_player
    return if @initial_pc_state.nil?

    Entities.prefab :player do |entity|
      entity.position.x = @initial_pc_state.x
      entity.position.y = @initial_pc_state.y

      @player = entity

      Camera.jump_to entity.position.x, entity.position.y - 10
    end
  end


  internal def self.place_npc
    return if @initial_npc_state.nil?

    @initial_npc_state.each do |npc|
      Entities.prefab npc.type do |entity|
        entity.position.x = npc.position.x
        entity.position.y = npc.position.y
      end
    end
  end


  def self.update
    @active_systems.each do |system|
      system.run
    end
  end


  def self.render
    Camera.update
    Fov.update

    Renderer.render_tiles
    Renderer.render_entities
    Renderer.render_ui

    Display.refresh
  end

end
