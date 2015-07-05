require 'spec/spec_helper'
require 'lib/game/server'

module TTT
  module Game
    describe Server do
      let(:server) { Server.new }

      describe "Freshly instantiated server" do
        specify { expect(server.clients).to be_empty }
        specify { expect(server.rooms).to be_empty }
      end
    end
  end
end
