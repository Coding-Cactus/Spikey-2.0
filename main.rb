require "mongo"
require "discordrb"

require_relative "lib/spikey"

spikey = Spikey.new(ENV["token"], ENV["mongouri"])



spikey.on_ready { spikey.ready }

spikey.server_create { |event| spikey.joined_server(event) }
spikey.server_delete { |event|  spikey.left_server(event)  }

spikey.command(:help, max_args: 1) { |event, category| spikey.help(event, category) }	


spikey.run
