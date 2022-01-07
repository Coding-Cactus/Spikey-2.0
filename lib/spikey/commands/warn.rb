class Spikey
	def warn(event, user, reason)
		server     = event.server
		server_id  = server.id

		unless event.author.defined_permission?(:administrator) || event.author.defined_permission?(:manage_messages) || server.owner == event.user
			return event.send_embed(
				"",
				Discordrb::Webhooks::Embed.new(
					title: "Insufficient Permissions!",
					description: "You must be a moderator to warn people.",
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
								description: "The reason for the warning must be less than 1000 characters.",
								colour: "cc0000".to_i(16),
								timestamp: Time.new
							)
						)
					end

					server_data = @servers.find({ _id: server_id }).first
					
					log_channel = server_data[:log_channel]
				
					
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
								event.send_message("Failed to log warning.")
							rescue
								nil
							end
						end
					end
						
					
					# message to user
					
					embed = Discordrb::Webhooks::Embed.new(
						title: "You've Been Warned!",
						colour: "00cc00".to_i(16),
						timestamp: Time.new,
						thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
					)
					embed.add_field(name: "Server", value: server.name)
					embed.add_field(name: "Reason", value: reason)

					begin
						member.pm.send_embed(nil, embed)
					rescue
						begin
							event.send_message("Unable to message user.")
						rescue
							nil
						end
					end
					
					
					infractions = server_data[:infractions][member_id]
					infractions ||= { warns: {}, stikes: {} }

					next_id = infractions[:warns].reduce(0) { |biggest, (id, _)| [biggest, id.to_i].max } + 1

					infractions[:warns][next_id] = reason

					@servers.update_one({ _id: server_id }, { "$set" => { "infractions.#{member_id}" => infractions } })					

					
					# auto strike
					
					auto_strike = server_data[:auto_strike]
					
					if auto_strike != 0 && infractions[:warns].length % auto_strike == 0
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

						begin
							event.send_embed("", embed)
						rescue
							nil
						end
						
						unless log_channel == nil
							begin			
								@client.send_message(log_channel, nil, false, embed)
							rescue
								nil
							end
						end
					end
					
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