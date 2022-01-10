class Spikey
	def config_auto_strike(event, count)
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
		

		if count == nil || count == "0"
			embed = Discordrb::Webhooks::Embed.new(
				title: "Auto Striking Disabled!",
				description: "Members will no longer be automatically struck after recieving a certain number of warnings.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { auto_strike: 0 } })
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

		return event.send_embed("", embed) unless embed == nil
	end
end