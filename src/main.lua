local colors = require("lib.modules.colors")
local vec = require("lib.modules.vector")
--local initLuis = require("luis.init")
--local luis = initLuis("luis/widgets")
--luis.flux = require("luis.3rdparty.flux")
serpent = require("lib.modules.serpent") ---@diagnostic disable-line
local lurker = require "lib.modules.lurker"
local gamestate = require("gamestate")
local ball = require("ball")
local weapon = require("weapon")
love.physics.setMeter(64)
effect = love.graphics.newShader("assets/shaders/perish.vert")
love.graphics.setBackgroundColor(colors.list["Off White"])

function love.load()
	gs = gamestate.new()
	player = ball.new()
	enemy = ball.new()
	wpn = weapon.new()
	wpn2 = weapon.new()
	gs:addBall(player, vec.new(20, 18))
	gs:addBall(enemy)
	player:addWeapon(wpn)
	enemy:addWeapon(wpn2)
	enemy.gs.body:applyLinearImpulse(100, 0)
	--gs:addBall(ball.new())
	player.gs.body:applyTorque(50000000)

	--player.gs.body:setLinearVelocity(200, 0)
end

local t = 0
function love.update(dt)
	lurker.update()
	t = t + dt
	--effect:send("time", t)
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

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(colors.list["Almost Black"])
	love.graphics.print("FPS: " .. love.timer.getFPS(), 40, 40)
	love.graphics.setLineWidth(2)
	gs:_draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")
	--love.graphics.draw(gs.canvas, (love.graphics.getWidth() - gs.canvas:getWidth()) / 2
	--, (love.graphics.getHeight() - gs.canvas:getHeight()) / 2)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key)
	if key == "r" then
		lurker.hotswapfile("main.lua")
	end
end
