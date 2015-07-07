require 'spec/spec_helper'
require 'lib/game/server'
require 'lib/game/message_handler'

module TTT
  module Game
    describe MessageHandler do
      def generate_raw(command, options)
        options['command'] = command
        JSON.generate(options)
      end

      let(:web_socket) { double "WebSocket" }
      let(:server) { Server.new }
      let(:raw_message) { generate_raw(command, options) }
      let(:handler) { MessageHandler.new(server, web_socket, raw_message) }
      let(:room_name) { "test room" }

      let(:expected_room_info) do
        {
          name: room_name,
          password: false,
          size: "1/2",
          grid: 3,
          id: '123',
          players: [{name: nil, score: 0}]
        }
      end

      before do
        allow_any_instance_of(Room).to receive(:generate_id).and_return("123")
      end

      describe "Messages" do
        subject { handler.handle_message }
        before { allow(handler).to receive(:send_message) }

        describe "register message" do
          let(:command) { :register }
          let(:options) { { name: 'Foo' } }

          before { subject }

          specify do
            expect(handler).to have_received(:send_message).with(:welcome, {msg: 'to ttt v1' })
          end
          specify do
            expect(handler).to have_received(:send_message).with(:room_list, rooms: [])
          end
          specify do
            expect(handler).to have_received(:send_message).with(:user_info, username: 'Foo')
          end

          specify do
            expect(server.clients.count).to eq(1)
          end
        end

        describe "room_join message" do
          let(:client) { Client.new }
          let(:room) { Room.new(client, room_name) }

          let(:command) { :room_join }
          let(:options) { { room_id: room_name } }

          before do
            allow(server).to receive(:client_from_web_socket).and_return(client)
            allow(server).to receive(:room_from_id).and_return(room)
          end

          before { subject }

          context "when room was created" do
            specify do
              expect(handler).to have_received(:send_message).with(:room_joined, room: expected_room_info)
            end
          end
        end

        describe "room_create message" do
          let(:client) { Client.new }

          let(:command) { :room_create }
          let(:options) { { name: room_name } }
          before do
            allow(server).to receive(:client_from_web_socket).and_return(client)
          end
          before { subject }

          context "when room was created" do
            specify do
              expect(handler).to have_received(:send_message).with(:room_joined, room: expected_room_info)
            end

            specify do
              expect(server.rooms.count).to eq(1)
            end
          end

          context "when room was not created" do
            let(:options) { { name: '' } }

            specify do
              expect(handler).to have_received(:send_message).with(:error, message: "cannot create room")
            end

            specify do
              expect(server.rooms.count).to eq(0)
            end
          end
        end
      end
    end
  end
end
