require 'rubygems'
require 'bundler/setup'

$: << '.'

require 'lib/web/server'
require 'lib/game/server'

TTT::Game::Server.start!
TTT::Web::Server.start!
