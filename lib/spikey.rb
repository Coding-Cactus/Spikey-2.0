require_relative "spikey/help"
require_relative "spikey/ready"
require_relative "spikey/left_server"
require_relative "spikey/doc_template"
require_relative "spikey/joined_server"

class Spikey
	PREFIX = "+"
	
	def initialize(bot_token, mongo_uri)
		@client = Discordrb::Commands::CommandBot.new(
			token: bot_token,
			prefix: PREFIX,
			ignore_bots: true,
			help_command: false,
			spaces_allowed: true,
			command_doesnt_exist_message: "Could not find command **`%command%`**"
		)

		@servers = Mongo::Client.new(mongo_uri, database: "spikey")[:servers]
	end

	def run
		@client.run
	end

	def on_ready
		@client.ready { yield }
	end

	def server_create
		@client.server_create { |event| yield event }
	end

	def server_delete
		@client.server_delete { |event| yield event }
	end

	def watching=(activity)
		@client.watching = activity
	end

	def command(name, options={})
		@client.command(name, options) { |event, arguments| yield event, arguments }
	end
end