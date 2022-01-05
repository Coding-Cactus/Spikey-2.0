require "discordrb"

require_relative "lib/spikey"

spikey = Spikey.new(ENV["token"])



spikey.ready { spikey.watching = "you." }


spikey.command(:help, max_args: 1) { |event, category| spikey.help(event, category) }	


spikey.run
