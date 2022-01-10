class Spikey
	def get_channel(channel, server)
		if channel.to_i.to_s == channel
			channel = channel.to_i
		elsif channel.include?("<#") && channel.split("<#")[1][0...-1].to_i.to_s == channel.split("<#")[1][0...-1]
			channel = channel.split("<#")[1][0...-1].to_i
		end

		server.channels.each do |c|
			return c if c.id == channel || c.name == channel
		end

		nil
	end
end