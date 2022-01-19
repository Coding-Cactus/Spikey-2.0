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
require_relative "spikey/commands/configuration/config_warn_mute"
require_relative "spikey/commands/configuration/config_strike_mute"

require_relative "spikey/commands/infractions/warn"
require_relative "spikey/commands/infractions/strike"
require_relative "spikey/commands/infractions/infractions"

require_relative "spikey/commands/repealing/repeal_warn"
require_relative "spikey/commands/repealing/repeal_strike"

require_relative "spikey/commands/muting/mute"
require_relative "spikey/commands/muting/unmute"

require_relative "spikey/helpers/get_role"
require_relative "spikey/helpers/get_member"
require_relative "spikey/helpers/get_channel"
require_relative "spikey/helpers/check_mutes"
require_relative "spikey/helpers/parse_time"
require_relative "spikey/helpers/display_time"
require_relative "spikey/helpers/doc_template"


class Spikey
	PREFIX = "+"
	PERMISSIONS = {
		administrator: [:administrator],
		moderator: [:administrator, :manage_messages]
	}
	
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

		command(:ping) { |_| "pong :ping_pong:" }

		command(:invite) { |_| @client.invite_url }

		command(:help, max_args: 1) { |event, category| help(event, category) }

		command(:config_mute, max_args: 1, perms: :administrator) { |event, role| config_mute(event, role) }
		
		command(:config_logs, max_args: 1, perms: :administrator) { |event, channel| config_logs(event, channel) }
		command(:config_mod_logs, max_args: 1, perms: :administrator) { |event, channel| config_mod_logs(event, channel) }
		
		command(:config_auto_ban, max_args: 1, perms: :administrator) { |event, count| config_auto_ban(event, count) }
		command(:config_auto_strike, max_args: 1, perms: :administrator) { |event, count| config_auto_strike(event, count) }
		
		command(:config_warn_mute, max_args: 1, perms: :administrator) { |event, duration| config_warn_mute(event, duration) }
		command(:config_strike_mute, max_args: 1, perms: :administrator) { |event, duration| config_strike_mute(event, duration) }

		command(:warn, min_args: 1, perms: :moderator)   { |event, user, *reason|  warn(event, user, reason.join(" "))  }
		command(:strike, min_args: 1, perms: :moderator) { |event, user, *reason| strike(event, user, reason.join(" ")) }
		command(:infractions, max_args: 1) { |event, user| infractions(event, user) }
		
		command(:repeal_warn, min_args: 2, max_args: 2, perms: :moderator)   { |event, user, warnID| repeal_warn(event, user, warnID) }
		command(:repeal_strike, min_args: 2, max_args: 2, perms: :moderator) { |event, user, strikeID| repeal_strike(event, user, strikeID) }
		
		command(:mute, min_args: 1, max_args: 2, perms: :moderator) { |event, user, duration| mute(event, user, duration) }
		command(:unmute, min_args: 1, max_args: 1, perms: :moderator) { |event, user| unmute(event, user) }

		
		# slash commands

		slash_command(:ping) { |event| event.respond(content: "pong :ping_pong:") }

		slash_command(:help) { |event| help(event, event.options["category"], slash_command: true) }
		select_menu("help_select") { |event| help(event, event.values[0], select_menu: true) }

		slash_command(:config_mute, :administrator) { |event| config_mute(event, event.options["role"], slash_command: true) }

		slash_command(:config_logs, :administrator) { |event| config_logs(event, event.options["channel"], slash_command: true) }
		slash_command(:config_mod_logs, :administrator) { |event| config_mod_logs(event, event.options["channel"], slash_command: true) }

		slash_command(:config_auto_strike, :administrator) { |event| config_auto_strike(event, event.options["count"].to_s, slash_command: true) }
		slash_command(:config_auto_ban, :administrator) { |event| config_auto_ban(event, event.options["count"].to_s, slash_command: true) }

		slash_command(:config_warn_mute, :administrator) { |event| config_warn_mute(event, event.options["duration"].to_s + event.options["unit"], slash_command: true) }
		slash_command(:config_strike_mute, :administrator) { |event| config_strike_mute(event, event.options["duration"].to_s + event.options["unit"], slash_command: true) }
		
		slash_command(:infractions) { |event| infractions(event, event.options["user"], slash_command: true) }
		slash_command(:warn, :moderator) { |event| warn(event, event.options["user"], event.options["reason"], slash_command: true) }
		slash_command(:strike, :moderator) { |event| strike(event, event.options["user"], event.options["reason"], slash_command: true) }

		slash_command(:repeal_warn, :moderator) { |event| repeal_warn(event, event.options["user"], event.options["id"].to_s, slash_command: true) }
		slash_command(:repeal_strike, :moderator) { |event| repeal_strike(event, event.options["user"], event.options["id"].to_s, slash_command: true) }

		slash_command(:mute, :moderator) { |event| mute(event, event.options["user"], event.options["duration"].to_s + event.options["unit"], slash_command: true) }
		slash_command(:unmute, :moderator) { |event| unmute(event, event.options["user"], slash_command: true) }
	end

	def run
		@client.run
	end

	def command(name, options={})
		perms = options[:perms]
		options.delete(:perms)
		@client.command(name, options) do |event, *args|
			Thread.new { event.channel.start_typing }

			if perms != nil && !(PERMISSIONS[perms].any? { |perm| event.user.defined_permission?(perm) } || event.server.owner == event.user)
				event.send_embed(
					nil,
					Discordrb::Webhooks::Embed.new(
						title: "Insufficient Permissions!",
						description: "You must be a#{["a", "e", "i", "o", "u"].include?(perms.to_s[0]) ? "n" : ""} #{perms.to_s} to use that command.",
						colour: "cc0000".to_i(16),
						timestamp: Time.new
					)
				)
			else
				yield event, *args
			end
		end
	end

	def slash_command(name, perms=nil)
		@client.application_command(name) do |event|
			if perms != nil && !(PERMISSIONS[perms].any? { |perm| event.user.defined_permission?(perm) } || event.server.owner == event.user)
				event.respond(
					embeds: [Discordrb::Webhooks::Embed.new(
						title: "Insufficient Permissions!",
						description: "You must be a#{["a", "e", "i", "o", "u"].include?(perms.to_s[0]) ? "n" : ""} #{perms.to_s} to use that command.",
						colour: "cc0000".to_i(16),
						timestamp: Time.new
					)]
				)
			else
				yield event
			end
		end
	end

	def select_menu(name)
		@client.select_menu(custom_id: /^#{Regexp.quote(name)}:/) do |event|
			if event.custom_id.split(":")[1].to_i == event.user.id
				yield event
			else
				event.respond(content: "You can't use someone else's select menu!", ephemeral: true)
			end
		end
	end
end