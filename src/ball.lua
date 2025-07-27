local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
return {
	new = function(color, radius)
		---@class Ball.lua
		local ball = {
			radius = radius or 32,
			health = 100,
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
		end

		function ball:update(dt)
			local x, y = self.gs.body:getLinearVelocity()
			local max = self.maxSpeed
			if x > max then
				x = max
			end
			if y > max then
				y = max
			end
			self.gs.body:setLinearVelocity(x, y)
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
