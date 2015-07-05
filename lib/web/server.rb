require 'sinatra/base'


module TTT
  module Web
    class Server < Sinatra::Base
      set :root, File.dirname(__FILE__)

      def self.start!
        self.run!
      end

      get '/' do
        load 'lib/game/message_handler.rb'
        File.read('views/index.html')
      end
    end
  end
end

