class Spikey
	def display_time(time, date: true)
		return "Indefinite" if time == nil

		time = time.to_f
		
		y = ((time / (3600 * 24).to_f / 30.436875 / 12.0) + (date ? 1970 : 0)).floor.to_s
		m = ((time / (3600 * 24).to_f / 30.436875 % 12) + (date ? 1 : 0)).floor.to_s
		d = (time / (3600 * 24).to_f % 30.436875).floor.to_s

		h = (time / 3600.0 % 24).floor.to_s
		i = (time % 3600 / 60).floor.to_s
		s = (time % 3600 % 60).floor.to_s

		y = "0" + y if y.length < 2
		m = "0" + m if m.length < 2
		d = "0" + d if d.length < 2

		h = "0" + h if h.length < 2
		i = "0" + i if i.length < 2
		s = "0" + s if s.length < 2

		"#{d}/#{m}/#{y} #{h}:#{i}:#{s}"
	end
end