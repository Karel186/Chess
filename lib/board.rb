require_relative "pieces"
require_relative "modules_helper"

class Board
  include MovementLimitation

    attr_accessor :board
    attr_reader :turn
    def initialize
        @board = Hash.new(" ")
        @turn = 0
    end

    # User choose which and where to move
    def user_input()
      @turn += 1
      continue = false
      while continue != true
        input = gets.chomp#"e4:c2"
        from_cell, to_cell = split_user_input(input)
        if @board[from_cell] != " " && is_legal?(from_cell,to_cell,@board) && !same_color?(from_cell,to_cell,@board)
          continue = true
          @board[to_cell] = @board[from_cell]
          @board[from_cell] = ' '
        else
          puts @board[from_cell] == " " ? "Please choose a piece to move" : "Please choose a valid destination"
        end
      end
      #print_board
    end
    
    # Return 1 for checkmate, -1 for check, 0 for not check
    def checkmate
      if check?(@board)
        king_cell = cell_of_king(@board)
        king_moves = free_moves(king_cell,@board)
        king_moves.select!{|cell| @board[king_cell] == " " || !same_color?(king_cell,cell,@board)}
        num_moves = king_moves.length
        count = 0
        king_moves.each do |cell|
          copy_board = @board.clone
          copy_board[cell] = copy_board[king_cell]
          copy_board[king_cell] = " "
          count += 1 if check?(copy_board)
        end
        if count == num_moves
          return 1
        else
          return -1
        end
      else
        return 0
      end
    end

    # Returns if there is a check based on current turn
    def check?(board)
      hash_cells = cells_to_king(board)
      cells = hash_cells[:moves]
      check = false
      piece_in_cells = cells.find_all{|x| board[x] != " "}
      piece_in_cells.each do |cell|
        moves = free_moves(cell,board)
        if moves.include?(hash_cells[:king_cell]) && !same_color?(cell,hash_cells[:king_cell],board)
          check = true 
        end
      end
    return check
    end

    def cells_to_king(board)
      color = which_turn
      king_cell = cell_of_king(board)
      board[king_cell] = Queen.new(color)
      moves_to_king_1 = free_moves(king_cell,board)
      board[king_cell] = Knight.new(color)
      moves_to_king_Bishop = free_moves(king_cell,board)
      board[king_cell] = color == "black" ? @black_king : @white_king
      moves_to_king = moves_to_king_1 + moves_to_king_Bishop
      moves_king = {:king_cell => king_cell, :moves => moves_to_king}
      return moves_king
    end

    def cell_of_king(board)
      return which_turn == "black" ? board.key(@black_king) : board.key(@white_king)
    end

    # Returns the colour of the current turn
    def which_turn
      if (@turn+1).even?
        colour = "black"
      else
        colour = "white"
      end
      return colour
    end

    # Check if colors of pieces are the same
    def same_color?(from_cell,to_cell,board)
      return false if board[from_cell] == " " || board[to_cell] == " "
      return board[from_cell].color == board[to_cell].color ? true : false
    end

    # Return symbols for initial cell and the final cell it should gp (from cell to another cell)
    def split_user_input(input)
      split_input = input.upcase.split(":")
      from_cell = split_input[0].to_sym
      to_cell = split_input[1].to_sym
      return from_cell,to_cell
    end

    # Return whether or not the user choice of movement respects the rules of each piece
    def is_legal?(from_cell,to_cell,board)
      moves = free_moves(from_cell,board)
      #p moves
      return moves.include? to_cell
    end

    # Return an array of all cells that can be actually be reached based on other pieces around the board
    def free_moves(from_cell,board)
      moves = all_available_moves(board[from_cell],from_cell)
      if ['Rook','Bishop','Queen','Pawn'].include? board[from_cell].class.name
        moves = self.send("limit_#{board[from_cell].class.name}",moves,from_cell,board) 
      end
      return moves
    end

    # Return an array of all cells that can be reached within the board
    def all_available_moves(klass,current_position)
      moves = []
      for i in klass.movement(current_position)
        moves.push(i) if is_inside?(i)
      end
      return moves
    end

    # Return whether is on board or not
    def is_inside?(sym)
      x = sym[0]
      y = sym[1..-1].to_i
      if x.between?("A","H") && y.between?(1,8)
        return true
      else
        return false
      end
    end

    # Initialize new board by setting pieces in correct initial positions
    def new_board()
      b = "black"; w = "white"
      # Inserting Pawns
      ("A".."H").each do |char| 
        sym_b = (char +"2").to_sym
        sym_w = (char +"7").to_sym
        @board[sym_b] = Pawn.new(b)
        @board[sym_w] = Pawn.new(w)
      end

      # Inserting black pieces
      @black_king = King.new(b)
      @board[:E1] = @black_king
      @board[:D1] = Queen.new(b)
      @board[:A1] = @board[:H1] = Rook.new(b)
      @board[:B1] = @board[:G1] = Knight.new(b)
      @board[:C1] = @board[:F1] = Bishop.new(b)
      

      # Inserting white pieces
      @white_king = King.new(w)
      @board[:E8] = @white_king
      @board[:D8] = Queen.new(w)
      @board[:A8] = @board[:H8] = Rook.new(w)
      @board[:B8] = @board[:G8] = Knight.new(w)
      @board[:C8] = @board[:F8] = Bishop.new(w)
      
    end

    def print_board()
        puts "
        A   B   C   D   E   F   G   H
      ╔═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╗
    1 ║ #{@board[:A1]} ║ #{@board[:B1]} ║ #{@board[:C1]} ║ #{@board[:D1]} ║ #{@board[:E1]} ║ #{@board[:F1]} ║ #{@board[:G1]} ║ #{@board[:H1]} ║ 1
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    2 ║ #{@board[:A2]} ║ #{@board[:B2]} ║ #{@board[:C2]} ║ #{@board[:D2]} ║ #{@board[:E2]} ║ #{@board[:F2]} ║ #{@board[:G2]} ║ #{@board[:H2]} ║ 2
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    3 ║ #{@board[:A3]} ║ #{@board[:B3]} ║ #{@board[:C3]} ║ #{@board[:D3]} ║ #{@board[:E3]} ║ #{@board[:F3]} ║ #{@board[:G3]} ║ #{@board[:H3]} ║ 3
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    4 ║ #{@board[:A4]} ║ #{@board[:B4]} ║ #{@board[:C4]} ║ #{@board[:D4]} ║ #{@board[:E4]} ║ #{@board[:F4]} ║ #{@board[:G4]} ║ #{@board[:H4]} ║ 4
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    5 ║ #{@board[:A5]} ║ #{@board[:B5]} ║ #{@board[:C5]} ║ #{@board[:D5]} ║ #{@board[:E5]} ║ #{@board[:F5]} ║ #{@board[:G5]} ║ #{@board[:H5]} ║ 5
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    6 ║ #{@board[:A6]} ║ #{@board[:B6]} ║ #{@board[:C6]} ║ #{@board[:D6]} ║ #{@board[:E6]} ║ #{@board[:F6]} ║ #{@board[:G6]} ║ #{@board[:H6]} ║ 6
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    7 ║ #{@board[:A7]} ║ #{@board[:B7]} ║ #{@board[:C7]} ║ #{@board[:D7]} ║ #{@board[:E7]} ║ #{@board[:F7]} ║ #{@board[:G7]} ║ #{@board[:H7]} ║ 7
      ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
    8 ║ #{@board[:A8]} ║ #{@board[:B8]} ║ #{@board[:C8]} ║ #{@board[:D8]} ║ #{@board[:E8]} ║ #{@board[:F8]} ║ #{@board[:G8]} ║ #{@board[:H8]} ║ 8
      ╚═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╝
        A   B   C   D   E   F   G   H
      "
    end

    def test(board)
      puts "
      A   B   C   D   E   F   G   H
    ╔═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╗
  1 ║ #{board[:A1]} ║ #{board[:B1]} ║ #{board[:C1]} ║ #{board[:D1]} ║ #{board[:E1]} ║ #{board[:F1]} ║ #{board[:G1]} ║ #{board[:H1]} ║ 1
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  2 ║ #{board[:A2]} ║ #{board[:B2]} ║ #{board[:C2]} ║ #{board[:D2]} ║ #{board[:E2]} ║ #{board[:F2]} ║ #{board[:G2]} ║ #{board[:H2]} ║ 2
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  3 ║ #{board[:A3]} ║ #{board[:B3]} ║ #{board[:C3]} ║ #{board[:D3]} ║ #{board[:E3]} ║ #{board[:F3]} ║ #{board[:G3]} ║ #{board[:H3]} ║ 3
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  4 ║ #{board[:A4]} ║ #{board[:B4]} ║ #{board[:C4]} ║ #{board[:D4]} ║ #{board[:E4]} ║ #{board[:F4]} ║ #{board[:G4]} ║ #{board[:H4]} ║ 4
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  5 ║ #{board[:A5]} ║ #{board[:B5]} ║ #{board[:C5]} ║ #{board[:D5]} ║ #{board[:E5]} ║ #{board[:F5]} ║ #{board[:G5]} ║ #{board[:H5]} ║ 5
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  6 ║ #{board[:A6]} ║ #{board[:B6]} ║ #{board[:C6]} ║ #{board[:D6]} ║ #{board[:E6]} ║ #{board[:F6]} ║ #{board[:G6]} ║ #{board[:H6]} ║ 6
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  7 ║ #{board[:A7]} ║ #{board[:B7]} ║ #{board[:C7]} ║ #{board[:D7]} ║ #{board[:E7]} ║ #{board[:F7]} ║ #{board[:G7]} ║ #{board[:H7]} ║ 7
    ╠═══╬═══╬═══╬═══╬═══╬═══╬═══╬═══╣
  8 ║ #{board[:A8]} ║ #{board[:B8]} ║ #{board[:C8]} ║ #{board[:D8]} ║ #{board[:E8]} ║ #{board[:F8]} ║ #{board[:G8]} ║ #{board[:H8]} ║ 8
    ╚═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╝
      A   B   C   D   E   F   G   H
    "
  end
end

'''
x = Board.new
x.new_board
x.board[:E3] = Knight.new("black")
start = "D8".to_sym
endd = "G7".to_sym

b = Queen.new("lack")
b.movement(":E5")
key = :B1
x.board[key] = b
#x.user_input


x.print_board


#p moves = x.all_available_moves(b,key)


=begin
if x.board[start] != " "
  x.board[start],x.board[endd] = x.board[endd],x.board[start]
end
p x.is_inside?("K9")

x.print_board
=end
puts "
**************

"
#p limit_Queen(moves,key,x)

#p x.checkmate
#p x.same_color?(:D1,:C3)
'''
'''
x = Board.new
x.new_board
x.print_board

#puts x.board[:G2].object_id

o = []
("A".."H").each do |char| 
  sym_b = (char +"2").to_sym
  sym_w = (char +"7").to_sym
  puts "#{sym_b} - #{x.board[sym_b].object_id}"
  o << x.board[sym_b].object_id
  #p "#{x.board[sym_w].object_id}"
end

p o.uniq.length
'''