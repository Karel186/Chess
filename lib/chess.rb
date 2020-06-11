require_relative 'board'

class ChessGame
    def initialize
        puts "Welcome to the Chess Game"
        puts "Player 1 is color white"
        puts "Player 2 is color black"
        @board = Board.new
        @board.new_board
    end

    def game
        puts "Player 1 start!"
        win = false
        until win
            @board.print_board
            player =  (@board.turn+1).even? ? "Player 2 (Black)" : "Player 1 (White)"
            puts "
            #{player}'s turn'"
            print "Choose a piece to move: "
            @board.user_input
            puts "***************************************************"
            look_for_check = @board.checkmate
            if look_for_check == 1
                win = true
            elsif look_for_check == -1
                puts "Check!"
            end
            break if win
        end
        puts "
        You win !
        "
        puts "Congratulations #{player}
        " if win
    end
end
game = ChessGame.new
game.game