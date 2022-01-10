class Spikey
	def config_logs(event, channel)
		embed     = nil
		server    = event.server
		server_id = server.id

		unless event.author.defined_permission?(:administrator) || server.owner == event.user
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be an administrator to use the configuration commands.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end
		

		if channel == nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Logging Disabled!",
				description: "Important events will no longer be logged.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { log_channel: nil } })
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
					description: "Important events will now be logged in <##{c.id}>.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)

				@servers.update_one({ _id: server_id }, { "$set" => { log_channel: c.id } })
			end
		end

		event.send_embed("", embed)
	end
end