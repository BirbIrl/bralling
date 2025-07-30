local bib = require("lib.modules.biblib")
local defaults = {
	perish = {
		variables = { time = 0, duration = 1.25, velocity = nil, impactPoint = nil },
		constants = {},
	}
}
return {
	---Creates a new shader wrapper object
	---@param type "perish"
	---@return ShaderWrapper.lua
	new = function(type)
		---@class ShaderWrapper.lua
		local wrapper = {
			shader = love.graphics.newShader("assets/shaders/" .. type .. ".vert"),
			type = type,
			---@type table
			variables = bib.shallowCopy(defaults[type].variables),
			constants = bib.shallowCopy(defaults[type].constants)
		}
		function wrapper:send(name, value)
			self.variables[name] = value
			self.shader:send(name, value)
		end

		function wrapper:get(name)
			return self.variables[name]
		end

		for name, value in pairs(wrapper.variables) do
			wrapper.shader:send(name, value)
		end
		return wrapper
	end
}
