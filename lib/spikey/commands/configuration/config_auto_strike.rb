class Spikey
	def config_auto_strike(event, count, slash_command: false)
		embed     = nil
		server    = event.server
		server_id = server.id

		if count.to_s == "" || count == "0"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Auto Striking Disabled!",
				description: "Members will no longer be automatically struck after recieving a certain number of warnings.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { auto_strike: nil } })
		else
			if count.to_i.to_s == count && count.to_i > 0
				count = count.to_i
			
				embed = Discordrb::Webhooks::Embed.new(
					title: "Auto Striking Enabled!",
					description: "Members will be automatically struck after recieving **#{count}** warning#{count == 1 ? "" : "s"}.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)
	
				@servers.update_one({ _id: server_id }, { "$set" => { auto_strike: count } })
			else
				embed = Discordrb::Webhooks::Embed.new(
					title: "Invalid Argument!",
					description: "The number of warnings must be an integer above 0.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			end
		end

		if slash_command
			event.respond(embeds: [embed])
		else
			event.send_embed(nil, embed)
		end
	
		return
	end
end