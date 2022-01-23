class Spikey
	def infractions(event, user, slash_command: false)
		embed = nil
		
		if event.channel.pm?
			embeds = Discordrb::Webhooks::Embed.new(
				title: "Command Unavailable!",
				description: "You must use this command from within the server you wish to view your infractions from.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif user == nil
			user = event.user
		elsif event.user.defined_permission?(:administrator) || event.user.defined_permission?(:manage_messages) || event.server.owner == event.user
			u = get_member(user, event.server)

			if u == nil
				embed = Discordrb::Webhooks::Embed.new(
					title: "Member not found!",
					description: "Could not find member **#{user}**",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			end

			user = u
		else
			embed = Discordrb::Webhooks::Embed.new(
				title: "Insufficient Permissions!",
				description: "You must be a moderator to view other server members' infractions.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		end

		unless embed == nil
			if slash_command
				event.respond(embeds: [embed])
			else
				event.send_embed(nil, embed)
			end
			return
		end

		
		embed = Discordrb::Webhooks::Embed.new(
			title: "#{user.username}'s Infractions",
			colour: "00cc00".to_i(16),
			timestamp: Time.new,
			footer: Discordrb::Webhooks::EmbedFooter.new(text: "Page 1"),
			thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url)
		)

		server_data = @servers.find({ _id: event.server.id }).first
		infractions = server_data[:infractions][user.id.to_s]

		warnings = infractions == nil ? {} : infractions[:warns]
		strikes  = infractions == nil ? {} : infractions[:strikes]

		if warnings == {} && strikes == {}
			embed.add_field(name: "Overview", value: "No infractions!")

			begin
				event.user.pm.send_embed(nil, embed)
			rescue				
				if slash_command
					event.respond(content: "Unable to message you.")
				else
					event.send_message("Unable to message you.")
				end
				return
			end
			
			if slash_command
				event.respond(content: "Check your DMs :wink:")
			else
				event.send_message("Check your DMs :wink:")
			end
			return
		end
	
		
		auto_strike = server_data[:auto_strike]

		if auto_strike == nil
			auto_strikes = 0
			auto_strike_msg = ""
		else
			auto_strikes = warnings.length / auto_strike
			auto_strike_msg = "\nAutomatic Strikes: **#{auto_strikes}**"
		end

		embed.add_field(
			name: "Overview",
			value: "Server: **#{event.server.name}**\nWarnings: **#{warnings.length}**\nStrikes: **#{strikes.length + auto_strikes}#{server_data[:auto_ban] == nil ? "" : "/#{server_data[:auto_ban]}"}**#{auto_strike_msg}"
		)
		
		
		warnings_msgs = [""]
		strikes_msgs = [""]

		warnings.each do |id, reason|
			msg = "Warn ID: **#{id}**\nReason: **#{reason}**"

			if msg.length + warnings_msgs[-1].length + 2 > 1024
				warnings_msgs << msg
			else
				warnings_msgs[-1] += (warnings_msgs[-1].length == 0 ? "" : "\n\n") + msg
			end
		end

		strikes.each do |id, reason|
			msg = "Strike ID: **#{id}**\nReason: **#{reason}**"

			if msg.length + strikes_msgs[-1].length + 2 > 1024
				strikes_msgs << msg
			else
				strikes_msgs[-1] += (strikes_msgs[-1].length == 0 ? "" : "\n\n") + msg
			end
		end

		begin
			embed.add_field(name: "Warnings", value: warnings_msgs[0], inline: true) if warnings_msgs[0].to_s != ""
			embed.add_field(name: "Strikes",  value: strikes_msgs[0],  inline: true) if strikes_msgs[0].to_s  != ""
			
			event.user.pm.send_embed(nil, embed)

			warnings_msgs = warnings_msgs[1..-1]
			strikes_msgs = strikes_msgs[1..-1]

			(warnings_msgs.length > strikes_msgs.length ? warnings_msgs : strikes_msgs).each_index do |index|
				embed = Discordrb::Webhooks::Embed.new(
					colour: "00cc00".to_i(16),
					timestamp: Time.new,
					footer: Discordrb::Webhooks::EmbedFooter.new(text: "Page #{index+2}")
				)
				
				embed.add_field(name: "Warnings", value: warnings_msgs[index], inline: true) if warnings_msgs[index].to_s != ""
				embed.add_field(name: "Strikes",  value: strikes_msgs[index],  inline: true) if strikes_msgs[index].to_s != ""

				event.user.pm.send_embed(nil, embed)
			end
		
			
			if slash_command
				event.respond(content: "Check your DMs :wink:")
			else
				event.send_message("Check your DMs :wink:")
			end
		rescue
			if slash_command
				event.respond(content: "Unable to message you.")
			else
				event.send_message("Unable to message you.")
			end
		end
	
		return
	end	
end