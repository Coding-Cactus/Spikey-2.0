class Spikey
	def config_mod_logs(event, channel)
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
			if channel.to_i.to_s == channel
				channel = channel.to_i
			elsif channel.include?("<#") && channel.split("<#")[1][0...-1].to_i.to_s == channel.split("<#")[1][0...-1]
				channel = channel.split("<#")[1][0...-1].to_i
			end

			server.channels.each do |c|
				if c.id == channel || c.name == channel
					embed = Discordrb::Webhooks::Embed.new(
						title: "Logging Enabled!",
						description: "Important moderation events will now be logged in <##{c.id}>.",
						colour: "00cc00".to_i(16),
						timestamp: Time.new
					)

					@servers.update_one({ _id: server_id }, { "$set" => { mod_log_channel: c.id } })
					
					break
				end
			end
		end

		return event.send_embed("", embed) unless embed == nil

		event.send_embed(
			"",
			Discordrb::Webhooks::Embed.new(
				title: "Channel not found!",
				description: "Could not find the channel **#{channel}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		)
	end
end