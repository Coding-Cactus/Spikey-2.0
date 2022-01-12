class Spikey
	private

	def doc_template(server_id)
		{
			_id: server_id,
			log_channel: nil,
			mod_log_channel: nil,
			infractions: {},
			auto_ban: 0,
			auto_strike: 0,
			mute_role: nil,
			muted: {},
			warn_mute: nil,
			strike_mute: nil
		}
	end
end