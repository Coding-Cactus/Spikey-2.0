class Spikey
	def mute(event, user, duration)
		server     = event.server
		server_id  = server.id
		
		start = Time.new

		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || server.owner == event.user
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to mute people.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

		server_data = @servers.find({ _id: server_id }).first
		muted_role  = server_data[:mute_role]
		log_channel = server_data[:mod_log_channel]

		if muted_role == nil
			return event.send_embed(
				nil,
				Discordrb::Webhooks::Embed.new(
					title: "Unable To Mute!",
					description: "Muting has not been set up yet. Please do **+config_mute Role** to set a role for muting.",
					colour: "cc0000".to_i(16),
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
	
		unless duration == nil
			duration = parse_time(duration)

			if duration == nil || duration <= 0
				return event.send_embed(
					nil,
					Discordrb::Webhooks::Embed.new(
						title: "Invalid Duration!",
						description: "The duration must be a positive integer with one of the following units:\n```yaml\ns: Seconds\nm: Minutes\nh: Hours\n```",
						colour: "cc0000".to_i(16),
						timestamp: Time.new
					)
				)
			end
		end

		
		begin
			member.add_role(muted_role)
		rescue
			return event.send_embed(
				nil,
				Discordrb::Webhooks::Embed.new(
					title: "Failed To Mute!",
					description: "Unable to mute user. Please check my permissions and that the mute role still exists.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end

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

		begin
			event.send_embed("", embed)
		rescue
			nil
		end

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

		
		embed = Discordrb::Webhooks::Embed.new(
			title: "You've Been Muted!",
			colour: "00cc00".to_i(16),
			timestamp: Time.new,
			thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
		)
		embed.add_field(name: "Server", value: server.name)
		embed.add_field(name: "Duration", value: display_time(duration, date: false), inline: true)
		embed.add_field(name: "Start", value: display_time(start), inline: true)
		embed.add_field(name: "End", value: display_time(end_time), inline: true)

		begin
			member.pm.send_embed(nil, embed)
		rescue
			begin
				event.send_message("Unable to message user.")
			rescue
				nil
			end
		end

		@servers.update_one({ _id: server_id }, { "$set" => { "muted.#{member.id}" => end_time } })
		
		return
	end
end