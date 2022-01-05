class Spikey
	def ready
		self.watching = "you."

		current_db_servers  = @servers.find.map { |doc| doc[:_id] }
		current_bot_servers = @client.servers.map { |id, _| id }

		add_servers    = current_bot_servers.reject { |id| current_db_servers.include?(id) }
		remove_servers = current_db_servers.reject { |id| current_bot_servers.include?(id) }
		
		@servers.insert_many(add_servers.map { |id| doc_template(id) })
		@servers.delete_many({ _id: { "$in" => remove_servers } })
	end
end