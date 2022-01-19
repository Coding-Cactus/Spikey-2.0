class Spikey
	def config_auto_ban(event, count, slash_command: false)
		embed     = nil
		server    = event.server
		server_id = server.id

		if count.to_s == "" || count == "0"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Auto Banning Disabled!",
				description: "Members will no longer be automatically banned after recieving a certain number of strikes.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { auto_ban: nil } })
		else
			
			if count.to_i.to_s == count && count.to_i > 0
				count = count.to_i
			
				embed = Discordrb::Webhooks::Embed.new(
					title: "Auto Banning Enabled!",
					description: "Members will be automatically banned after recieving **#{count}** strike#{count == 1 ? "" : "s"}.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)
	
				@servers.update_one({ _id: server_id }, { "$set" => { auto_ban: count } })
			else
				embed = Discordrb::Webhooks::Embed.new(
					title: "Invalid Argument!",
					description: "The number of strikes must be an integer above 0.",
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
	end
end