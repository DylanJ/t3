module TTT
  module Game
    class Handler
      def initialize(server, web_socket, message)
        @web_socket = web_socket
        @server = server
      end

      def self.handle(server, web_socket, message="")
        handler = self.new(server, web_socket, message)
        handler.handle_message
      end

      def handle_message
        raise "ImplementMe"
      end
    end
  end
end
