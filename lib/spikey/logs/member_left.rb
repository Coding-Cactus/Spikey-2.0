class Spikey
	def log_member_left(event)
		user      = event.user
		user_id   = user.id
		user_pfp  = user.avatar_url
		server_id = event.server.id

		server = @servers.find({ _id: server_id }).first

		return if server == nil

		log_channel = server[:log_channel]

		return if log_channel == nil
	
		@client.send_message(
			log_channel,
			nil,
			false,
			Discordrb::Webhooks::Embed.new(
				title: "Member Left!",
				description: "<@#{user_id}> (#{user.username}##{user.discriminator}) left the server!",
				colour: "cc0000".to_i(16),
				timestamp: Time.new,
				thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: user_pfp)
			)
		)
	end
end