class Spikey
	def config_strike_mute(event, duration)
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
	
		duration = parse_time(duration)
	
		if duration == nil
			embed = Discordrb::Webhooks::Embed.new(
					title: "Invalid Duration!",
				description: "The duration must be a positive integer with one of the following units:\n```yaml\ns: Seconds\nm: Minutes\nh: Hours\n```",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif duration == 0
			embed = Discordrb::Webhooks::Embed.new(
				title: "Muting Disabled!",
				description: "Users will longer be muted after recieving a strike.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { strike_mute: nil } })
		else
			embed = Discordrb::Webhooks::Embed.new(
				title: "Muting Enabled!",
				description: "Users will be muted for **#{display_time(duration, date: false)}** when they recieve a strike.",
				colour: "00cc00".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { strike_mute: duration } })
		end

		event.send_embed("", embed)
	end
end