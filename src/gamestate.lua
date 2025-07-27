local vec = require("lib.modules.vector")
return {
	new = function()
		---@class Gamestate.lua
		local gamestate = {
			size = vec.new(500, 500),
		}
		---@type Ball.lua[]
		gamestate.balls = {}
		---comment
		---@param ball Ball.lua
		function gamestate:addBall(ball, pos)
			if not pos then
				pos = vec.new(
					love.math.random(0 + ball.radius, self.size.x - ball.radius),
					love.math.random(0 + ball.radius, self.size.y - ball.radius))
			end
			ball:_addToGame(self, pos)
			table.insert(self.balls, ball)
		end

		return gamestate
	end
}
