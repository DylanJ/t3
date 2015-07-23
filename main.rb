require 'rubygems'
require 'bundler/setup'

$: << '.'

require 'pry'
require 'lib/web/server'
require 'lib/game/server'

require 'optparse'

# default options
options = {
  web_port: 4567,
  ws_port: 4568,
  host: 'localhost',
  bind: '0.0.0.0'
}

OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-b HOST", "--bind=HOST", "Address to bind to") do |host|
    options[:bind] = host
  end

  opts.on("-p PORT", "--port=PORT", "Webserver port") do |port|
    options[:web_port] = port.to_i
  end

  opts.on("-wsp PORT", "--websocket-port=PORT", "Web socket port") do |port|
    options[:ws_port] = port.to_i
  end

  opts.on("-host HOST", "--host=HOST", "Host clients will connect to") do |host|
    options[:host] = host
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

TTT::Game::Server.start!(options)
TTT::Web::Server.start!(options)
