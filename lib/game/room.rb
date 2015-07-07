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

        @pieces = (size*size).times.map do
          nil
        end
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
          broadcast("player_joined", { player: client.info })

          @players << client
          client.room = self
        end

        added_successfully
      end

      def remove_player(client)
        @players.delete(client)
        broadcast("player_left", { player: client.info })
      end

      def symbol_for_player(client)
        @symbol_map[client]
      end

      def move(client, piece_id)
        return false unless in_progress?

        piece_id = Integer(piece_id) rescue nil

        return false if piece_id.nil?

        too_big = piece_id >= @grid_size**2
        too_small = piece_id < 0
        taken = !@pieces[piece_id].nil?

        return false if too_big || too_small || taken

        @pieces[piece_id] = symbol_for_player(client)
        @last_move = piece_id

        true
      end

      def finish_turn
        last_move = @last_move

        @current_player = next_player

        broadcast('turn', turn: { piece_id: @last_move, symbol: @pieces[@last_move], player_id: @current_player.id })
      end

      def empty?
        @players.size == 0
      end

      def start_game
        if ready? && !in_progress?
          @state = STATE::IN_PROGRESS
          @current_player = @players.sample
          @symbol_map = Hash[@players.zip(['x','o'])] # narly, do something else
          broadcast("game_start", { starter: @current_player.info })
        end
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

      def broadcast(command, options)
        @players.each do |player|
          player.send(command, options)
        end
      end

      def waiting?
        @state == STATE::WAITING
      end

      def in_progress?
        @state == STATE::IN_PROGRESS
      end

      def ready?
        @players.size == 2
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

      def next_player
        @players.detect{ |x| x != @current_player }
      end
    end
  end
end
