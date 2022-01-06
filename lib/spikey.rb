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
require_relative "spikey/commands/warn"
require_relative "spikey/commands/strike"
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
		@client.message { |event| @cached_messages[event.message.id] = event.message if event.message.server != nil }


		# event handling

		@client.ready { ready }

		@client.server_create { |event| joined_server(event) }
		@client.server_delete { |event|  left_server(event)  }

		@client.member_join  { |event| log_member_joined(event) }
		@client.member_leave { |event|  log_member_left(event)  }

		@client.user_ban   { |event|  log_member_ban(event)  }
		@client.user_unban { |event| log_member_unban(event) }

		@client.message_edit   { |event|  log_message_edit(event)  }
		@client.message_delete { |event| log_message_delete(event) }


		# command handling

		command(:help, max_args: 1) { |event, category| help(event, category) }

		command(:config_logs, max_args: 1) { |event, channel| config_logs(event, channel) }

		command(:warn, min_args: 1)   { |event, user, *reason|  warn(event, user, reason.join(" "))  }
		command(:strike, min_args: 1) { |event, user, *reason| strike(event, user, reason.join(" ")) }
	end

	def run
		@client.run
	end

	def command(name, options={})
		@client.command(name, options) do |event, *args|
			Thread.new { event.channel.start_typing }
			yield event, *args
		end
	end
end