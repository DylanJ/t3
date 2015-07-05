require 'em-websocket'

module TTT
  module Game
    class Server
      attr_reader :clients, :rooms

      def initialize
        @clients = []
        @rooms = []
      end

      def websocket_handler
        EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, debug: true) do |ws|
          ws.onopen do |handshake|
            puts "WebSocket connection open"
          end

          ws.onclose do
            puts "Connection closed"
          end

          ws.onmessage do |msg|
            MessageHandler.handle(self, ws, msg)
          end
        end
      end

      def start
        Thread.new do
          EM.run { websocket_handler }
        end
      end

      def self.start!
        self.new.start
      end
    end
  end
end

