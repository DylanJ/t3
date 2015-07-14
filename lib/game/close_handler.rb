require 'lib/game/handler'

module TTT
  module Game
    class CloseHandler < Handler
      def handle_message
        client = @server.client_from_web_socket(@web_socket)

        return if client.nil?

        if room = client.room
          room.disconnect_client(client)
          @server.update_room(room)
        end
      end
    end
  end
end
