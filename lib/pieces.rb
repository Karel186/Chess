require_relative "modules_helper"

class Piece
    attr_reader :color, :symbol
    def initialize(color,symbol)
        @color = color.downcase
        @symbol = symbol
    end

    # Return array of all positions a particular piece can make (Polymorphism)
    def movement(initial_position,dx,dy)
        initial_x = initial_position[0].ord
        initial_y = initial_position[1].to_i
        
        array_positions = []
        for i in 0..dx.length-1
            x = initial_x + dx[i]
            y = initial_y + dy[i]
            position = x.chr + y.to_s
            array_positions.push(position.to_sym)
        end
        return array_positions
    end

    def self.num
        @@num
    end

    def to_s
        @symbol
    end
end


class King < Piece
    def initialize(color)
        sym = color.downcase == "black" ? "\u265B" : "\u2654"
        super(color,sym)
    end

    def movement(inital_position)
        dx = [0,1,1,1,0,-1,-1,-1]
        dy = [1,1,0,-1,-1,-1,0,1]
        return super(inital_position,dx,dy)
    end
end

class Pawn < Piece
    def initialize(color)
        sym = color.downcase == "black" ? "\u265F" : "\u2659"
        @first_time = true
        super(color,sym)
    end

    def movement(inital_position)
        if @first_time || (color == "black" and [:A2,:B2,:C2,:D2,:E2,:F2,:G2,:H2].include?(inital_position)) || 
            (color == "black" and [:A7,:B7,:C7,:D7,:E7,:F7,:G7,:H7].include?(inital_position))
            dx = [-1,0,0,1]; dy = [1,1,2,1]
            @first_time = false
        else
            dx = [-1,0,1]; dy = [1,1,1]
        end
        dy.map!{|x| x*-1} if color.downcase != "black"
        return super(inital_position,dx,dy)
    end
end

class Knight < Piece
    def initialize(color)
        sym = color.downcase == "black" ? "\u265E" : "\u2658"
        super(color,sym)
    end

    def movement(initial_position)
        dx = [2, 2, -2, -2, 1, 1, -1, -1] 
        dy = [1, -1, 1, -1, 2, -2, 2, -2]
        return super(initial_position,dx,dy)
    end
end

class Queen < Piece
    include LongLines
    def initialize(color)
        sym = color.downcase == "black" ? "\u265B" : "\u2655"
        super(color,sym)
    end

    def movement(initial_position)
        delta_hori_verti = horizontal_vertical
        delta_hori_verti[:dx] << 0 ; delta_hori_verti[:dy] << 0 
        delta_diagonal = diagonal
        delta= delta_hori_verti.merge(delta_diagonal){|key,val1,val2|[val1,val2].flatten}
        return super(initial_position,delta[:dx],delta[:dy])
    end
end

class Rook < Piece
    include LongLines
    def initialize(color)
        sym = color.downcase == "black" ? "\u265C" : "\u2656"
        super(color,sym)
    end

    def movement(initial_position)
        delta = horizontal_vertical
        return super(initial_position,delta[:dx],delta[:dy])
    end
end

class Bishop < Piece
    include LongLines
    def initialize(color)
        sym = color.downcase == "black" ? "\u265D" : "\u2657"
        super(color,sym)
    end

    def movement(initial_position)
        delta = diagonal
        return super(initial_position,delta[:dx],delta[:dy])
    end
end

#p LongLines::horizontal_vertical[:dx]
#p LongLines::horizontal_vertical[:dy]

#p LongLines::diagonal[0]
#p LongLines::diagonal[1]
