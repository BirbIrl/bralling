local damageFont = love.graphics.newFont("assets/fonts/monocraft-birb-fix.ttf", 28)
local shaderWrapper = require("shaderWrapper")
local vec = require("lib.modules.vector")
local colors = require("lib.modules.colors")
local function ghettoTextWithOutline(text, font, x, y, lineWidth, align, r, sx, sy, strokeWidth, textColor, borderColor)
	love.graphics.setColor(borderColor)
	love.graphics.printf(text, font, x - strokeWidth, y, lineWidth, align, r, sx, sy)
	love.graphics.printf(text, font, x + strokeWidth, y, lineWidth, align, r, sx, sy)
	love.graphics.printf(text, font, x, y - strokeWidth, lineWidth, align, r, sx, sy)
	love.graphics.printf(text, font, x, y + strokeWidth, lineWidth, align, r, sy)
	love.graphics.setColor(textColor)
	love.graphics.printf(text, font, x, y, lineWidth, align, r, sx, sy)
end
return {
	new = function(color, radius)
		---@class Ball.lua
		local ball = {
			type = "ball",
			radius = radius or 32,
			health = 5,
			magneticPull = 70,
			maxSpeed = 1000,
			---@type Weapon.lua[]
			weapons = {},
			---@type ballGSHeader?
			gs = nil
		}
		if color then
			ball.color = color
		else
			ball.color = colors.keys[math.random(1, #colors.keys)]
		end
		print(ball.color)

		---adds the ball to a given gamestate, used by gamestate:addBall
		---@param gamestate Gamestate.lua
		---@param body love.Body
		---@param shape love.Shape
		---@param fixture love.Fixture
		function ball:_addToGame(gamestate, body, shape, fixture, id)
			---@class ballGSHeader
			self.gs = {
				id = id,
				parent = gamestate,
				body = body,
				shape = shape,
				fixture = fixture,
				damage = 0,
				dead = false,
				---@type ShaderWrapper.lua[]
				shaders = {},
				data = self,
			}
			function self.gs:isActive()
				---@diagnostic disable-next-line:need-check-nil
				return self.body:isActive()
			end

			function self.gs:setActive(boolean)
				---@diagnostic disable-next-line:need-check-nil
				self.body:setActive(boolean)
				for _, weapon in ipairs(self.data.weapons) do
					weapon.gs:setTangible(false)
				end
			end

			function self.gs:isDead()
				---@diagnostic disable-next-line:need-check-nil
				return self.dead
			end

			function self.gs:setDead(boolean)
				self.dead = boolean
			end

			function self.gs:getPos()
				---@diagnostic disable-next-line:need-check-nil
				return vec.new(self.body:getPosition())
			end

			---@param pos Vector.lua
			function self.gs:setPos(pos)
				---@diagnostic disable-next-line:need-check-nil
				self.body:setPosition(pos.x, pos.y)
			end

			function self.gs:getVelocity()
				---@diagnostic disable-next-line:need-check-nil
				return vec.new(self.body:getLinearVelocity())
			end

			---@param velocity Vector.lua
			function self.gs:setVelocity(velocity)
				---@diagnostic disable-next-line:need-check-nil
				self.body:setLinearVelocity(velocity.x, velocity.y)
			end

			function self.gs:getLinearVelocity()
				---@diagnostic disable-next-line:need-check-nil
				return vec.new(self.body:getLinearVelocity())
			end

			---@param pos Vector.lua
			---@return nil
			function self.gs:setLinearVelocity(pos)
				---@diagnostic disable-next-line:need-check-nil
				self.body:setLinearVelocity(pos.x, pos.y)
			end
		end

		function ball:deathHandler()
			local gs = self.gs
			if not gs or not self.gs:isDead() then return end
			local deathShader
			for _, shader in ipairs(self.gs.shaders) do
				if shader.type == "perish" then
					deathShader = shader
				end
			end
			if not deathShader then
				deathShader       = shaderWrapper.new("perish")
				local velocity    = self.gs:getVelocity()
				local impactPoint = self.gs:getPos() + (-velocity:clone():norm()) * self.radius * 1.5
				deathShader:send("velocity", { velocity.x, velocity.y })
				deathShader:send("impactPoint", { impactPoint.x, impactPoint.y })
				table.insert(self.gs.shaders, deathShader)
			end
			if deathShader:get("time") > deathShader:get("duration") then
				-- i shall find myself and die now :DD
				for index, targetBall in ipairs(gs.parent.balls) do
					if self == targetBall then
						table.remove(gs.parent.balls, index)
						gs.body:destroy()
						for _, weapon in ipairs(self.weapons) do
							weapon.gs.body:destroy()
							weapon.gs = nil
						end
						gs = nil
						break
					end
				end
			end
		end

		function ball:hit(damage)
			self.gs.damage = self.gs.damage + damage
			if self.gs.damage >= self.health then
				self.gs:setDead(true)
			end
		end

		---@param weapon Weapon.lua
		function ball:addWeapon(weapon)
			local weaponPos = self.gs:getPos()
			local body = love.physics.newBody(self.gs.parent.world, weaponPos.x, weaponPos.y, "dynamic")
			body:setUserData(weapon)
			local shape = love.physics.newRectangleShape(weapon.size.x / 2, weapon.size.y / 2, weapon.size.x,
				weapon.size.y)
			local fixture = love.physics.newFixture(body, shape, 1)
			fixture:setGroupIndex(-self.gs.id)
			fixture:setUserData(weapon)
			fixture:setMask(2)
			fixture:setCategory(2)
			--fixture:setSensor(true)
			weapon:_addToBall(self, body, shape, fixture)
			table.insert(self.weapons, weapon)
		end

		---@param target Ball.lua
		---@return Vector.lua
		function ball:getDistanceFromBall(target)
			if target then
				return target.gs:getPos() - self.gs:getPos()
			else
				return vec.new(0, 0)
			end
		end

		function ball:findClosestBall()
			local pos = self.gs:getPos()
			local cases = {}

			for _, candidate in ipairs(self.gs.parent.balls) do
				if candidate ~= self and candidate.gs:isActive() then
					table.insert(cases, { ball = candidate, diff = (pos - candidate.gs:getPos()):getmag() })
				end
			end

			table.sort(cases, function(a, b)
				return a.diff < b.diff
			end)

			if cases[1] then
				return cases[1].ball
			end
		end

		function ball:update(dt)
			self.gs.body:setAwake(true)
			if self.gs:isDead() then
				if self.gs:isActive() then
					self.gs:setActive(false)
				end
				self:deathHandler()
			else
				local velocity = self.gs:getLinearVelocity()

				velocity = velocity + self:getDistanceFromBall(self:findClosestBall()):norm() * self.magneticPull * dt

				-- cap out the velocity
				local max = self.maxSpeed
				if velocity.x > max then
					velocity.x = max
				end
				if velocity.y > max then
					velocity.y = max
				end

				self.gs:setLinearVelocity(velocity)
			end

			for _, weapon in ipairs(self.weapons) do
				if weapon.gs then
					weapon:update(dt)
				end
			end
			for _, shader in ipairs(self.gs.shaders) do
				shader:send("time", shader:get("time") + dt)
			end
		end

		function ball:_draw()
			love.graphics.setLineWidth(1)
			local oldCanvas = love.graphics.getCanvas()
			local canvas = love.graphics.newCanvas(self.gs.parent.size.x, self.gs.parent.size.y)
			love.graphics.setCanvas(canvas)
			love.graphics.push()
			love.graphics.translate(self.gs.body:getX(), self.gs.body:getY())
			love.graphics.setColor(colors.list[self.color])
			love.graphics.circle("fill", 0, 0, self.radius)
			love.graphics.setColor(colors.list["Almost Black"])
			love.graphics.circle("line", 0, 0, self.radius)
			love.graphics.setColor(colors.list["White"])
			local dmg = tostring(self.health - self.gs.damage)
			local textScale = 1
			if dmg:len() > 2 then
				print(dmg:len())
				textScale = 1 / ((dmg:len() - 1) / 2)
			end

			ghettoTextWithOutline(tostring(self.health - self.gs.damage), damageFont, -self.radius,
				-damageFont:getHeight() / 2 * textScale,
				self.radius * 2 / textScale, "center", 0, textScale, textScale, 2, colors.list["Off White"],
				colors.list["Almost Black"])

			love.graphics.setCanvas(oldCanvas)
			love.graphics.pop()
			--TODO make gooder, recursive
			if self.gs.shaders[1] then
				love.graphics.setShader(self.gs.shaders[1].shader)
			end
			love.graphics.draw(canvas)
			love.graphics.setShader()
		end

		return ball
	end
}
