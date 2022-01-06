class Spikey
	def strike(event, user, reason)
		server     = event.server
		server_id  = server.id

		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || server.owner == event.user
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to strike people.",
					colour: "cc0000".to_i(16),
					timestamp: Time.new
				)
			)
		else
			if user.to_i.to_s == user
				user = user.to_i
			elsif user.include?("<@") && user.split("<@")[1][0...-1].to_i.to_s == user.split("<@")[1][0...-1]
				user = user.split("<@")[1][0...-1].to_i
			end
	
			server.members.each do |member|
				if member.id == user || "#{member.username}##{member.discrim}" == user || member.display_name == user
					member_id = member.id.to_s
					reason = "No reason specified" if reason.to_s.gsub(" ", "") == ""

					if reason.length > 1000
						return event.send_embed(
							nil,
							embed = Discordrb::Webhooks::Embed.new(
								title: "Reason Too Large!",
								description: "The reason for the strike must be less than 1000 characters.",
								colour: "cc0000".to_i(16),
								timestamp: Time.new
							)
						)
					end

					
					# message in channel
					
					embed = Discordrb::Webhooks::Embed.new(
						title: "User Struck!",
						colour: "00cc00".to_i(16),
						timestamp: Time.new,
						thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
					)
					embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
					embed.add_field(name: "Reason", value: reason)

					begin
						event.send_embed("", embed)
					rescue
						nil
					end
					

					# message to user
					
					embed = Discordrb::Webhooks::Embed.new(
						title: "You've Been Struck!",
						colour: "00cc00".to_i(16),
						timestamp: Time.new,
						thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
					)
					embed.add_field(name: "Server", value: server.name)
					embed.add_field(name: "Reason", value: reason)

					begin
						member.pm.send_embed(nil, embed)
					rescue
						event.send_message("Unable to message user.")
					end


					# log strike
					
					log_channel = @servers.find({ _id: server_id }).first[:log_channel]

					unless log_channel == nil
						embed = Discordrb::Webhooks::Embed.new(
							title: "User Struck!",
							colour: "00cc00".to_i(16),
							timestamp: Time.new,
							thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
						)
						embed.add_field(name: "Moderator", value: "<@#{event.user.id}> (#{event.user.username}##{event.user.discriminator})")
						embed.add_field(name: "User", value: "<@#{member.id}> (#{member.username}##{member.discriminator})")
						embed.add_field(name: "Reason", value: reason)

						begin
							@client.send_message(log_channel, nil, false, embed)
						rescue							
							event.send_message("Failed to log strike.")
						end
					end

					
					
					infractions = @servers.find({ _id: server_id }).first[:infractions][member_id]
					infractions ||= { warns: {}, strikes: {} }

					next_id = infractions[:strikes].reduce(0) { |biggest, (id, _)| [biggest, id.to_i].max } + 1

					infractions[:strikes][next_id] = reason

					@servers.update_one({ _id: server_id }, { "$set" => { "infractions.#{member_id}" => infractions } })
					return
				end
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