return {
	getTableKeys = function(t, includeMeta)
		local keys = {}
		for k, _ in pairs(t) do
			if includeMeta or k:sub(0, 1) ~= "_" then
				table.insert(keys, k)
			end
		end
		return keys
	end,
	lerp = function(a, b, t) return a * (1 - t) + b * t end
}
