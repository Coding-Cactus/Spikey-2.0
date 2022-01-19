class Spikey
	def config_mod_logs(event, channel, slash_command: false)
		embed     = nil
		server    = event.server
		server_id = server.id

		if channel == nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Logging Disabled!",
				description: "Important moderation events will no longer be logged.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { mod_log_channel: nil } })
		else
			c = get_channel(channel, server)

			if c == nil
				embed = Discordrb::Webhooks::Embed.new(
					title: "Channel not found!",
					description: "Could not find the channel **#{channel}**",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			else
				embed = Discordrb::Webhooks::Embed.new(
					title: "Logging Enabled!",
					description: "Important moderation events will now be logged in <##{c.id}>.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)

				@servers.update_one({ _id: server_id }, { "$set" => { mod_log_channel: c.id } })
			end
		end

		if slash_command
			event.respond(embeds: [embed])
		else
			event.send_embed(nil, embed)
		end
	end
end