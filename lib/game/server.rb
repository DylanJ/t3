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

      def add_room(owner, name)
        room = Room.new(owner, name)

        return false if room_name_exists?(name)
        return false unless room.valid?

        @rooms << room

        @clients.each do |c|
          next if c == owner

          c.send('room_added', room: room.simple_info)
        end

        room
      end

      def remove_room(room)
        @rooms.delete(room)
        puts "Deleting Room"
        @clients.each do |c|
          next if c == room.owner

          c.send('room_removed', room_id: room.id)
        end
      end

      def update_room(room)
        @clients.each do |c|
          c.send('room_update', room: room.simple_info)
        end
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

            binding.pry; 1+1

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

