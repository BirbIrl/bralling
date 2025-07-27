local colors = require("lib.modules.colors")
serpent = require("lib.modules.serpent") ---@diagnostic disable-line
local gamestate = require("gamestate")
local ball = require("ball")
local gs = gamestate.new()
local player = ball.new()
function love.load()
	love.graphics.setBackgroundColor(colors["Off White"])
	gs:addBall(player)
end

function love.draw()
	love.graphics.setCanvas(gs.canvas)
	love.graphics.setLineWidth(2)
	gs:_draw()
	for _, ball in ipairs(gs.balls) do
		ball:_draw()
	end
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(gs.canvas, (love.graphics.getWidth() - gs.canvas:getWidth()) / 2
	, (love.graphics.getHeight() - gs.canvas:getHeight()) / 2)
end
