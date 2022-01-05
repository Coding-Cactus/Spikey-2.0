require_relative "spikey/events/ready"
require_relative "spikey/events/left_server"
require_relative "spikey/events/joined_server"

require_relative "spikey/logs/member_left"
require_relative "spikey/logs/member_joined"
require_relative "spikey/logs/member_banned"
require_relative "spikey/logs/member_unbanned"
require_relative "spikey/logs/message_edit"
require_relative "spikey/logs/message_delete"

require_relative "spikey/commands/help"
require_relative "spikey/commands/config_logs"

require_relative "spikey/helpers/doc_template"


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

		
		# cache messages for logs
		
		@cached_messages = {}
		@client.message { |event| @cached_messages[event.message.id] = event.message }
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

	def member_join
		@client.member_join { |event| yield event }
	end

	def member_leave
		@client.member_leave { |event| yield event }
	end

	def member_banned
		@client.user_ban { |event| yield event }
	end

	def member_unbanned
		@client.user_unban { |event| yield event }
	end

	def message_edit
		@client.message_edit { |event| yield event }
	end

	def message_delete
		@client.message_delete { |event| yield event }
	end


	def watching=(activity)
		@client.watching = activity
	end


	def command(name, options={})
		@client.command(name, options) do |event, arguments|
			event.channel.start_typing
			yield event, arguments
		end
	end
end