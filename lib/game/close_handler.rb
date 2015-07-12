require 'lib/game/handler'

module TTT
  module Game
    class CloseHandler < Handler
      def handle_message
        client = @server.client_from_web_socket(@web_socket)

        return if client.nil?

        room = client.room

        client.disconnect()

        if room
          @server.update_room(room)

          if room.empty?
            @server.remove_room(room)
          end
        end
      end
    end
  end
end
