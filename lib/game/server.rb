require 'em-websocket'

module TTT
  module Game
    class Server
      def self.handler
        EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
          ws.onopen do |handshake|
            puts "WebSocket connection open"
            ws.send "Hello Client, you connected to #{handshake.path}"
          end

          ws.onclose do
            puts "Connection closed"
          end

          ws.onmessage do |msg|
            puts "Recieved message: #{msg}"
            ws.send "Pong: #{msg}"
          end
        end
      end

      def self.start!
        puts "starting game server"
        Thread.new do
          EM.run { Server.handler }
        end
      end
    end
  end
end


