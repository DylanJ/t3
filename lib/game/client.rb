require 'lib/game/message_builder'
require 'securerandom'

module TTT
  module Game
    class Client
      attr_reader :name, :web_socket, :id
      attr_accessor :room

      include MessageBuilder

      def initialize(web_socket=nil, name=nil)
        @web_socket = web_socket
        @name = name
        @id = SecureRandom.uuid
      end

      def disconnect
        puts "disconnecting #{name}"
        if @room
          @room.remove_player(self)
        end
      end

      def send(command, options)
        @web_socket.send(build_message(command, options))
      end

      def info
        {
          id: @id,
          name: @name,
        }
      end
    end
  end
end
