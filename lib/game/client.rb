require 'lib/game/message_builder'
require 'securerandom'

module TTT
  module Game
    class Client
      attr_reader :name, :web_socket, :id
      attr_accessor :room

      include MessageBuilder

      def initialize(web_socket=nil, name=nil, id=nil)
        @web_socket = web_socket
        @name = name
        @id = id || SecureRandom.uuid
      end

      def info
        {
          id: id,
          name: name,
        }
      end

      def send(command, options={})
        if @web_socket.state != :connected
          puts "web socket not connected from #{caller_locations[0]}"
          return
        end

        @web_socket.send(build_message(command, options))
      end

      def join_room(room)
        if room.nil?
          send(:error, {message: 'room does not exist'})
        elsif room.add_client(self)
          # should happen after room_joined, think about some queue to
          # deal with messages that need to happen later.
          # ~L44 room.rb
          room.start_game
        else
          send(:error, {message: 'cannot join room'})
        end
      end

      def leave_room
        @room.remove_client(self) if @room
      end

      def move(piece_id)
        @room.move(self, piece_id) if @room
      end
    end
  end
end
