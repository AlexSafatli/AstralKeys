local ADDON_NAME, addon = ...

ASTRAL_KEYS = 'Astral Keys'
ASTRAL_GUILD = 'Astral'
ASTRAL_INFO = ASTRAL_GUILD .. ' - Area 52 (US)'

LibStub('AceAddon-3.0'):NewAddon(addon, ADDON_NAME, 'AceConsole-3.0')

addon.icon = LibStub('LibDBIcon-1.0')

addon.CLIENT_VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, 'Version')

addon.Modules = {}
addon.ModulesOptions = {}
addon.mod = {}

addon.refreshTime = 0

ASTRAL_KEYS_REFRESH_INTERVAL = 30 -- seconds

function addon.mod:Event(event, ...)
	return self[event](self, ...)
end

do
	local function mod_LoadOptions(this)
		this:SetScript('OnShow', nil)
		if this.Load then
			this:Load()
		end
		this.Load = nil
		this.isLoaded = true
	end

	function addon:New(moduleName, title, leadProtected, inParty, disabled)
		if addon.A[moduleName] then
			return false
		end
		local m = {}
		for k,v in pairs(addon.mod) do m[k] = v end

		m.options = addon.Options:Add(moduleName, title, leadProtected, inParty, disabled)
		m.options:Hide()
		m.options.moduleName = moduleName
		m.options.name = title or moduleName
		m.options:SetScript('OnShow', mod_LoadOptions)
		addon.ModulesOptions[#addon.ModulesOptions + 1] = m.options

		m.main = CreateFrame('FRAME', nil)
		m.main.events = {}
		m.main:SetScript('OnEvent', addon.mod.Event)

		m.name = moduleName
		table.insert(addon.Modules, m)
		addon.A[moduleName] = m

		return m
	end
end

-- TODO
local DEFAULT_SETTINGS = {
	profile = {

	},
	global = {
		general = {
			debug = { isEnabled = false, showAllMenus = false },
			show_minimap_button = true,
			font = { name = 'PT Sans Narrow', size = 72 },
			sounds = { channel = 'Master' }
		},
		wa = { required = {} },
		addons = { required = {} },
		texts = {
			position = { x = 0, y = 400 },
			reminders = { inRaid = true, inParty = false, outsideInstances = false, enable = true },
			alerts = { outsideInstances = false, enable = true },
			enabled = {},
			sounds = {},
		},
		notifiers = {
			general = { isEnabled = false, toConsole = true, toOfficer = false, toRaid = false },
			instances = {},
			encounters = {},
		},
		earlypull = {
			general = { isEnabled = false, printResults = true },
			announce = { onlyGuild = false, earlyPull = 1, onTimePull = 1, latePull = 1, untimedPull = 1 },
		},
		readycheck = {
			severedstrands = { enable = false },
		},
	}
}

function addon.Console(...)
    print(WrapTextInColorCode('[' .. ADDON_NAME .. ']', 'fff5e4a8'), ...)
end

function addon.PrintDebug(...)
    if addon.Debug then
        addon.Console(WrapTextInColorCode('D', 'C1E1C1FF'), ...)
    end
end

local uiScale, mult

function addon:SetUIScale()
	local scale = string.match(GetCVar('gxWindowedResolution'), "%d+x(%d+)")
	uiScale = UIParent:GetScale()
	mult = 768/scale/uiScale
end

function addon:Scale(x)
	return mult * floor(x/mult+.5)
end

-- TODO
function addon:OnInitialize()
	-- TODO: NEED?
	self.db = LibStub('AceDB-3.0'):New('AstralKeysDB', DEFAULT_SETTINGS)

	-- Shim layer to back the AstralKeySettings object with the global DB
	AstralKeySettings = self.db.global

	--AstralKeySettings.general.debug.isEnabled = true
	addon.Debug = AstralKeySettings.general.debug.isEnabled

	if addon.Debug then addon.PrintDebug('ADDON_LOADED') end
end