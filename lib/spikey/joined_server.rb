class Spikey
	def joined_server(event)
		server_id = event.server.id

		if @servers.find({ _id: server_id }).first == nil
			@servers.insert_one(doc_template(server_id))
		end
	end
end