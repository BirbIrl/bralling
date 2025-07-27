local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
return {
	new = function(color, radius)
		---@class Ball.lua
		local ball = {
			radius = radius or 32,
			health = 100,
			magneticPull = 1,
			maxSpeed = 1000,
			---@type gsHeader
			gs = nil
		}
		if color then
			ball.color = color
		else
			ball.color = colors._keys[math.random(1, #colors._keys)]
		end
		print(ball.color)

		---adds the ball to a given gamestate, used by gamestate:addBall
		---@param gamestate Gamestate.lua
		---@param body love.Body
		---@param shape love.Shape
		---@param fixture love.Fixture
		function ball:_addToGame(gamestate, body, shape, fixture)
			---@class gsHeader
			self.gs = {
				parent = gamestate,
				body = body,
				shape = shape,
				fixture = fixture,
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

		function ball:findClosestBall()
			local pos = self.gs:getPos()
			local diffs = {}

			for index, candidate in ipairs(self.gs.parent.balls) do
				table.insert(diffs, { ball = candidate, diff = (pos - candidate.gs:getPos()):getmag() })
			end

			table.sort(diffs, function(a, b)
				return a.diff < b.diff
			end)

			table.remove(diffs, 1)
			return diffs[1].ball
		end

		---comment
		---@param target Ball.lua
		---@return Vector.lua
		function ball:getDistanceFromBall(target)
			return target.gs:getPos() - self.gs:getPos()
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
		end

		function ball:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors[self.color])
			love.graphics.circle("fill", self.gs.body:getX(), self.gs.body:getY(),
				self.radius)
			love.graphics.setColor(colors["Almost Black"])
			love.graphics.circle("line", self.gs.body:getX(), self.gs.body:getY(),
				self.radius)
		end

		return ball
	end
}
