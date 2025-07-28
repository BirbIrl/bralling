local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
return {
	new = function(color, radius)
		---@class Ball.lua
		local ball = {
			type = "ball",
			radius = radius or 32,
			health = 100,
			magneticPull = 2,
			maxSpeed = 1000,
			---@type Weapon.lua[]
			weapons = {},
			---@type ballGSHeader
			gs = nil
		}
		if color then
			ball.color = color
		else
			ball.color = colors.keys[math.random(1, #colors.keys)]
		end
		print(ball.color)

		---adds the ball to a given gamestate, used by gamestate:addBall
		---@param gamestate Gamestate.lua
		---@param body love.Body
		---@param shape love.Shape
		---@param fixture love.Fixture
		function ball:_addToGame(gamestate, body, shape, fixture, id)
			---@class ballGSHeader
			self.gs = {
				id = id,
				parent = gamestate,
				body = body,
				shape = shape,
				fixture = fixture,
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

		function ball:findClosestBall()
			local pos = self.gs:getPos()
			local diffs = {}

			for _, candidate in ipairs(self.gs.parent.balls) do
				table.insert(diffs, { ball = candidate, diff = (pos - candidate.gs:getPos()):getmag() })
			end

			table.sort(diffs, function(a, b)
				return a.diff < b.diff
			end)

			table.remove(diffs, 1)
			if diffs[1] then
				return diffs[1].ball
			end
		end

		---@param weapon Weapon.lua
		function ball:addWeapon(weapon)
			local weaponPos = self.gs:getPos()
			local body = love.physics.newBody(self.gs.parent.world, weaponPos.x, weaponPos.y, "kinematic")
			body:setUserData(weapon)
			local shape = love.physics.newRectangleShape(weapon.size.x / 2, weapon.size.y / 2, weapon.size.x,
				weapon.size.y)
			local fixture = love.physics.newFixture(body, shape, 0)
			fixture:setGroupIndex(-self.gs.id)
			fixture:setUserData(weapon)
			--fixture:setMask(1)
			--fixture:setSensor(true)
			weapon:_addToBall(self, body, shape, fixture)
			table.insert(self.weapons, weapon)
		end

		---comment
		---@param target Ball.lua
		---@return Vector.lua
		function ball:getDistanceFromBall(target)
			if target then
				return target.gs:getPos() - self.gs:getPos()
			else
				return vec.new(0, 0)
			end
		end

		function ball:update(dt)
			local velocity = self.gs:getLinearVelocity()

			velocity = velocity + self:getDistanceFromBall(self:findClosestBall()):norm() * self.magneticPull

			-- cap out the velocity
			local max = self.maxSpeed
			if velocity.x > max then
				velocity.x = max
			end
			if velocity.y > max then
				velocity.y = max
			end

			self.gs:setLinearVelocity(velocity)

			for _, weapon in ipairs(self.weapons) do
				weapon:update(dt)
			end
		end

		function ball:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors.list[self.color])
			love.graphics.circle("fill", self.gs.body:getX(), self.gs.body:getY(),
				self.radius)
			love.graphics.setColor(colors.list["Almost Black"])
			love.graphics.circle("line", self.gs.body:getX(), self.gs.body:getY(),
				self.radius)
		end

		return ball
	end
}
