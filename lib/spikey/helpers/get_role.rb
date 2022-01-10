class Spikey
	def get_role(role, server)
		if role.to_i.to_s == role
			role = role.to_i
		elsif role.include?("<@&") && role.split("<@&")[1][0...-1].to_i.to_s == role.split("<@&")[1][0...-1]
			role = role.split("<@&")[1][0...-1].to_i
		end

		server.roles.each do |r|
			return r if r.id == role || r.name == role
		end

		nil
	end
end