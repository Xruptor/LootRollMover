local _G = _G
local type = type
local setmetatable = setmetatable

local _, private = ...
if type(private) ~= "table" then
	private = {}
end

local function NormalizeLocale(loc)
	if loc == "enGB" then
		return "enUS"
	end
	return loc or "enUS"
end

local GetLocale = _G.GetLocale
local current = NormalizeLocale(type(GetLocale) == "function" and GetLocale())

private._locales = private._locales or {
	current = current,
	default = nil,
	locales = {},
	merged = nil,
}
private._locales.current = current

function private:NewLocale(locale, isDefault)
	if type(locale) ~= "string" or locale == "" then return nil end
	local store = private._locales

	if isDefault then
		store.default = store.default or {}
		store.merged = nil
		return store.default
	end

	if locale ~= store.current then
		return nil
	end

	store.locales[locale] = store.locales[locale] or {}
	store.merged = nil
	return store.locales[locale]
end

function private:GetLocale()
	local store = private._locales
	local L = store.locales[store.current] or store.default or {}
	if not store.default or L == store.default then
		return L
	end
	if store.merged ~= L then
		store.merged = setmetatable(L, { __index = store.default })
	end
	return store.merged
end

private.L = private.L or setmetatable({}, {
	__index = function(_, key)
		return (private:GetLocale() or {})[key]
	end,
})
