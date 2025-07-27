local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
return {
	new = function(color)
		---@class Ball.lua
		local ball = {
			radius = 25,
			health = 100,
			gs = {
				parent = nil,
				---@type Vector.lua
				pos = nil,
				damage = 0
			}
		}
		if color then
			ball.color = color
		else
			ball.color = colors._keys[math.random(1, #colors._keys)]
		end
		print(ball.color)

		---adds the ball to a given gamestate, used by gamestate:addBall
		---@param gamestate Gamestate.lua
		---@param pos Vector.lua
		function ball:_addToGame(gamestate, pos)
			self.gs = {
				parent = gamestate,
				pos = pos:clone()
			}
		end

		function ball:_draw()
			love.graphics.setLineWidth(1)
			love.graphics.setColor(colors[self.color])
			love.graphics.circle("fill", self.gs.pos.x, self.gs.pos.y, self.radius)
			love.graphics.setColor(colors["Almost Black"])
			love.graphics.circle("line", self.gs.pos.x, self.gs.pos.y, self.radius)
		end

		return ball
	end
}
