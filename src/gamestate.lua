local colors = require("lib.modules.colors")
local vec = require("lib.modules.vector")
return {
	new = function()
		---@class Gamestate.lua
		local gamestate = {
			size = vec.new(500, 500),
		}
		gamestate.canvas = love.graphics.newCanvas(gamestate.size.x, gamestate.size.y)
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

		function gamestate:_draw()
			love.graphics.setLineWidth(5)
			love.graphics.setColor(colors["Almost Black"])
			love.graphics.rectangle("line", 0, 0, self.size.x, self.size.y)
		end

		return gamestate
	end
}
