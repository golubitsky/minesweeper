class Tile
  attr_accessor :bombed, :flagged, :revealed, :neighbors, :adjacent_bomb_count, :cursor

  def initialize(bombed = false)
    @bombed = bombed
    @flagged = false
    @revealed = false
    @neighbors = []
    @adjacent_bomb_count = 0
  end

  def bombed?
    bombed
  end

  def flagged?
    flagged
  end

  def revealed?
    revealed
  end

  def reveal
    self.revealed = true
  end
end
