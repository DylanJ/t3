require 'spec/spec_helper'
require 'lib/game/message_handler'

module TTT
  module Game
    describe MessageHandler do
      def generate_raw(command, options)
        options['command'] = command
        JSON.generate(options)
      end

      let(:web_socket) { double "WebSocket" }
      let(:raw_message) { generate_raw(command, options) }
      let(:handler) { MessageHandler.new(web_socket, raw_message) }

      subject { handler.handle_message }
      before { allow(handler).to receive(:send_message) }
      before { subject }

      describe "Messages" do
        describe "register message" do
          let(:command) { :register }
          let(:options) { { name: 'Foo' } }

          specify do
            expect(handler).to have_received(:send_message).with(:welcome, {msg: 'to ttt v1' })
          end
          specify do
            expect(handler).to have_received(:send_message).with(:room_list, rooms: [])
          end
          specify do
            expect(handler).to have_received(:send_message).with(:user_info, username: 'Foo')
          end
        end
      end
    end
  end
end
