require_relative "spikey/help"

class Spikey
	PREFIX = "+"
	
	def initialize(token)
		@client = Discordrb::Commands::CommandBot.new(
			token: ENV["token"],
			prefix: PREFIX,
			ignore_bots: true,
			help_command: false,
			spaces_allowed: true,
			command_doesnt_exist_message: "Could not find command **`%command%`**"
		)
	end

	def run
		@client.run
	end

	def ready
		@client.ready { yield }
	end

	def watching=(activity)
		@client.watching = activity
	end

	def command(name, options={})
		@client.command(name, options) { |event, arguments| yield event, arguments }
	end
end