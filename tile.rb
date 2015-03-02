def Tile
  attr_accessor :bombed, :flagged, :revealed

  def initialize
    @bomded = false
    @flagged = false
    @revealed = false
  end

  def bombed?
    bomded
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
