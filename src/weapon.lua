local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")

return {
	new = function()
		---@class Weapon.lua
		local weapon = {
			offset = vec.new(50, 0),
			size = vec.new(50, 50),
			---@type weaponGSHeader
			gs = nil
		}

		function weapon:_addToBall(ball, body, shape, fixture, joint)
			---@class weaponGSHeader
			self.gs = {
				---@type Ball.lua
				parent = ball,
				---@type love.Body
				body = body,
				---@type love.Shape
				shape = shape,
				---@type love.Fixture
				fixture = fixture,
				---@type love.Joint
				joint = joint,
			}

			function self.gs:getPos()
				return vec.new(self.body:getPosition())
			end

			function self.gs:getLinearVelocity()
				return vec.new(self.body:getLinearVelocity())
			end

			---@param vec Vector.lua
			---@return nil
			function self.gs:setLinearVelocity(vec)
				self.body:setLinearVelocity(vec.x, vec.y)
			end
		end

		function weapon:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors["Beige"])
			love.graphics.push()
			love.graphics.translate(self.gs.body:getX(), self.gs.body:getY())
			love.graphics.rotate(self.gs.body:getAngle())
			love.graphics.rectangle("fill", 0, 0,
				self.size.x, self.size.y)
			love.graphics.setColor(colors["Almost Black"])
			love.graphics.rectangle("line", 0, 0,
				self.size.x, self.size.y)
			love.graphics.pop()
		end

		return weapon
	end
}
