class Spikey
	def unmute(event, user)
		server = event.server
		server_id = server.id

		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || server.owner == event.user
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to unmute people.",
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
					title: "Unable To Unmute!",
					description: "Muting has not been set up yet. Please do **+config_mute Role** to set a role for muting.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		end


		if user.to_i.to_s == user
			user = user.to_i
		elsif user.include?("<@") && user.split("<@")[1][0...-1].to_i.to_s == user.split("<@")[1][0...-1]
			user = user.split("<@")[1][0...-1].to_i
		end

		muted = @servers.find({ _id: server_id }).first[:muted]

		server.members.each do |member|
			if member.id == user || "#{member.username}##{member.discrim}" == user || member.display_name == user
				unless muted.include?(member.id.to_s)
					return event.send_embed(
						nil,
						Discordrb::Webhooks::Embed.new(
							title: "User Not Muted!",
							description: "Unable to unmute **<@#{member.id}> (#{member.username}##{member.discriminator})** as they are already not muted.",
							colour: "cc0000".to_i(16),
							timestamp: Time.new
						)
					)
				end
				
				begin
					member.remove_role(muted_role)
				rescue
					return event.send_embed(
						nil,
						Discordrb::Webhooks::Embed.new(
							title: "Failed To Unmute!",
							description: "Unable to unmute user. Please check my permissions and that the mute role still exists.",
							colour: "cc0000".to_i(16),
							timestamp: Time.new
						)
					)
				end
			
				
				# message in channel & logs
				
				embed = Discordrb::Webhooks::Embed.new(
					title: "User Unmuted!",
					colour: "00cc00".to_i(16),
					timestamp: Time.new,
					thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
				)
				embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")

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
							event.send_message("Failed to log unmute.")
						rescue
							nil
						end
					end
				end

				
				embed = Discordrb::Webhooks::Embed.new(
					title: "You've Been Unmuted!",
					description: "You've been unmuted in **#{server.name}**.",
					colour: "00cc00".to_i(16),
					timestamp: Time.new,
					thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
				)

				begin
					member.pm.send_embed(nil, embed)
				rescue
					event.send_message("Unable to message user.")
				end

				@servers.update_one({ _id: server_id }, { "$unset" => { "muted.#{member.id}" => 1 } })
				
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