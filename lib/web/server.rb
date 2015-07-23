require 'sinatra/base'

module TTT
  module Web
    class Server < Sinatra::Base
      set :public_folder, 'assets'
      set :bind, '0.0.0.0'

      def self.start!(options)
        @@options = options

        self.run!({port: options[:web_port]})
      end

      get '/' do
        load 'lib/game/message_handler.rb'
        @address = "#{@@options[:host]}:#{@@options[:ws_port]}"
        template = File.read('views/index.html')
        ERB.new(template).result(binding)
      end
    end
  end
end

