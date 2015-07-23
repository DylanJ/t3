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
      let(:client) { Client.new }
      let(:raw_message) { generate_raw(command, options || {}) }
      let(:handler) { MessageHandler.new(server, web_socket, raw_message) }
      let(:room_name) { "test room" }

      before do
        allow(server).to receive(:client_from_web_socket).and_return(client)
        allow_any_instance_of(Room).to receive(:generate_id).and_return("123")
        allow(Client).to receive(:new).and_return(client)
        allow(client).to receive(:send)
      end

      describe "Messages" do
        subject { handler.handle_message }

        describe "register message" do
          let(:command) { :register }
          let(:options) { { name: 'Foo' } }

          before { subject }

          specify do
            expect(client).to have_received(:send).with(:welcome, {msg: TTT_VERSION })
            expect(client).to have_received(:send).with(:room_list, rooms: [])
            expect(client).to have_received(:send).with(:user_info, client: client.info)
          end

          specify do
            expect(server.clients.count).to eq(1)
          end
        end

        describe "room_join message" do
          let(:room) { Room.new(client, room_name) }
          let(:command) { :room_join }
          let(:options) { { room_id: room_id } }

          context "when room exists" do
            let(:room_id) { room.id }

            before do
              server.add_room(room)
              subject
            end

            specify do
              expect(client).to have_received(:send).with(:room_joined, any_args)
            end
          end

          context "when room does not exist" do
            let(:room_id) { 'doesnt_exist' }

            before { subject }

            specify do
              expect(client).to have_received(:send).with(:error, message: "room does not exist")
            end
          end
        end

        describe "room_create message" do
          let(:command) { :room_create }
          let(:options) { { name: room_name } }

          before { subject }

          context "when room was created" do
            specify do
              expect(client).to have_received(:send).with(:room_joined, any_args)
            end

            specify do
              expect(server.rooms.count).to eq(1)
            end
          end

          context "when room was not created" do
            let(:options) { { name: '' } } # bad name

            specify do
              expect(client).to have_received(:send).with(:error, message: "cannot create room")
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
