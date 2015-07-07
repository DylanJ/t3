require 'securerandom'

module TTT
  module Game
    class Room
      attr_reader :name, :size, :players, :state, :id

      module STATE
        WAITING = 0
        IN_PROGRESS = 1
      end

      def initialize(owner, name="", password=nil, size=3)
        @owner = owner
        @name = name
        @password = password
        @grid_size = size
        @state = STATE::WAITING
        @players = []
        @original_players = []
        @id = generate_id()

        puts "Creating Room"
      end

      def add_player(client)
        added_successfully = joinable?

        if in_progress? && joinable?
          # verify only same username can rejoin a game.
          added_successfully = @original_players.detect do |player_name|
            player_name == client.name
          end
        end

        if added_successfully
          @players << client
          client.room = self
          puts "added player (#{@players.count}/2)"
        end

        start_game

        added_successfully
      end

      def remove_player(client)
        @players.delete(client)
        puts "removed player (#{@players.count}/2)"
      end

      def empty?
        @players.size == 0
      end

      def start_game
        puts "willd start game here if ready"
      end

      def valid?
        return false if @owner.nil?
        return false if @name.empty?
        return false if @grid_size != 3 # for now :)

        true
      end

      def id= id
        @id ||= id
      end

      def simple_info
        {
          name: @name,
          password: has_password?,
          size: "#{@players.count}/2",
          grid: @grid_size,
          id: @id,
        }
      end

      def info
        simple_info.merge(players: player_info)
      end

      private

      def waiting?
        @state == STATE::WAITING
      end

      def in_progress?
        @state == STATE::IN_PROGRESS
      end

      def joinable?
        @players.size < 2
      end

      def has_password?
        (@password || "").size > 0
      end

      def player_info
        @players.map do |p|
          {
            name: p.name,
            score: 0,
          }
        end
      end

      def generate_id
        SecureRandom.uuid # something unique
      end
    end
  end
end
