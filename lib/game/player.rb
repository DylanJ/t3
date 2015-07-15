module TTT
  module Game
    class Player
      attr_accessor :symbol, :status, :client

      def initialize(client)
        @client = client

        @current_streak = 0
        @highest_streak = 0

        @wins = 0
        @losses = 0
        @ties = 0
      end

      def id
        @client.id
      end

      def name
        @client.name
      end

      def send(*args); @client.send(*args); end

      def info
        {
          record: record,
          streak: @highest_streak,
          status: @status,
          icon: @symbol || '',
        }.merge(@client.info)
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

