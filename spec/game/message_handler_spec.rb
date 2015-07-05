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

        describe "room_create message" do
          let(:client) { double "Client" }
          let(:command) { :room_create }
          let(:options) { { name: 'Some Room' } }

          before do
            allow(server).to receive(:client_from_web_socket).and_return(client)
          end
          before { subject }

          context "when room was created" do
            specify do
              expect(handler).to have_received(:send_message).with(:room_info, name: options[:name], password: nil, size: 3, players: [])
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
