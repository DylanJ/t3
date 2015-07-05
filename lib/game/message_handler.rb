require 'json'

module TTT
  module Game
    class MessageHandler
      def initialize(web_socket, raw_message)
        puts "Recieved message: #{raw_message}"

        data = JSON.parse(raw_message)

        @web_socket = web_socket
        @command = (data.delete('command') || :invalid_command).to_sym
        @message = data

        if !whitelisted_commands.include?(!@command)
          puts "receieved unacceptable command: #{@command}"
        end

        handle_message
      end

      def self.handle(web_socket, message)
        self.new(web_socket, message)
      end

      def send_message(command, options)
        cmd = { c: command.to_sym }.merge(options)
        data = JSON.generate(cmd)
        @web_socket.send(data)
      end

      private
      def handle_message
        case @command
        when :register
          puts "CLIENT REGISTERING"
          send_message(:welcome, { msg: "to ttt v2awd" })
          send_message(:room_list, rooms: [])
          send_message(:user_info, username: 'foo')
        else
          puts "don't know how to handle #{@command}"
        end
      end

      def whitelisted_commands
        [:register, :room_create]
      end
    end
  end
end
