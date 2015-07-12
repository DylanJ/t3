require 'securerandom'

module TTT
  module Game
    class Room
      attr_reader :name, :size, :players, :state, :id, :owner

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
        @scores = {}

        reset_board()
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

          broadcast("player_joined", { player: client.info })
          client.room = self
        end

        added_successfully
      end

      def remove_player(client)
        @players.delete(client)
        broadcast("player_disconnected", { player_id: client.id })
      end

      def symbol_for_player(client)
        @symbol_map[client.id]
      end

      def win_or_tie?(client)
        g = @pieces
        s = symbol_for_player(client)

        @grid_size.times do |i|
          # rows
          return :win if g[0][i] == s && g[1][i] == s && g[2][i] == s
          # cols
          return :win if g[i][0] == s && g[i][1] == s && g[i][2] == s
        end

        # diag \
        return :win if @grid_size.times.map{ |i| g[i][i] == s }.all?
        # diag /
        return :win if @grid_size.times.map{ |i| g[(@grid_size-1)-i][i] == s }.all?

        return :tie if @pieces.flatten.all?{ |p| !p.nil? }

        return nil
      end

      def players_turn?(client)
        @current_player == client
      end

      def move(client, piece_id)
        return false unless in_progress?

        return false unless players_turn?(client)

        piece_id = Integer(piece_id) rescue nil

        return false if piece_id.nil?

        too_big = piece_id >= @grid_size**2
        too_small = piece_id < 0

        x = piece_id % @grid_size
        y = piece_id / @grid_size

        taken = !@pieces[y][x].nil?

        return false if too_big || too_small || taken

        @pieces[y][x] = symbol_for_player(@current_player)
        @last_move = piece_id

        true
      end

      def print_board
        @grid_size.times do |y|
          @grid_size.times do |x|
            print @pieces[y][x] || '#'
          end
          print "\n"
        end
      end

      def finish_turn
        last_player = @current_player

        puts "before symbol"
        symbol = symbol_for_player(last_player)
        puts "after symbol"

        @current_player = next_player

        print_board()

        broadcast('game_turn', turn: {
          piece_id: @last_move,
          symbol: symbol,
          player_id: @current_player.id
        })

        if result = win_or_tie?(last_player)

          if result == :win
            @scores[last_player.id] ||= 0
            @scores[last_player.id] += 1

            last_player.win!

            @players.each do |p|
              next if p.id == last_player.id
              p.lose!
            end
          else # tie
            @players.each do |p|
              p.tie!
            end
          end

          broadcast('game_end', result: result, winner: last_player.info, scores: @scores)
          reset_board()
          broadcast_gamestate()
        else
        end
      end

      def reset_board
        @pieces = @grid_size.times.map do
          @grid_size.times.map { nil }
        end
      end

      def empty?
        @players.size == 0
      end

      def start_game
        if in_progress?
          broadcast_gamestate()
        elsif ready? && !in_progress?
          @state = STATE::IN_PROGRESS
          @current_player = @players.sample
          @symbol_map = Hash[@players.map(&:id).zip(['x','o'])] # narly, do something else
          @original_players = @players.map(&:name)
          broadcast_gamestart()
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
          owner: @owner.name,
        }
      end

      def info
        simple_info.merge(players: player_info)
      end

      private

      def broadcast_gamestate
        broadcast("game_state", { game: { pieces: @pieces.flatten, players: player_info } })
      end

      def broadcast_gamestart
        broadcast("game_start", { start_player_id: @current_player.id })
      end

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
        @players.map(&:info)
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
