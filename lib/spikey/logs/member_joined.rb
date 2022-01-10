class Spikey
	def log_member_joined(event)
		user      = event.user
		user_id   = user.id
		user_pfp  = user.avatar_url
		server_id = event.server.id
		server = @servers.find({ _id: server_id }).first

		return if server == nil

		if server[:mute_role] != nil && server[:muted] != nil && server[:muted].include?(user_id.to_s)
			begin
				user.add_role(server[:mute_role])
			rescue
				nil
			end
		end

		log_channel = server[:log_channel]

		return if log_channel == nil
		
		@client.send_message(
			log_channel,
			nil,
			false,
			Discordrb::Webhooks::Embed.new(
				title: "New Member!",
				description: "<@#{user_id}> (#{user.username}##{user.discriminator}) joined the server!",
				colour: "00cc00".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: user_pfp)
			)
		)
	end
end