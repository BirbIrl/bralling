local colors = require("lib.modules.colors")
serpent = require("lib.modules.serpent") ---@diagnostic disable-line
local gamestate = require("gamestate")
local ball = require("ball")
local gs = gamestate.new()
local player = ball.new()
function love.load()
	love.graphics.setBackgroundColor(colors.offWhite)
	gs:addBall(player)
end

function love.draw()
	love.graphics.setLineWidth(2)
	for _, ball in ipairs(gs.balls) do
		love.graphics.setColor(colors[ball.color])
		love.graphics.circle("fill", ball.gs.pos.x, ball.gs.pos.y, ball.radius)
		love.graphics.setColor(colors.almostBlack)
		love.graphics.circle("line", ball.gs.pos.x, ball.gs.pos.y, ball.radius)
	end
end
