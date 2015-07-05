require 'json'

require 'lib/game/client'

module TTT
  module Game
    class MessageHandler
      def initialize(server, web_socket, raw_message)
        puts "Recieved message: #{raw_message}"

        data = JSON.parse(raw_message)
        data = symify_hash(data)

        @web_socket = web_socket
        @command = (data.delete(:command) || :invalid_command).to_sym
        @options = data
        @server = server

        if !whitelisted_commands.include?(!@command)
          puts "receieved unacceptable command: #{@command}"
        end
      end

      def self.handle(server, web_socket, message)
        handler = self.new(server, web_socket, message)
        handler.handle_message
      end

      def handle_message
        puts "options: #{@options.inspect}"

        case @command
        when :register
          register
        else
          puts "don't know how to handle #{@command}"
        end
      end

      private

      def register
        puts "CLIENT REGISTERING"
        send_message(:welcome, { msg: "to ttt v1" })
        send_message(:room_list, rooms: @server.rooms)
        send_message(:user_info, username: @options[:name])

        @server.clients << Client.new(@websocket, @options[:name])
      end

      def symify_hash(hash)
        {}.tap do |h|
          hash.each { |k,v| h[k.to_sym] = v }
        end
      end

      def send_message(command, options)
        cmd = { c: command.to_sym }.merge(options)
        data = JSON.generate(cmd)
        @web_socket.send(data)
      end

      def whitelisted_commands
        [:register, :room_create]
      end
    end
  end
end
