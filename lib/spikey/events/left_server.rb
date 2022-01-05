class Spikey
	def left_server(event)
		server_id = event.server

		unless @servers.find({ _id: server_id }).first == nil
			@servers.delete_one({ _id: server_id })
		end
	end
end