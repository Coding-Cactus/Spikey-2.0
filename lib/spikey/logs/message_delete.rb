class Spikey
	def log_message_delete(event)
		message_id = event.id
		channel_id = event.channel.id
		
		message = @cached_messages[message_id]

		return if message == nil

		@cached_messages.delete(message_id)

		user      = message.user
		user_id   = user.id
		user_pfp  = user.avatar_url
		server_id = message.server.id

		server = @servers.find({ _id: server_id }).first

		return if server == nil

		log_channel = server[:log_channel]

		return if log_channel == nil

		embed = Discordrb::Webhooks::Embed.new(
			title: "Message Deleted!",
			colour: "cc0000".to_i(16),
			timestamp: Time.new,
			thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: user_pfp)
		)

		embed.add_field(name: "In", value: "<##{channel_id}>", inline: true)
		embed.add_field(name: "From", value: "<@#{user_id}> (#{user.username}##{user.discriminator})", inline: true)
		embed.add_field(name: "Content", value: message.content) unless message.content.to_s == ""
		
		
		@client.send_message(
			log_channel,
			nil,
			false,
			embed
		)
		
		attachments = message.attachments.map(&:url)
		
		@client.send_message(log_channel, "**Attachments**\n" + attachments.join("\n")) if attachments.length > 0
	end
end