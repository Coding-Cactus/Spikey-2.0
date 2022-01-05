class Spikey
	def ready
		@client.watching = "you."

		current_db_servers  = @servers.find.map { |doc| doc[:_id] }
		current_bot_servers = @client.servers.map { |id, _| id }

		add_servers    = current_bot_servers.reject { |id| current_db_servers.include?(id) }
		remove_servers = current_db_servers.reject { |id| current_bot_servers.include?(id) }
		
		@servers.insert_many(add_servers.map { |id| doc_template(id) })
		@servers.delete_many({ _id: { "$in" => remove_servers } })


		
		# keep all docs up to date with the template
		
		requests = []
		template = doc_template(nil)
		@servers.find.each do |doc|
			new_doc = {}
			old_doc = doc.map{ |k, v| [k.to_sym, v] }.to_h
			
			request = { update_one: { filter: { _id: doc[:_id] }, update: { "$set" => { } } } }
			
			template.each do |key, value|
				unless old_doc.include?(key)
					new_doc[key] = value
					request[:update_one][:update]["$set"][key] = value
				end
			end

			requests << request if old_doc != new_doc
		end

		Mongo::BulkWrite.new(@servers, requests).execute
	end
end