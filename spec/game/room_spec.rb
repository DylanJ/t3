require 'spec/spec_helper'

require 'lib/game/room'

module TTT
  module Game
    describe Room do
      let(:room) { Room.new(owner, name) }
      let(:owner) { double "Client" }
      let(:name) { "Some Room" }

      specify { expect(room.state).to eq(Room::STATE::WAITING) }
      specify { expect(room.players).to be_empty }

      describe "valid?" do
        context "defaults are valid" do
          specify { expect(room).to be_valid }
        end

        context "empty room name" do
          let(:name) { "" }

          specify { expect(room).to_not be_valid }
        end

        context "nil owner" do
          let(:owner) { nil }

          specify { expect(room).to_not be_valid }
        end
      end
    end
  end
end
