require 'json'

require 'lib/game/client'
require 'lib/game/handler'
require 'lib/game/message_builder'

module TTT
  module Game
    class MessageHandler < Handler
      include MessageBuilder

      def initialize(server, web_socket, raw_message)
        super

        puts "Recieved message: #{raw_message}"

        data = JSON.parse(raw_message)
        data = symify_hash(data)

        @command = (data.delete(:command) || :invalid_command).to_sym
        @options = data
      end

      def handle_message
        return unless acceptable_command?

        puts "options: #{@options.inspect}"

        case @command
        when :register
          register
        when :room_create
          room_create
        when :room_join
          room_join
        when :move
          move
        else
          puts "don't know how to handle #{@command}"
        end
      end

      private

      def move
        puts "PLAYER MOVED"

        client = @server.client_from_web_socket(@web_socket)

        if client.nil?
          puts "client is nil!"
          return
        end

        room = client.room

        if room.nil?
          puts "room is nil!"
          return
        end

        if room.move(client, @options[:piece_id])
          send_message(:valid_move)
          room.finish_turn
        else
          send_message(:illegal_move)
        end
      end

      def register
        puts "CLIENT REGISTERING"

        client = Client.new(@web_socket, @options[:name])

        send_message(:welcome, { msg: "to ttt v1" })
        send_message(:room_list, rooms: @server.room_list)
        send_message(:user_info, client: client.info)

        @server.clients << client
      end

      def room_create
        client = @server.client_from_web_socket(@web_socket)

        room_name = @options[:name]

        if room = @server.add_room(client, room_name)
          room.add_player(client)
          send_message(:room_joined, room: room.info)
        else
          send_message(:error, {message: 'cannot create room'})
        end
      end

      def room_join
        client = @server.client_from_web_socket(@web_socket)
        room = @server.room_from_id(@options[:room_id])

        if room.nil?
          send_message(:error, {message: 'room does not exist'})
        elsif room.add_player(client)
          send_message(:room_joined, room: room.info)
          room.start_game
        else
          send_message(:error, {message: 'cannot join room'})
        end
      end

      def symify_hash(hash)
        {}.tap do |h|
          hash.each { |k,v| h[k.to_sym] = v }
        end
      end

      def send_message(command, options={})
        @web_socket.send(build_message(command, options))
      end

      def whitelisted_commands
        [:register, :room_create, :room_join, :move]
      end

      def acceptable_command?
        whitelisted_commands.include?(@command)
      end
    end
  end
end
