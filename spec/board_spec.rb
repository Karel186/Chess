require "./lib/board"
require "./lib/pieces"

describe Board do
    let(:board) {Board.new}

    context "#free_available_moves" do
        context "King movement" do
            let(:king){King.new("white")}
            it "Middle on board, returns 8 positions" do
                pos = board.free_available_moves(king,"E6")
                expect(pos).to match_array([:E5,:F5,:F6,:F7,:E7,:D7,:D6,:D5])
            end

            it "Top right corner, returns 3 positions" do
                pos = board.free_available_moves(king,"H1")
                expect(pos).to match_array([:G1,:G2,:H2])
            end
        end

        context "Knight movement" do
            let(:knight){Knight.new("white")}
            it "Middle on board, returns 8 positions" do
                pos = board.free_available_moves(knight,"E6")
                expect(pos).to match_array([:F4,:D4,:G5,:C5,:G7,:C7,:F8,:D8])
            end

            it "Top right corner, returns 2 positions" do
                pos = board.free_available_moves(knight,"H1")
                expect(pos).to match_array([:F2,:G3])
            end
        end

        context "Queen movement" do
            let(:queen){Queen.new("black")}
            it "Middle on board, returns all positions" do
                pos = board.free_available_moves(queen,"E4")
                expect(pos).to match_array([:E1,:E2,:E3,:E5,:E6,:E7,:E8,:A4,:B4,:C4,:D4,:F4,:G4,:H4,:H1,:G2,:F3,:D5,:C6,:B7,:A8,:B1,:C2,:D3,:F5,:G6,:H7])
            end

            it "Top right corner, returns 3 lines" do
                pos = board.free_available_moves(queen,"H1")
                expect(pos).to match_array([:A1,:B1,:C1,:D1,:E1,:F1,:G1,:H2,:H3,:H4,:H5,:H6,:H7,:H8,:G2,:F3,:E4,:D5,:C6,:B7,:A8])
            end
        end

        context "Pawn movement" do
            let(:pawn){Pawn.new("black")}
            it "Start position, returns 2 postions" do
                pos = board.free_available_moves(pawn,"E2")
                expect(pos).to match_array([:E3,:E4])
            end

            it "Not start position, returns 1 position" do
                pawn.movement("E3") # Simulates first move
                pos = board.free_available_moves(pawn,"E3")
                expect(pos).to match_array([:E4])
            end
        end
    end
end

