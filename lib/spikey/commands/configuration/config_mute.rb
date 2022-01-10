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
			r = get_role(role, server)
	
			if r == nil
				embed = Discordrb::Webhooks::Embed.new(
					title: "Role not found!",
					description: "Could not find the role **#{role}**",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			else
				embed = Discordrb::Webhooks::Embed.new(
					title: "Muting Enabled!",
					description: "Muted users will be given the <@&#{r.id}> role.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)
	
				@servers.update_one({ _id: server_id }, { "$set" => { mute_role: r.id } })
			end
		end

		event.send_embed("", embed)
	end
end