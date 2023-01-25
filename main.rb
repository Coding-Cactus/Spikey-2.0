require "mongo"
require "discordrb"

require_relative "lib/spikey"

Spikey.new(ENV["token"], ENV["mongouri"]).run
