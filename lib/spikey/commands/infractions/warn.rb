class Spikey
	def warn(event, user, reason, slash_command: false)
		server     = event.server
		server_id  = server.id	
		member     = get_member(user, server)		
		member_id  = member == nil ? nil : member.id.to_s
		
		reason = "No reason specified" if reason.to_s.gsub(" ", "") == ""

		embeds = []

		if member == nil
			embeds << Discordrb::Webhooks::Embed.new(
				title: "Member not found!",
				description: "Could not find member **#{user}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif reason.length > 1000
			embeds << Discordrb::Webhooks::Embed.new(
				title: "Reason Too Large!",
				description: "The reason for the warning must be less than 1000 characters.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		else
			server_data = @servers.find({ _id: server_id }).first
			
			log_channel = server_data[:mod_log_channel]
			warn_mute   = server_data[:warn_mute]
			strike_mute = server_data[:strike_mute]
			auto_struck = auto_banned = false
		
			
			# message in channel & logs
			
			embed = Discordrb::Webhooks::Embed.new(
				title: "User Warned!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
			)
			embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
			embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
			embed.add_field(name: "Reason", value: reason)

			embeds << embed
	
			unless log_channel == nil
				begin
					@client.send_message(log_channel, nil, false, embed)
				rescue
					begin
						event.send_message("Failed to log warning.")
					rescue
						nil
					end
				end
			end
				
			
			# message to user
			
			user_embed = Discordrb::Webhooks::Embed.new(
				title: "You've Been Warned!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
			)
			user_embed.add_field(name: "Server", value: server.name)
			user_embed.add_field(name: "Reason", value: reason)
	
			begin
				member.pm.send_embed(nil, user_embed)
			rescue
				begin
					event.send_message("Unable to message user.")
				rescue
					nil
				end
			end
			
			
			infractions = server_data[:infractions][member_id]
			infractions ||= { warns: {}, strikes: {} }
	
			next_id = infractions[:warns].reduce(0) { |biggest, (id, _)| [biggest, id.to_i].max } + 1
	
			infractions[:warns][next_id] = reason
	
			@servers.update_one({ _id: server_id }, { "$set" => { "infractions.#{member_id}" => infractions } })
	
			
			# auto strike
			
			auto_strike = server_data[:auto_strike]
			auto_ban    = server_data[:auto_ban]
			
			if auto_strike != 0 && infractions[:warns].length % auto_strike == 0
				auto_struck = true
				
				begin
					member.pm.send_embed(
						nil,
						Discordrb::Webhooks::Embed.new(
							title: "You've Been Automatically Struck!",
							description: "You've been struck automatically after recieving **#{auto_strike}** warning#{auto_strike == 1 ? "" : "s"}.",
							colour: "00cc00".to_i(16),
							timestamp: Time.new,
							thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
						)
					)
				rescue
					nil
				end
	
				
				embed = Discordrb::Webhooks::Embed.new(
					title: "Member Automatically Struck!",
					description: "<@#{member.id}> (#{member.username}##{member.discriminator}) has been struck automatically after recieving **#{auto_strike}** warning#{auto_strike == 1 ? "" : "s"}.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new,
					thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
				)
	
				embeds << embed
				
				unless log_channel == nil
					begin
						@client.send_message(log_channel, nil, false, embed)
					rescue
						nil
					end
				end
			end
		
	
			strike_count = infractions[:strikes].length + (auto_strike == nil ? 0 : infractions[:warns].length / auto_strike)
	
			if auto_ban != nil && strike_count >= auto_ban
				auto_banned = true
				begin
					server.ban(member_id, 0, reason: "Automatically banned for reaching the strike limit.")
					
					embed = Discordrb::Webhooks::Embed.new(
						title: "Member Automatically Banned!",
						description: "<@#{member.id}> (#{member.username}##{member.discriminator}) has been banned automatically after recieving **#{strike_count}/#{auto_ban}** strike#{strike_count == 1 ? "" : "s"}.",
						colour: "00cc00".to_i(16),
						timestamp: Time.new,
						thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
					)
	
					embeds << embed
					
					unless log_channel == nil
						begin
							@client.send_message(log_channel, nil, false, embed)
						rescue
							nil
						end
					end
				rescue
					begin
						event.send_message("Unable to ban member, however they have reached the strike limit. Make sure to ban this member yourself, and give me permissions for next time.")
					rescue
						nil
					end
				end
			end
		end
		
		return if member == nil || reason.length > 1000
		
		if !auto_banned && auto_struck && strike_mute != nil
			return mute(event, member_id, "#{strike_mute}s", slash_command: slash_command, embeds: embeds)
		elsif !auto_banned && warn_mute != nil
			return mute(event, member_id, "#{warn_mute}s", slash_command: slash_command, embeds: embeds)
		else
			begin
				if slash_command
					event.respond(embeds: embeds)
				else
					embeds.each { |e| event.send_embed(nil, e) }
				end
			rescue
				nil
			end
		end
	
		return
	end
end