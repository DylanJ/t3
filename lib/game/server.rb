require 'em-websocket'

module TTT
  module Game
    class Server
      def self.handler
        EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, debug: true) do |ws|
          ws.onopen do |handshake|
            puts "WebSocket connection open"
          end

          ws.onclose do
            puts "Connection closed"
          end

          ws.onmessage do |msg|
            MessageHandler.handle(ws, msg)
          end
        end
      end

      def self.start!
        Thread.new do
          EM.run { Server.handler }
        end
      end
    end
  end
end

