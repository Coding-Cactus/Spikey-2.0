class Spikey
	def log_message_edit(event)
		new_message = event.message
		
		message_id  = new_message.id
		channel_id  = event.channel.id
		
		old_message = @cached_messages[message_id]

		return if old_message == nil || old_message.content == new_message.content

		@cached_messages[message_id] = new_message

		user      = new_message.user
		user_id   = user.id
		user_pfp  = user.avatar_url
		server_id = new_message.server.id

		server = @servers.find({ _id: server_id }).first

		return if server == nil

		log_channel = server[:log_channel]

		return if log_channel == nil

		embed = Discordrb::Webhooks::Embed.new(
			title: "Message Edited!",
			colour: "cccc00".to_i(16),
			timestamp: Time.new,
			thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(url: user_pfp)
		)

		embed.add_field(name: "In", value: "<##{channel_id}>", inline: true)
		embed.add_field(name: "From", value: "<@#{user_id}> (#{user.username}##{user.discriminator})", inline: true)
		embed.add_field(name: "Before", value: old_message.content)
		embed.add_field(name: "After", value: new_message.content)
		
		
		@client.send_message(
			log_channel,
			nil,
			false,
			embed
		)
	end
end