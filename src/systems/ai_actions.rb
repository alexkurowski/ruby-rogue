def System.ai_actions
  return unless World.turn == :enemy

  World.turn = :player
end
