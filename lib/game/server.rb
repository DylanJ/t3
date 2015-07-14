require 'em-websocket'
require 'lib/game/room'
require 'lib/game/close_handler'
require 'pry'

module TTT
  module Game
    class Server
      attr_reader :clients, :rooms

      def initialize
        @clients = []
        @rooms = []
      end

      def broadcast(command, options)
        @clients.each do |c|
          c.send(command, options)
        end
      end

      def add_room(room)
        return false if room_name_exists?(room.name)
        return false unless room.valid?

        @rooms << room

        broadcast('room_added', room: room.simple_info)

        room
      end

      def remove_room(room)
        @rooms.delete(room)

        broadcast('room_removed', room_id: room.id)
      end

      def update_room(room)
        if room.empty? && !room.in_progress?
          remove_room(room)
        end

        broadcast('room_update', room: room.simple_info)
      end

      def websocket_handler
        EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, debug: true) do |ws|
          ws.onopen do |handshake|
            puts "WebSocket connection open"
          end

          ws.onclose do
            puts "Connection closed"
            CloseHandler.handle(self, ws)
          end

          ws.onmessage do |msg|
            MessageHandler.handle(self, ws, msg)
          end

          ws.onerror do |error|

            binding.pry;1;
          end
        end
      end

      def start
        Thread.new do
          EM.run { websocket_handler }
        end
      end

      def self.start!
        self.new.start
      end

      def client_from_web_socket(web_socket)
        @clients.detect{ |x| x.web_socket == web_socket }
      end

      def room_from_id(room_id)
        @rooms.detect{ |x| x.id == room_id }
      end

      def room_list
        @rooms.map(&:simple_info)
      end

      def room_name_exists?(name)
        @rooms.detect{ |x| x.name == name }
      end
    end
  end
end

