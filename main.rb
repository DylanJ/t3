require 'rubygems'
require 'bundler/setup'

$: << '.'

require 'pry'
require 'lib/web/server'
require 'lib/game/server'

WS_PORT = 4568

TTT::Game::Server.start!
TTT::Web::Server.start!
