class Spikey
	def get_member(member, server)
		if member.to_i.to_s == member
			member = member.to_i
		elsif member.include?("<@")
			u = member.split("<@")[1][0...-1]
			u = u[1..-1] if u[0] == "!"
			member = u.to_i if u.to_i.to_s == u
		end
	
		server.members.each do |m|
			return m if m.id == member || "#{m.username}##{m.discrim}" == member || m.display_name == member
		end

		nil
	end
end