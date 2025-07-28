local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")

return {
	new = function()
		---@class Weapon.lua
		local weapon = {
			type = "weapon",
			offset = vec.new(30, 0),
			size = vec.new(50, 50),
			---@type weaponGSHeader
			gs = nil,
			hitCooldown = 5
		}

		function weapon:_addToBall(ball, body, shape, fixture)
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
				---@type number
				cooldown = 0,
			}

			function self.gs:getPos()
				return vec.new(self.body:getPosition())
			end

			---@param vec Vector.lua
			function self.gs:setPos(pos)
				self.body:setPosition(pos.x, pos.y)
			end

			function self.gs:getLinearVelocity()
				return vec.new(self.body:getLinearVelocity())
			end

			---@param vec Vector.lua
			---@return nil
			function self.gs:setLinearVelocity(pos)
				self.body:setLinearVelocity(pos.x, pos.y)
			end
		end

		function weapon:update(dt)
			local parent = self.gs.parent
			local parentPos = parent.gs:getPos()
			local parentAngle = parent.gs.body:getAngle()
			local radius = parent.radius


			self.gs:setPos(parentPos + (self.offset + vec.new(0, -self.size.y / 2)):rotate(-parentAngle))
			self.gs.body:setAwake(true)


			self.gs.body:setAngle(parentAngle)

			if self.gs.cooldown > 0 then
				self.gs.cooldown = self.gs.cooldown - dt
			end

			if self.gs.body:isActive() then
				if self.gs.cooldown > 0 then
					self.gs.body:setActive(false)
				end
			else
				if self.gs.cooldown <= 0 then
					self.gs.cooldown = 0
					self.gs.body:setActive(true)
				end
			end
			--print(self.gs.body:getAngle())
		end

		function weapon:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors.blend(colors.list["Beige"], { nil, nil, nil, 0 },
				self.gs.cooldown / self.hitCooldown))
			love.graphics.push()
			love.graphics.translate(self.gs.body:getX(), self.gs.body:getY())
			love.graphics.rotate(self.gs.body:getAngle())
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
			love.graphics.setColor(colors.blend(colors.list["Almost Black"], { nil, nil, nil, 0 },
				self.gs.cooldown / self.hitCooldown))
			love.graphics.rectangle("line", 0, 0, self.size.x, self.size.y)
			love.graphics.pop()
		end

		return weapon
	end
}
