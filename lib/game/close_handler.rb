require 'lib/game/handler'

module TTT
  module Game
    class CloseHandler < Handler
      def handle_message
        client = @server.client_from_web_socket(@web_socket)

        return if client.nil?

        if room = client.room
          room.client_disconnected(client)
          @server.update_room(room)
        end

        @server.clients.delete(client)
      end
    end
  end
end
