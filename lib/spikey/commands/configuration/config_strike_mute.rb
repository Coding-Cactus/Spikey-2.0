class Spikey
	def config_strike_mute(event, duration, slash_command: false)
		embed     = nil
		server    = event.server
		server_id = server.id
		duration  = parse_time(duration)

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

		if slash_command
			event.respond(embeds: [embed])
		else
			event.send_embed(nil, embed)
		end
	
		return
	end
end