class Spikey
	def mute(event, user, duration, slash_command: false, embeds: [])
		server    = event.server
		server_id = server.id
		member    = get_member(user, server)
		
		duration = parse_time(duration) unless duration == nil
		duration = nil if duration == 0
		
		start = Time.new

		server_data = @servers.find({ _id: server_id }).first
		muted_role  = server_data[:mute_role]
		log_channel = server_data[:mod_log_channel]

		if muted_role == nil
			embeds << Discordrb::Webhooks::Embed.new(
				title: "Unable To Mute!",
				description: "Muting has not been set up yet. Please do **+config_mute Role** to set a role for muting.",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif member == nil
			embeds << Discordrb::Webhooks::Embed.new(
				title: "Member not found!",
				description: "Could not find member **#{user}**",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		elsif duration != nil && duration < 0
			embeds << Discordrb::Webhooks::Embed.new(
				title: "Invalid Duration!",
				description: "The duration must be a positive integer with one of the following units:\n```yaml\ns: Seconds\nm: Minutes\nh: Hours\n```",
				colour: "cc0000".to_i(16),
				timestamp: Time.new
			)
		else		
			begin
				member.add_role(muted_role)
				role_added = true
			rescue
				role_added = false
				embeds << Discordrb::Webhooks::Embed.new(
					title: "Failed To Mute!",
					description: "Unable to mute user. Please check my permissions and that the mute role still exists.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			end
		end

		if role_added	
			end_time = duration == nil ? nil : start + duration
			
			# message in channel & logs
			
			embed = Discordrb::Webhooks::Embed.new(
				title: "User Muted!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
			)
			embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
			embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
			embed.add_field(name: "Duration", value: display_time(duration, date: false), inline: true)
			embed.add_field(name: "Start", value: display_time(start), inline: true)
			embed.add_field(name: "End", value: display_time(end_time), inline: true)
	
			embeds << embed
	
			unless log_channel == nil
				begin
					@client.send_message(log_channel, nil, false, embed)
				rescue
					begin
						event.send_message("Failed to log mute.")
					rescue
						nil
					end
				end
			end

		
			user_embed = Discordrb::Webhooks::Embed.new(
				title: "You've Been Muted!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
			)
			user_embed.add_field(name: "Server", value: server.name)
			user_embed.add_field(name: "Duration", value: display_time(duration, date: false), inline: true)
			user_embed.add_field(name: "Start", value: display_time(start), inline: true)
			user_embed.add_field(name: "End", value: display_time(end_time), inline: true)
	
			begin
				member.pm.send_embed(nil, user_embed)
			rescue
				begin
					event.send_message("Unable to message user.")
				rescue
					nil
				end
			end
	
			@servers.update_one({ _id: server_id }, { "$set" => { "muted.#{member.id}" => end_time } })
		end

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
end