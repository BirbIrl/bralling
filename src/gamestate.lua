local colors = require("lib.modules.colors")
local vec = require("lib.modules.vector")
local wallThickness = 500
return {
	new = function()
		---@class Gamestate.lua
		local gamestate = {
			size = vec.new(500, 500),
			lineWidth = 6,
		}

		function gamestate:updateCollission()
			self.walls = {
				body = love.physics.newBody(gamestate.world, 0, 0),
				shapes = {
					top = love.physics.newRectangleShape(self.size.x / 2, -wallThickness / 2,
						self.size.x + wallThickness * 2, wallThickness),
					bottom = love.physics.newRectangleShape(self.size.x / 2, self.size.y + wallThickness / 2,
						self.size.x + wallThickness * 2, wallThickness),
					left = love.physics.newRectangleShape(-wallThickness / 2, self.size.y / 2, wallThickness, self.size
						.y),
					right = love.physics.newRectangleShape(wallThickness / 2 + self.size.x, self.size.y / 2,
						wallThickness, self.size.y),
				},
				---@type love.Fixture[]
				fixtures = {
				},
			}
			for dir, shape in pairs(self.walls.shapes) do
				local fixture = love.physics.newFixture(self.walls.body, shape)
				fixture:setMask()
				self.walls.fixtures[dir] = fixture
			end
		end

		gamestate.world = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)
		gamestate.canvas = love.graphics.newCanvas(
			gamestate.size.x + gamestate.lineWidth, gamestate.size.y + gamestate.lineWidth
		)
		gamestate:updateCollission()
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
			local body = love.physics.newBody(self.world, pos.x, pos.y, "dynamic")
			body:setLinearDamping(0)
			local shape = love.physics.newCircleShape(ball.radius)
			local fixture = love.physics.newFixture(body, shape)
			fixture:setRestitution(1.25)
			ball:_addToGame(self, body, shape, fixture)
			table.insert(self.balls, ball)
		end

		function gamestate:update(dt)
			self.world:update(dt)
			for _, ball in ipairs(self.balls) do
				ball:update(dt)
			end
		end

		function gamestate:_draw()
			love.graphics.translate(self.lineWidth / 2, self.lineWidth / 2)
			love.graphics.setLineWidth(self.lineWidth)
			love.graphics.setColor(colors["Almost Black"])
			love.graphics.rectangle("line", 0 - self.lineWidth / 2, 0 - self.lineWidth / 2, self.size.x + self.lineWidth,
				self.size.y + self.lineWidth)
			for _, ball in ipairs(self.balls) do
				ball:_draw()
				--[[
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("fill", ball.gs.body:getX(), ball.gs.body:getY(), 5, 5)
				--]]
			end
			love.graphics.translate(0, 0)
		end

		return gamestate
	end
}
