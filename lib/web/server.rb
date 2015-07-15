require 'sinatra/base'

module TTT
  module Web
    class Server < Sinatra::Base
      set :public_folder, 'assets'
      set :bind, '0.0.0.0'

      def self.start!
        self.run!
      end

      get '/' do
        load 'lib/game/message_handler.rb'
        @address = "#{settings.bind}:#{WS_PORT}"
        template = File.read('views/index.html')
        ERB.new(template).result(binding)
      end
    end
  end
end

