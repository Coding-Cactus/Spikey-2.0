class Spikey
	def parse_time(duration)
		duration.downcase!
		
		unit = duration[-1]
		duration = duration[0...-1]

		return nil unless ["s", "m", "h"].include?(unit)

		if duration.include?(".")
			return nil if duration.to_f.to_s != duration
		else		
			return nil if duration.to_i.to_s != duration
		end

		duration.to_f * [1, 60, 3600][["s", "m", "h"].index(unit)]
	end
end