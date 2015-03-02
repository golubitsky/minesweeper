require_relative 'mine_tile.rb'
require_relative 'mine_board.rb'


require 'yaml'
require 'io/console' #for controller functionality
class MineSweeper

  attr_accessor :board

  def initialize
    @board = Board.new
    play
  end

  def play
    print_controls = false
    until game_over?
      system "clear"

      board.render(false)
      if print_controls
        board.print_controls
      end

      input_char = read_char
      coord = board.cursor
      #get controller input and perform functions
      case input_char
      when "\r" #RETURN
        board.reveal_tile(*coord)
      when " " #SPACE
        board.flag_tile(*coord)
      when "\e" #ESC
        puts "Are you sure you want to exit the game? (y/n)"
        if gets.chomp == "y"
          exit
        end
      when "\e[A" #up arrow
        board.move_cursor("up")
      when "\e[B" #down
        board.move_cursor("down")
      when "\e[C" #right
        board.move_cursor("right")
      when "\e[D" #left
        board.move_cursor("left")
      when "s"
        save_game
      when "l"
        load_game
      when "c"
        print_controls = print_controls ? false : true
      when "\u0003" #ctrl-c
        exit 0
      else
      end
    end

    game_over_message
  end

  def game_over_message
    system "clear"
    board.render(true)
    puts 'Game over!'
    if board.lost?
      puts "Sorry, you lose."
    else
      puts "Congratulations, you win!"
    end

    exit
  end

  def game_over?
    board.lost? || board.won?
  end

  def save_game
    puts ''
    puts "Enter file_name to save to (without extension)"
    file_name = gets.chomp
    File.open("#{file_name}.yaml", 'w') { |f| f.puts board.to_yaml}
    puts "Game saved successfully to #{file_name}.yaml"
    puts "Continue? (y/n)"
    if gets.chomp == "n"
      exit
    end
  end

  def load_game
    puts ''
    puts "Enter file_name to load from (without extension) or q to go back"
    file_name = gets.chomp
    return if file_name == "q"
    @board = File.open("#{file_name}.yaml", 'r') { |f| YAML::load(f) }
    puts "Game loaded successfully."
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end
end

MineSweeper.new
