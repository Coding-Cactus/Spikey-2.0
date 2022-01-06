class Spikey
	def infractions(event, user)		
		if event.channel.pm?
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Command Unavailable!",
					description: "You must use this command from within the server you wish to view your infractions from.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

		
		if user == nil
			user = event.user
		elsif event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || event.server.owner == event.user
			if user.to_i.to_s == user
				user = user.to_i
			elsif user.include?("<@") && user.split("<@")[1][0...-1].to_i.to_s == user.split("<@")[1][0...-1]
				user = user.split("<@")[1][0...-1].to_i
			end

			u = nil
			event.server.members.each do |member|
				if member.id == user || "#{member.username}##{member.discrim}" == user || member.display_name == user
					u = member
					break
				end
			end

			if u == nil
				return event.send_embed(
					"",
					Discordrb::Webhooks::Embed.new(
						title: "Member not found!",
						description: "Could not find member **#{user}**",
						colour: "cc0000".to_i(16),
						timestamp: Time.new
					)
				)
			end

			user = u
		else			
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to view other server members' infractions.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

		title = "#{user.username}'s Infractions"
		
		embed = Discordrb::Webhooks::Embed.new(
			title: title,
			colour: "00cc00".to_i(16),
			timestamp: Time.new,
			footer: Discordrb::Webhooks::EmbedFooter.new(text: "Page 1"),			
			thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url)
		)

		infractions = @servers.find({ _id: event.server.id }).first[:infractions][user.id.to_s]		
		warnings = infractions[:warns]
		strikes  = infractions[:strikes]

		embed.add_field(name: "Overview", value: "Server: **#{event.server.name}**\nWarnings: **#{warnings.length}**\nStrikes: **#{strikes.length}**")
		
		
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

				Thread.new { event.user.pm.send_embed(nil, embed) }
			end
		
			return event.send_message("Check your DMs :wink:")
		rescue
			event.send_message("Unable to message you.")
		end
	end	
end