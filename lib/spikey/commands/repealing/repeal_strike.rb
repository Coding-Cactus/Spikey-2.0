class Spikey
	def repeal_strike(event, user, strikeID)
		server     = event.server
		server_id  = server.id
		
		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || event.server.owner == event.user
			return event.send_embed(
				nil,
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to repeal strikes.",
					colour: "cc0000".to_i,
					timestamp: Time.new
				)
			)
		end
	
		if user.to_i.to_s == user
			user = user.to_i
		elsif user.include?("<@") && user.split("<@")[1][0...-1].to_i.to_s == user.split("<@")[1][0...-1]
			user = user.split("<@")[1][0...-1].to_i
		end

		server.members.each do |member|
			if member.id == user || "#{member.username}##{member.discrim}" == user || member.display_name == user
				member_id = member.id.to_s

				server_data = @servers.find({ _id: server_id }).first
				infractions = server_data[:infractions][member_id]				
				log_channel = server_data[:mod_log_channel]

				if infractions == nil || infractions[:strikes][strikeID] == nil
					return event.send_embed(
						nil,
						Discordrb::Webhooks::Embed.new(
							title: "Strike Not Found!",
							description: "Could not find strike ID **#{strikeID}** for **<@#{member.id}> (#{member.username}##{member.discriminator})**.",
							colour: "cc0000".to_i(16),
							timestamp: Time.new
						)
					)
				end

				embed = Discordrb::Webhooks::Embed.new(
					title: "Strike Repealed!",
					colour: "00cc00".to_i(16),
					timestamp: Time.new
				)
				embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
				embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
				embed.add_field(name: "Strike ID", value: strikeID)
				embed.add_field(name: "Strike Reason", value: infractions[:strikes][strikeID])
				
				
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
							event.send_message("Failed to log strike repeal.")
						rescue
							nil
						end
					end
				end

				@servers.update_one({ _id: server_id }, { "$unset" => { "infractions.#{member_id}.strikes.#{strikeID}" => 1 } })

				return
			end
		end
		

		event.send_embed(
			"",
			Discordrb::Webhooks::Embed.new(
				title: "Member not found!",
				description: "Could not find member **#{user}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		)
	end
end