class Spikey
	def help(event, category)
		lowered_category = category == nil ? nil : category.downcase
	
		case lowered_category
		when nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Command Categories",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "Do **#{PREFIX}help category** to view a certain category")
			)
			
			embed.add_field(
				name: "Configuration",
				value: "The commands to set up the bot."
			)
			embed.add_field(
				name: "Infractions",
				value: "The commands to infract someone for being naughty."
			)
			embed.add_field(
				name: "Repealing",
				value: "The commands to repeal an infraction when mods get a little too trigger happy."
			)
			embed.add_field(
				name: "Muting",
				value: "The commands to make people shut up."
			)
			embed.add_field(
				name: "Member",
				value: "The commands for any server member to use."
			)
		when "configuration"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Configuration Commands",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "These commands can only be used by server admins")
			)
	
			embed.add_field(
				name: "config_logs",
				value: "Choose to which channel I should send the logs.\nIn the form `+config_logs TextChannel`."
			)
			embed.add_field(
				name: "config_mod_logs",
				value: "Choose to which channel I should send the moderation logs.\nIn the form `+config_mod_logs TextChannel`."
			)
			embed.add_field(
				name: "config_mute",
				value: "Choose which role to be addded to a member when muted.\nIn the form `+config_mute Role`."
			)
			embed.add_field(
				name: "config_warn_mute",
				value: "Choose for how long a member will be muted after being warned.\nIn the form `+config_warn_mute time`."
			)
			embed.add_field(
				name: "config_strike_mute",
				value: "Choose for how long a member will be muted after being struck.\nIn the form `+config_strike_mute time`."
			)
			embed.add_field(
				name: "config_auto_strike",
				value: "Choose how many warnings until a member gets automatically struck.\nIn the form `+config_auto_strike integer`."
			)
			embed.add_field(
				name: "config_auto_ban",
				value: "Choose how many strikes until a member gets automatically banned.\nIn the form `+config_auto_ban integer`."
			)
			embed.add_field(
				name: "config_nicknames",
				value: "Choose to which channel I should send the nickname requests.\nIn the form `+config_nicknames TextChannel`."
			)
		when "infractions"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Infraction Commands",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "These commands can only be used by server moderators")
			)
	
			embed.add_field(
				name: "warn",
				value: "Warn a member for being naughty.\nIn the form `+warn Member <reason>`."
			)
			embed.add_field(
				name: "strike",
				value: "Strike a member for being naughty.\nIn the form `+strike Member <reason>`."
			)
			embed.add_field(
				name: "infractions",
				value: "View your infractions from this server. Moderators can do `+infractions Member` to view another member's infractions. Must allow DMs from me."
			)
		when "repealing"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Repealing Commands",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "These commands can only be used by server moderators")
			)
	
			embed.add_field(
				name: "repeal_warn",
				value: "Repeal one of a member's warns.\nIn the form `+repeal_warn Member WarnID`."
			)
			embed.add_field(
				name: "repeal_strike",
				value: "Repeal one of a member's strikes.\nIn the form `+repeal_strike Member strikeID`."
			)
		when "muting"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Muting Commands",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "These commands can only be used by server moderators (except view_mutes)")
			)
	
			embed.add_field(
				name: "mute",
				value: "Make a member shut up.\nIn the form `+mute Member <time>`, if a time is omitted, then they will be muted indefinitely."
			)
			embed.add_field(
				name: "unmute",
				value: "Allow a member to speak again.\nIn the form `+unmute Member`."
			)
			embed.add_field(
				name: "view_mutes",
				value: "View your current mutes across all the servers that I am in. Must allow DMs from me."
			)
			embed.add_field(
				name: "view_servers_mutes",
				value: "View the current mutes in this server. Must allow DMs from me."
			)
		when "member"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Member Commands",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "These commands can be used by any server member")
			)
	
			embed.add_field(
				name: "infractions",
				value: "View your infractions from this server. Moderators can do `+infractions Member` to view another member's infractions. Must allow DMs from me."
			)
			embed.add_field(
				name: "view_mutes",
				value: "View your current mutes across all the servers that I am in. Must allow DMs from me."
			)
			embed.add_field(
				name: "nickname",
				value: "Request a nickname to have in this server.\nIn the form `+nickname Name`."
			)
		else
			embed = Discordrb::Webhooks::Embed.new(
				title: "Infraction Commands",
				colour: "cc0000".to_i(16),
				description: "Category **#{category}** not found.",
				timestamp: Time.new,
				footer: Discordrb::Webhooks::EmbedFooter.new(text: "Do **#{PREFIX}help category** to view a certain category")
			)
		end
	
		event.send_embed("", embed)
	end
end