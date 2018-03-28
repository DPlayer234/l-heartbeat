--[[
Entity following the mouse
]]
local currentModule = miscMod.getModule(..., false)

local colors = require "libs.colors"
local Vector2 = require "Engine.Vector2"

local SelectionBox = require(currentModule .. ".selection_box")

local UserController = class("UserController", require "Engine.ECS.Entity")

local color = {
	neutral = colors.new(255, 255, 255, 255),
	lmb = colors.new(0, 255, 255, 255),
	rmb = colors.new(255, 0, 255, 255),
	mmb = colors.new(255, 255, 0, 255)
}

local releaseCallbacks

function UserController:initialize()
	self.down = {}
	self.held = {}

	self.selection = {}
end

function UserController:update()
	self.transform.position = self.ecs.transformation:inverseApplyPoint(Vector2(love.mouse.getPosition()))

	-- Mouse state
	for i=1, 3 do
		self.down[i] = love.mouse.isDown(i) and not self.held[i]
		self.held[i] = love.mouse.isDown(i)

		if self.down[i] then
			self.selection[i] = self:addComponent(SelectionBox())
			self.selection[i].callback = releaseCallbacks[i]
		elseif self.selection[i] and not self.held[i] then
			self.selection[i]:destroy()
			self.selection[i] = nil
		end
	end

	self.color = self.held[1] and color.lmb or self.held[2] and color.rmb or self.held[3] and color.mmb or color.neutral
end

function UserController:draw()
	love.graphics.setColor(self.color)

	local x, y = self.transform.position:unpack()
	love.graphics.points(x, y)

	love.graphics.printf(("%.0f, %.0f"):format(x, y), x - 1000, y, 1000, "right")
end

releaseCallbacks = {
	[1] = function(fixture)
		print(fixture)
	end
}

return UserController
