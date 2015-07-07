require 'json'

require 'lib/game/client'
require 'lib/game/handler'

module TTT
  module Game
    class MessageHandler < Handler
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
        else
          puts "don't know how to handle #{@command}"
        end
      end

      private

      def register
        puts "CLIENT REGISTERING"
        send_message(:welcome, { msg: "to ttt v1" })
        send_message(:room_list, rooms: @server.room_list)
        send_message(:user_info, username: @options[:name])

        @server.clients << Client.new(@web_socket, @options[:name])
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
        else
          send_message(:error, {message: 'cannot join room'})
        end
      end

      def symify_hash(hash)
        {}.tap do |h|
          hash.each { |k,v| h[k.to_sym] = v }
        end
      end

      def send_message(command, options)
        cmd = { command: command.to_sym }.merge(options)
        data = JSON.generate(cmd)
        @web_socket.send(data)
      end

      def whitelisted_commands
        [:register, :room_create, :room_join]
      end

      def acceptable_command?
        whitelisted_commands.include?(@command)
      end
    end
  end
end
