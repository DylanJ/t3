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

        @current_streak = 0
        @highest_streak = 0

        @wins = 0
        @losses = 0
        @ties = 0
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
          record: record,
          streak: @highest_streak
        }
      end

      def win!
        @wins += 1

        inc_streak!
      end

      def lose!
        @losses += 1

        reset_streak!
      end

      def tie!
        @ties += 1
        reset_streak!
      end

      private

      def record
        "#{@wins}/#{@ties}/#{@losses}"
      end

      def inc_streak!
        if @won_last_game
          @current_streak += 1

          if @current_streak > @highest_streak
            @highest_streak = @current_streak
          end

          @won_last_game = true
        end
      end

      def reset_streak!
        @won_last_game = false
        @current_streak = 0
      end
    end
  end
end
