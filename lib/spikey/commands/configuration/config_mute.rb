class Spikey
	def config_mute(event, role)
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
		

		if role == nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Muting Disabled!",
				description: "Users can no longer be muted.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)

			@servers.update_one({ _id: server_id }, { "$set" => { mute_role: nil } })
		else			
			if role.to_i.to_s == role
				role = role.to_i
			elsif role.include?("<@&") && role.split("<@&")[1][0...-1].to_i.to_s == role.split("<@&")[1][0...-1]
				role = role.split("<@&")[1][0...-1].to_i
			end

			server.roles.each do |r|
				if r.id == role || r.name == role
					embed = Discordrb::Webhooks::Embed.new(
						title: "Muting Enabled!",
						description: "Muted users will be given the <@&#{r.id}> role.",
						colour: "00cc00".to_i(16),
						timestamp: Time.new
					)

					@servers.update_one({ _id: server_id }, { "$set" => { mute_role: r.id } })
					
					break
				end
			end
		end

		return event.send_embed("", embed) unless embed == nil

		event.send_embed(
			"",
			Discordrb::Webhooks::Embed.new(
				title: "Role not found!",
				description: "Could not find the role **#{role}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		)
	end
end