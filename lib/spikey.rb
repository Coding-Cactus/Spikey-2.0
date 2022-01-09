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

require_relative "spikey/commands/configuration/config_mute"
require_relative "spikey/commands/configuration/config_logs"
require_relative "spikey/commands/configuration/config_mod_logs"
require_relative "spikey/commands/configuration/config_auto_ban"
require_relative "spikey/commands/configuration/config_auto_strike"

require_relative "spikey/commands/infractions/warn"
require_relative "spikey/commands/infractions/strike"
require_relative "spikey/commands/infractions/infractions"

require_relative "spikey/commands/repealing/repeal_warn"
require_relative "spikey/commands/repealing/repeal_strike"

require_relative "spikey/commands/muting/mute"

require_relative "spikey/helpers/check_mutes"
require_relative "spikey/helpers/parse_time"
require_relative "spikey/helpers/display_time"
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

		command(:ping) { |_| "pong" }

		command(:help, max_args: 1) { |event, category| help(event, category) }

		command(:config_mute, max_args: 1) { |event, role| config_mute(event, role) }
		
		command(:config_logs, max_args: 1) { |event, channel| config_logs(event, channel) }
		command(:config_mod_logs, max_args: 1) { |event, channel| config_mod_logs(event, channel) }
		
		command(:config_auto_ban, max_args: 1) { |event, count| config_auto_ban(event, count) }
		command(:config_auto_strike, max_args: 1) { |event, count| config_auto_strike(event, count) }

		command(:warn, min_args: 1)   { |event, user, *reason|  warn(event, user, reason.join(" "))  }
		command(:strike, min_args: 1) { |event, user, *reason| strike(event, user, reason.join(" ")) }
		command(:infractions, max_args: 1) { |event, user| infractions(event, user) }
		
		command(:repeal_warn, min_args: 2, max_args: 2)   { |event, user, warnID| repeal_warn(event, user, warnID) }
		command(:repeal_strike, min_args: 2, max_args: 2) { |event, user, strikeID| repeal_strike(event, user, strikeID) }
		
		command(:mute, min_args: 1, max_args: 2) { |event, user, duration| mute(event, user, duration) }
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