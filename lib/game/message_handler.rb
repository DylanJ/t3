require 'json'

module TTT
  module Game
    class MessageHandler
      def initialize(web_socket, raw_message)
        puts "Recieved message: #{raw_message}"

        data = JSON.parse(raw_message)
        data = symify_hash(data)

        @web_socket = web_socket
        @command = (data.delete(:command) || :invalid_command).to_sym
        @options = data

        if !whitelisted_commands.include?(!@command)
          puts "receieved unacceptable command: #{@command}"
        end
      end

      def self.handle(web_socket, message)
        handler = self.new(web_socket, message)
        handler.handle_message
      end

      def handle_message
        puts "options: #{@options.inspect}"

        case @command
        when :register
          puts "CLIENT REGISTERING"
          send_message(:welcome, { msg: "to ttt v1" })
          send_message(:room_list, rooms: [])
          send_message(:user_info, username: @options[:name])
        else
          puts "don't know how to handle #{@command}"
        end
      end

      private

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
