require 'json'

require 'lib/game/room'
require 'lib/game/client'
require 'lib/game/handler'
require 'lib/game/message_builder'

module TTT
  module Game
    class MessageHandler < Handler
      include MessageBuilder

      def initialize(server, web_socket, raw_message)
        super

        data = JSON.parse(raw_message) rescue {}
        data = symify_hash(data)

        @command = (data.delete(:command) || :invalid_command).to_sym
        @options = data
        @client = server.client_from_web_socket(web_socket)
      end

      def handle_message
        return unless acceptable_command?

        puts "options: #{@options.inspect}"

        if @command == :register
          register
        end

        return if @client.nil?

        case @command
        when :room_create
          create
        when :room_join
          join
        when :move
          move
        when :leave
          leave
        else
          puts "don't know how to handle #{@command}"
        end
      end

      private

      def register
        client = Client.new(@web_socket, @options[:name], @options[:id])

        client.send(:welcome, { msg: "to ttt v1" })
        client.send(:room_list, rooms: @server.room_list)
        client.send(:user_info, client: client.info)

        @server.clients << client
      end

      def leave
        if room = @client.room
          room.client_left(@client)
          @server.update_room(room)
          @client.send(:room_list, rooms: @server.room_list)
        end
      end

      def move
        @client.move(@options[:piece_id])
      end

      def create
        room = Room.new(@client, @options[:name])

        if room = @server.add_room(room)
          @client.join_room(room)
          @server.update_room(room)
        else
          @client.send(:error, {message: 'cannot create room'})
        end
      end

      def join
        room = @server.room_from_id(@options[:room_id])

        @client.join_room(room)
        @server.update_room(room)
      end

      def symify_hash(hash)
        {}.tap do |h|
          hash.each { |k,v| h[k.to_sym] = v }
        end
      end

      def whitelisted_commands
        [:register, :room_create, :room_join, :move, :leave]
      end

      def acceptable_command?
        whitelisted_commands.include?(@command)
      end
    end
  end
end
