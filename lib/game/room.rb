require 'securerandom'
require 'lib/game/player'

module TTT
  module Game
    class Room
      attr_reader :name, :size, :players, :state, :id, :owner

      module STATE
        WAITING = 0
        IN_PROGRESS = 1
        FINISHED = 2
      end

      def initialize(owner, name="", password=nil, size=3)
        @owner = owner
        @name = name
        @password = password
        @grid_size = size
        @state = STATE::WAITING
        @players = {}
        @original_players = []
        @id = generate_id()
        @scores = {}

        reset_board()
      end

      def add_client(client)
        return false unless joinable?

        # only players who started the game can rejoin
        return false if in_progress? && @players[client.id].nil?

        client.room = self

        player = @players[client.id] || Player.new(client)
        player.status = "Connected"
        player.client = client # updates websock

        @players[client.id] = player

        client.send(:room_joined, room: info)
        client.send(:game_state, gamestate_message)

        broadcast("player_joined", { player: player.info })
      end

      def client_disconnected(client)
        if player = @players[client.id]
          player.status = 'Disconnected'
          broadcast("player_disconnected", { player_id: player.id })
        end
      end

      def client_left(client)
        player = @players[client.id]

        return if player.nil?
        return end_game() if in_progress?

        broadcast("player_left", { player_id: player.id })

        @players.delete(client.id)
      end

      def end_game()
        @state = STATE::FINISHED

        broadcast("game_over", { scores: @scores, players: player_info })
      end

      def win_or_tie?(player)
        g = @pieces
        s = player.symbol

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

      def players_turn?(player)
        @current_player.id == player.id
      end

      def move(client, piece_id)
        x, y = get_x_y(piece_id)

        if valid_move?(client, x, y)
          @pieces[y][x] = @players[client.id].symbol
          @last_move = piece_id

          client.send(:valid_move)

          finish_turn
        else
          client.send(:illegal_move)
        end
      end

      def get_x_y(piece_id)
        piece_id = Integer(piece_id) rescue nil

        return nil if piece_id.nil?

        too_big = piece_id >= @grid_size**2
        too_small = piece_id < 0

        return nil if too_big || too_small

        x = piece_id % @grid_size
        y = piece_id / @grid_size

        [x, y]
      end

      def valid_move?(player, x, y)
        return false if x.nil? || y.nil?
        return false unless in_progress?
        return false unless players_turn?(player)
        return false unless @pieces[y][x].nil?

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

        @current_player = next_player

        print_board()

        broadcast('game_turn', turn: {
          piece_id: @last_move,
          symbol: last_player.symbol,
          player_id: @current_player.id
        })

        if result = win_or_tie?(last_player)
          if result == :win
            @scores[last_player.id] ||= 0
            @scores[last_player.id] += 1

            last_player.win!

            @players.each do |id, player|
              next if id == last_player.id
              player.lose!
            end
          else # tie
            @players.values.each do |player|
              player.tie!
            end
          end

          broadcast('game_end', result: result, winner_id: last_player.id, scores: room_scores)
          reset_board()
          broadcast_gamestate()
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
          @current_player = @players.values.sample
          @original_players = @players.keys

          @players.values.shuffle.zip(['x', 'o']) do |player, symbol|
            player.symbol = symbol
          end

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
          size: "#{connected_player_count}/2",
          grid: @grid_size,
          id: @id,
          owner: @owner.name,
        }
      end

      def info
        simple_info.merge(players: player_info)
      end

      def broadcast_gamestate
        broadcast("game_state", gamestate_message)
      end

      def gamestate_message
        { game: { pieces: @pieces.flatten, players: player_info, scores: @scores } }
      end

      def broadcast_gamestart
        broadcast("game_start", { start_player_id: @current_player.id, players: player_info })
      end

      def broadcast(command, options)
        @players.values.each do |player|
          player.send(command, options)
        end
      end

      def waiting?
        @state == STATE::WAITING
      end

      def in_progress?
        @state == STATE::IN_PROGRESS
      end

      def game_over?
        @state == STATE::FINISHED
      end

      def ready?
        @players.size == 2
      end

      def joinable?
        connected_player_count < 2
      end

      def connected_player_count
        statuses = @players.values.map(&:status)
        statuses.select{ |s| s == 'Connected' }.size
      end

      def has_password?
        (@password || "").size > 0
      end

      def player_info
        @players.values.map(&:info)
      end

      def generate_id
        SecureRandom.uuid # something unique
      end

      def next_player
        player_id = @players.keys.detect{ |id| id != @current_player.id }

        @players[player_id]
      end

      def room_scores
        @scores.map do |id, score|
          {
            name: @players[id].name,
            score: score
          }
        end
      end
    end
  end
end
