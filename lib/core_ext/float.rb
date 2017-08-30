class Float
	def round_n n = 4
		round to_i > 0 ? n - to_i.to_s.size : n
	end
end