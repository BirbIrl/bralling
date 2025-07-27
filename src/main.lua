local colors = require("lib.modules.colors")
serpent = require("lib.modules.serpent") ---@diagnostic disable-line
local gamestate = require("gamestate")
local ball = require("ball")

love.physics.setMeter(64)
local gs = gamestate.new()
local player = ball.new()
function love.load()
	love.graphics.setBackgroundColor(colors["Off White"])
	gs:addBall(player)
	gs:addBall(ball.new())
	player:findClosestBall()
	--player.gs.body:setLinearVelocity(200, 0)
end

function love.update(dt)
	gs:update(dt)
end

function love.draw()
	love.graphics.setCanvas(gs.canvas)
	love.graphics.clear()
	love.graphics.setLineWidth(2)
	gs:_draw()
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(gs.canvas, (love.graphics.getWidth() - gs.canvas:getWidth()) / 2
	, (love.graphics.getHeight() - gs.canvas:getHeight()) / 2)
end
