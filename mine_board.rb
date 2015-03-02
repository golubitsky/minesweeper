require_relative 'mine_tile.rb'
require 'matrix'
require 'colorize'

class Board
  attr_accessor :board, :bomb_count, :revealed, :lost, :won, :cursor

  def initialize(bomb_count = 11)
    @board = Array.new(9) {Array.new(9) {Tile.new}} #populate board
    @cursor = [0, 0]
    @revealed = []
    @lost = false
    @won = true
    @bomb_count = bomb_count
    define_neighbors
    place_bombs
  end

  def place_bombs
    bomb_counter = 0
    while bomb_counter < bomb_count #generate bomb tiles
      x = rand(9)
      y = rand(9)
      unless board[x][y].bombed?
        self.board[x][y].bombed = true #set a bombed tile
        board[x][y].neighbors.each do |x_neighbor, y_neighbor|
          board[x_neighbor][y_neighbor].adjacent_bomb_count += 1
        end
        self.inspect
        bomb_counter += 1
      end
    end
  end

  def define_neighbors
    board.each_with_index do |row, x|
      row.each_with_index do |tile, y|
        tile.neighbors = find_valid_neighbors(x,y)
      end
    end
  end

  def find_valid_neighbors(x, y)
    valid_neighbors = []
    vectors = [-1, 0, 1].product([-1, 0, 1]).reject { |x| x == [0, 0] }.map { |arr| Vector.elements(arr) }
    vectors.each do |vector|
      current_coord = (Vector.elements([x, y]) + vector).to_a
      valid_neighbors << current_coord if valid?(current_coord)
    end
    valid_neighbors
  end

  def valid?(coord)
    x, y = coord
    (0..8) === x && (0..8) === y
  end

  def render(game_over)
    board.each_with_index do |row, x|
      row.each_with_index do |tile, y|
        char_to_print = ''
        if tile.bombed? && tile.revealed?
          char_to_print = "X"
        elsif tile.revealed?
          char_to_print = tile.adjacent_bomb_count.to_s
        elsif tile.flagged?
          char_to_print = "F"
        else
          char_to_print = " "
        end

        if [x, y] == cursor
          print char_to_print.blue.on_green.blink
          print ' '.blue.on_green.blink
        else
          print char_to_print.colorize(background: :cyan)
          print ' '.colorize(background: :cyan)
        end
      end
      print "\n"
    end

    unless game_over
      puts ''
      print "press c to show/hide controls"
    end
  end

  def print_controls
    puts ''
    puts "arrows: select a square"
    puts "space: flag square as a mine"
    puts "enter: reveal square"
    puts "s: save game"
    puts "l: load game"
    puts "esc: quit"
  end


  def reveal_tile(x, y)
    this_tile = board[x][y]
    revealed << [x,y]
    this_tile.reveal
    if this_tile.bombed?
      self.lost = true
    elsif this_tile.adjacent_bomb_count == 0
      this_tile.neighbors.each do |x_neighbor, y_neighbor|
        unless revealed.include?([x_neighbor, y_neighbor])
          reveal_tile(x_neighbor, y_neighbor)
        end
      end
    end
  end

  def flag_tile(x, y)
    current_tile = board[x][y]
    unless current_tile.revealed?
      current_tile.flagged = current_tile.flagged? ? false : true
    end
  end

  def unflag_tile(x, y)
    board[x][y].flagged = false if board[x][y].flagged?
  end

  def lost?
    lost
  end

  def won?
    board.each do |row|
      row.each do |tile|
          return false if (tile.bombed? == false && tile.revealed? == false)
      end
    end
    self.won = true
  end

  def move_cursor(direction)
    cursor_vec = Vector.elements(cursor)
    case direction
    when "up"
      self.cursor = (cursor_vec + Vector[-1, 0]).to_a
    when "down"
      self.cursor = (cursor_vec + Vector[1, 0]).to_a
    when "left"
      self.cursor = (cursor_vec + Vector[0, -1]).to_a
    when "right"
      self.cursor = (cursor_vec + Vector[0, 1]).to_a
    end
    self.cursor = cursor.map do |x|
      if x < 0
        x += 9
      elsif x > 8
        x -= 9
      else
        x
      end
    end
  end
end
