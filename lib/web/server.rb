require 'sinatra/base'


module TTT
  module Web
    class Server < Sinatra::Base
      set :public_folder, 'assets'

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

