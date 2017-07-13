def System.npc_actions
  return unless World.turn == :npc

  World.turn = :player
end
