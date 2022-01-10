class Spikey
	def check_mutes
		time = Time.new
		servers = @servers.find.to_a.map do |data|
			[
				data[:_id],
				{
					unmute: data[:muted].select { |_, end_time| end_time != nil && end_time < time },
					mute_role: data[:mute_role],
					mod_log_channel: data[:mod_log_channel]
				}
			] 
		end.to_h

		requests = []
		
		@client.servers.each do |server_id, server|
			unmute = servers[server_id][:unmute]
			mute_role = servers[server_id][:mute_role]
			log_channel = servers[server_id][:mod_log_channel]
			
			next if unmute.length == 0 || mute_role == nil

			server.members.each do |member|
				next unless unmute.include?(member.id.to_s)

				begin
					member.remove_role(mute_role)
					requests << { update_one: { filter: { _id: server_id }, update: { "$unset" => { "muted.#{member.id}" => 1 } } } }
					
	
					begin
						member.pm.send_embed(
							nil,
							Discordrb::Webhooks::Embed.new(
								title: "You've Been Unmuted!",
								description: "You've been unmuted in **#{server.name}**.",
								colour: "00cc00".to_i(16),
								timestamp: Time.new,
								thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: server.icon_url)
							)
						)
					rescue
						nil
					end

					unless log_channel == nil
						begin
							@client.send_message(log_channel,
								nil,
								false,
								Discordrb::Webhooks::Embed.new(
									title: "User Unmuted!",
									description: "<@#{member.id}> (#{member.username}##{member.discriminator}) has been unmuted.",
									colour: "00cc00".to_i(16),
									timestamp: time,
									thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: member.avatar_url)
								)
							)
						rescue
							nil
						end
					end
				rescue
					nil
				end
			end
		end

		Mongo::BulkWrite.new(@servers, requests).execute
	end
end