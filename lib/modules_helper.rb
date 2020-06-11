module LongLines
    # Contains delta movement for horizontal, vertical and diagonal translations
    private
    def horizontal_vertical
        x = []
        y = []
        (-7).upto(7) do |i|
            unless i == 0
                x.push(i)
                y.push(0)
            end
        end

        x1 = x.dup
        y1 = y.dup

        x << y1
        y << x1

        delta = {:dx => x.flatten,
                :dy => y.flatten
        }
        return delta
    end

    def diagonal
        x = []; y =[]
        (-7).upto(7) do |i|
            unless i == 0
                x.push(i)
                y.push(i)
            end
        end
        x1 = x.dup.reverse
        y1 = y.dup

        x << 0
        y << 0

        x << y1
        y << x1

        delta = {:dx => x.flatten,
            :dy => y.flatten
        }
    return delta
    end
end

module MovementLimitation
    # It filtrates all the possible movement for Rook, Bishop and Queen
    # Returns only the positions which the piece can go
    # key => initial position of piece, x => board

    def limit_Pawn(moves,key,x)
        arr = []; col = key[0]
        while !moves.empty?
            move = moves.shift
            if move.to_s.include? col
                arr << move if x[move] == " "
            else
                arr << move unless x[move] == " "
            end
        end
        return arr
    end

    def limit_Rook(moves,key,x)
        middle = (moves.length)/2
        limit_Piece(middle,0,moves,key,x)
    end

    def limit_Bishop(moves,key,x)
        key_index = moves.index(key)
        limit_Piece(key_index,1,moves,key,x)
    end

    def limit_Queen(moves,key,x)
        key_index = moves.index(key)
        hori_verti = moves[0...key_index]
        arr1 = limit_Rook(hori_verti,key,x)

        diagonals = moves[key_index+1...moves.length]
        arr2 = limit_Bishop(diagonals,key,x)

        arr = arr1 + arr2
    end

    def limit_Piece(middle,incrementBishop,moves,key,x)
        first_moves = moves[0...middle]
        arr1 = limit_movements(first_moves,key,x)

        second_moves = moves[middle+incrementBishop..moves.length-1]
        arr2 = limit_movements(second_moves,key,x)

        arr = arr1 + arr2
    end

    def limit_movements(moves,key,x)
        moves << key
        moves.sort!
        key_index = moves.index(key)
        before_key = moves[0...key_index]
        after_key = moves[key_index+1..moves.length-1]
    
        arr = []
        while !before_key.empty?
        pop_out = before_key.pop
        arr << pop_out
        break unless x[pop_out] == " "
        end
    
        while !after_key.empty?
        pop_out = after_key.shift
        arr << pop_out
        break unless x[pop_out] == " "
        end
    
        return arr
    end
end


''' Rook
middle = (moves.length)/2
hori_moves = moves[0...middle]
puts "Horizontal: #{hori_moves}"
puts "Results: #{limit_movements(hori_moves,key,x)}"

verti_moves = moves[middle..moves.length-1]
puts "Vertical: #{verti_moves}"
puts "Results: #{limit_movements(verti_moves,key,x)}"
'''

''' Bishop
key_index = moves.index(key)
diago_posi = moves[0...key_index]
diago_negavi = moves[key_index+1..moves.length-1]

puts "diagonal -ve: #{diago_posi}"
puts "Results: #{limit_movements(diago_posi,key,x)}"

puts "diagonal +ve: #{diago_negavi}"
puts "Results: #{limit_movements(diago_negavi,key,x)}"
'''
