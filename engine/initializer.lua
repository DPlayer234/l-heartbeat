--[[
Initializes the engine
]]
local currentModule = miscMod.getModule(..., false)
local currentPath   = miscMod.getPath(..., false)

local EventStore = require "libs.event_store"

-- Class used to initialize and load everything
local Initializer = class("Initializer")

-- Creates a new Initializer
function Initializer:new(engine)
	self.engine = engine
end

-- Loads all entities into the engine's entities field
function Initializer:loadEntities()
	self:_loadClasses(self.engine._entities, currentPath .. "/entities")
end

-- Loads all components into the engine's components field
function Initializer:loadComponents()
	self:_loadClasses(self.engine._components, currentPath .. "/components")
end

-- Loads classes into a table from a certain directory
function Initializer:_loadClasses(into, directory)
	for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
		local fullPath = directory .. "/" .. item
		if love.filesystem.isDirectory(fullPath) then
			-- Load subdirectory
			into[item] = {}
			self:_loadClasses(into[item], fullPath)
		elseif (item:find("%.lua$")) then
			-- Loads the Lua file and stores the class
			local loaded = require(fullPath:gsub("%.lua$", ""):gsub("[/\\]", "."))
			if not class.isClass(loaded) then error(fullPath .. " does not return a class.") end
			into[loaded.NAME] = loaded
		end
	end
end

return Initializer
