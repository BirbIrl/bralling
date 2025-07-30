local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
local body
return {
	new = function()
		---@class Weapon.lua
		local weapon = {
			type = "weapon",
			offset = vec.new(30, 0),
			size = vec.new(50, 50),
			---@type weaponGSHeader
			gs = nil,
			hitCooldown = 1
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
				data = self,
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

			local pos = self.gs:getPos()
			local hitbox = {}
			---@class Hitbox.lua
			hitbox = {
				---@type Weapon.lua
				parent = self,
				---@type love.Body
				body = love.physics.newBody(self.gs.parent.gs.parent.world, pos.x, pos.y, "static"),
				---@type love.Shape
				shape = love.physics.newRectangleShape(weapon.size.x / 2, weapon.size.y / 2, weapon.size.x,
					weapon.size.y),
				---@type love.Fixture
				fixture = nil,
				type = "hitbox"
			}
			hitbox.body:setUserData(hitbox)
			hitbox.fixture = love.physics.newFixture(hitbox.body, hitbox.shape)
			hitbox.fixture:setUserData(hitbox)
			hitbox.fixture:setGroupIndex(-hitbox.parent.gs.parent.gs.id)

			function hitbox:isActive()
				---@diagnostic disable-next-line:need-check-nil
				return self.body:isActive()
			end

			function hitbox:setActive(boolean)
				---@diagnostic disable-next-line:need-check-nil
				self.body:setActive(boolean)
			end

			function hitbox:getPos()
				return vec.new(self.body:getPosition())
			end

			---@param vec Vector.lua
			function hitbox:setPos(pos)
				self.body:setPosition(pos.x, pos.y)
			end

			love.physics.newWeldJoint(self.gs.body, hitbox.body, 0, 0, self.size.x / 2, self.size.y, false)


			self.gs.hitbox = hitbox
		end

		function weapon:update(dt)
			print(self.gs:getLinearVelocity())
			local parent = self.gs.parent
			local parentPos = parent.gs:getPos()
			local parentAngle = parent.gs.body:getAngle()
			local radius = parent.radius

			self.gs:setPos(parentPos + (self.offset + vec.new(0, -self.size.y / 2)):rotate(-parentAngle))
			self.gs.hitbox.body:setAwake(true)


			self.gs.body:setAngle(parentAngle)

			if self.gs.cooldown > 0 then
				self.gs.cooldown = self.gs.cooldown - dt
			end

			if self.gs.hitbox:isActive() then
				if self.gs.cooldown > 0 then
					self.gs.hitbox:setActive(false)
				end
			elseif parent.gs:isActive() then
				if self.gs.cooldown <= 0 then
					self.gs.cooldown = 0
					self.gs.hitbox:setActive(true)
				end
			end
			--print(self.gs.body:getAngle())
		end

		function weapon:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors.blend(colors.list["Beige"], { nil, nil, nil, 0 },
				self.gs.cooldown / self.hitCooldown))
			love.graphics.push()
			love.graphics.translate(self.gs.hitbox.body:getX(), self.gs.hitbox.body:getY())
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
