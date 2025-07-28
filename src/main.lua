local colors = require("lib.modules.colors")
local vec = require("lib.modules.vector")
--local initLuis = require("luis.init")
--local luis = initLuis("luis/widgets")
--luis.flux = require("luis.3rdparty.flux")
serpent = require("lib.modules.serpent") ---@diagnostic disable-line
local gamestate = require("gamestate")
local ball = require("ball")
local weapon = require("weapon")

love.physics.setMeter(64)


local gs = gamestate.new()
local player = ball.new()
local enemy = ball.new()
local wpn = weapon.new()
local wpn2 = weapon.new()
function love.load()
	love.graphics.setBackgroundColor(colors.list["Off White"])
	gs:addBall(player, vec.new(20, 18))
	gs:addBall(enemy)
	enemy.gs.body:applyLinearImpulse(100, 0)
	--gs:addBall(ball.new())
	player.gs.body:applyTorque(50000000)

	--player.gs.body:setLinearVelocity(200, 0)
end

local weaponcnt = 0
function love.update(dt)
	if weaponcnt then
		weaponcnt = weaponcnt + dt
		if weaponcnt > 1 then
			player:addWeapon(wpn)
			enemy:addWeapon(wpn2)
			weaponcnt = nil
		end
	end
	if love.keyboard.isDown("up") then
		player.gs:setPos(player.gs:getPos() + vec.new(0, -5.0)) -- Move up
	end
	if love.keyboard.isDown("down") then
		player.gs:setPos(player.gs:getPos() + vec.new(0, 5.0)) -- Move down
	end
	if love.keyboard.isDown("left") then
		player.gs:setPos(player.gs:getPos() + vec.new(-5.0, 0)) -- Move left
	end
	if love.keyboard.isDown("right") then
		player.gs:setPos(player.gs:getPos() + vec.new(5.0, 0)) -- Move right
	end

	gs:update(dt)
end

function love.draw()
	love.graphics.setCanvas(gs.canvas)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.clear()
	love.graphics.setLineWidth(2)
	gs:_draw()
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(gs.canvas, (love.graphics.getWidth() - gs.canvas:getWidth()) / 2
	, (love.graphics.getHeight() - gs.canvas:getHeight()) / 2)
end
