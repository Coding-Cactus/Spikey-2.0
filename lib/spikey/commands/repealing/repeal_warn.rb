class Spikey
	def repeal_warn(event, user, warnID)
		server     = event.server
		server_id  = server.id
		
		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || event.server.owner == event.user
			return event.send_embed(
				nil,
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to repeal warnings.",
					colour: "cc0000".to_i,
					timestamp: Time.new
				)
			)
		end
	
		member = get_member(user, server)

		if member == nil
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Member not found!",
					description: "Could not find member **#{user}**",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

		
		member_id = member.id.to_s

		server_data = @servers.find({ _id: server_id }).first
		infractions = server_data[:infractions][member_id]
		log_channel = server_data[:mod_log_channel]

		if infractions == nil || infractions[:warns][warnID] == nil
			return event.send_embed(
				nil,
				Discordrb::Webhooks::Embed.new(
					title: "Warning Not Found!",
					description: "Could not find warning ID **#{warnID}** for **<@#{member.id}> (#{member.username}##{member.discriminator})**.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

		embed = Discordrb::Webhooks::Embed.new(
			title: "Warning Repealed!",
			colour: "00cc00".to_i(16),
			timestamp: Time.new
		)
		embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
		embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
		embed.add_field(name: "Warning ID", value: warnID)
		embed.add_field(name: "Warning Reason", value: infractions[:warns][warnID])
		
		
		begin
			event.send_embed(nil, embed)
		rescue
			nil
		end
	
		unless log_channel == nil
			begin
				@client.send_message(log_channel, nil, false, embed)
			rescue
				begin
					event.send_message("Failed to log warning repeal.")
				rescue
					nil
				end
			end
		end

		@servers.update_one({ _id: server_id }, { "$unset" => { "infractions.#{member_id}.warns.#{warnID}" => 1 } })

		return
	end
end