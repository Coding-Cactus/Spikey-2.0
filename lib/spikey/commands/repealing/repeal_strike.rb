class Spikey
	def repeal_strike(event, user, strikeID, slash_command: false)
		server    = event.server
		server_id = server.id
		
		member    = get_member(user, server)	
		member_id = member.id.to_s unless member == nil

		server_data = @servers.find({ _id: server_id }).first
		infractions = server_data[:infractions][member_id]
		log_channel = server_data[:mod_log_channel]

		if member == nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Member not found!",
				description: "Could not find member **#{user}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif infractions == nil || infractions[:strikes][strikeID] == nil
			embed = Discordrb::Webhooks::Embed.new(
				title: "Strike Not Found!",
				description: "Could not find strike ID **#{strikeID}** for **<@#{member.id}> (#{member.username}##{member.discriminator})**.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		else
			embed = Discordrb::Webhooks::Embed.new(
				title: "Strike Repealed!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new
			)
			embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
			embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
			embed.add_field(name: "Strike ID", value: strikeID)
			embed.add_field(name: "Strike Reason", value: infractions[:strikes][strikeID])
		
			unless log_channel == nil
				begin
					@client.send_message(log_channel, nil, false, embed)
				rescue
					begin			
						if slash_command
							event.respond(content: "Failed to log strike repeal.")
						else
							event.send_message("Failed to log strike repeal.")
						end
					rescue
						nil
					end
				end
			end
	
			@servers.update_one({ _id: server_id }, { "$unset" => { "infractions.#{member_id}.strikes.#{strikeID}" => 1 } })
		end

		if slash_command
			event.respond(embeds: [embed])
		else
			event.send_embed(nil, embed)
		end
	end
end