script_name('Event.lua by Dashok.')
script_properties("Event.lua")
script_version('3.3')

-- Áèáëèîòåêè
require "lib.moonloader"
local ffi = require 'ffi'
local tag = "{E3294D}RDS Events: {FFFFFF}"
local ev = require 'samp.events'
local sampev = require 'lib.samp.events'
time = os.time()
local real_time = os.date("%c")
local dlstatus = require('moonloader').download_status

local encoding							= require "encoding"
encoding.default 						= "CP1251"
u8 										= encoding.UTF8

local inicfg = require "inicfg"
local memory = require "memory"
local imgui = require("imgui")
local vkeys	= require "lib.vkeys"
local window_mess = imgui.ImBool(false)
local sw, sh = getScreenResolution()


local mp_combo = imgui.ImInt(0)
local arr_mp = {u8"Ïðÿòêè íà êîðàáëå", u8"Ïðÿòêè", u8"Ðóññêàÿ Ðóëåòêà", u8"Êîðîëü Äèãëà", u8"Fall Guys", u8"UFC", u8"Derby", u8"Fly Jump"}
local arr_prise = {u8"Âèðòû", u8"Î÷êè", u8"Êîèíû", u8"Ðóáëè", u8"Ñòàíäàðò"}
local arr_minigun = {u8"Ïîïðîñèòü", u8"Âûäàòü ñåáå", u8"Âûäàòü äðóãîìó"}
local minigun_combo = imgui.ImInt(0)
local mp_prise = imgui.ImInt(0)
local prise_kol = imgui.ImBuffer(200)
local mp_win = imgui.ImBuffer(200)
local player_id, player_nick
local mp_rules = imgui.ImBool(false)
local noErrorDialog = false

-- imgui update
-- inicfg
local directIni	= "Event\\settings.ini"

local mainIni = inicfg.load({
  settings =
  {
    style = 0,
	Cheats = ""
  }

}, directIni) 

tServers = {
	'46.174.52.246', -- 01
        '46.174.55.87', -- 02
        '46.174.49.170', -- 03
        '46.174.55.169', -- 04
		"46.174.49.47", -- ðàçðàáîòêà
		"51.254.139.153",
		"80.66.82.191"
}



function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function setInterfaceStyle(id)
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	if id == 0 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(2, 0, 0, 230):GetVec4() -- 04
		colors[clr.FrameBg]     	          = imgui.ImColor(150, 10, 10, 100):GetVec4() -- 01
		colors[clr.FrameBgHovered]         = imgui.ImColor(150, 10, 10, 180):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(150, 10, 10, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(150, 20, 20, 235):GetVec4() -- 01
		colors[clr.TitleBgActive]          = imgui.ImColor(150, 20, 20, 235):GetVec4() -- 01
		colors[clr.Button]                 = imgui.ImColor(150, 10, 10, 235):GetVec4() -- 01
		colors[clr.ButtonHovered]          = imgui.ImColor(150, 10, 10, 180):GetVec4() -- 01
		colors[clr.ButtonActive]           = imgui.ImColor(120, 10, 10, 180):GetVec4() -- 01
	elseif id == 1 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(2, 1, 3, 230):GetVec4() -- 04
		colors[clr.FrameBg]    	 		  = imgui.ImColor(70, 21, 135, 100):GetVec4() -- 02
		colors[clr.FrameBgHovered]         = imgui.ImColor(70, 18, 115, 180):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(70, 21, 135, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.TitleBgActive]          = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.Button]                 = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.ButtonHovered]          = imgui.ImColor(70, 21, 135, 170):GetVec4() -- 02
		colors[clr.ButtonActive]           = imgui.ImColor(55, 18, 115, 170):GetVec4() -- 02
	elseif id == 2 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 2, 0, 230):GetVec4() -- 03
		colors[clr.FrameBg] 				   = ImVec4(0.2, 0.79, 0.14, 0.24) -- 03
		colors[clr.FrameBgHovered]         = ImVec4(0.2, 0.79, 0.14, 0.4)
		colors[clr.FrameBgActive]          = ImVec4(0.15, 0.59, 0.14, 0.39)
		colors[clr.TitleBg]                = ImVec4(0.05, 0.35, 0.05, 0.95) -- 03
		colors[clr.TitleBgActive]          = ImVec4(0.05, 0.35, 0.05, 0.95) -- 03
		colors[clr.Button]                 = ImVec4(0.2, 0.79, 0.14, 0.59) -- 03
		colors[clr.ButtonHovered]          = ImVec4(0.2, 0.79, 0.14, 0.4) -- 03
		colors[clr.ButtonActive]           = ImVec4(0.15, 0.59, 0.14, 0.39) -- 03
	elseif id == 3 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 1, 2, 230):GetVec4() -- 04
		colors[clr.FrameBg]    	 		  = imgui.ImColor(2, 182, 193, 100):GetVec4() -- 04
		colors[clr.FrameBgHovered]         = imgui.ImColor(0, 182, 193, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(0, 182, 193, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(0, 123, 135, 232):GetVec4() -- 04
		colors[clr.TitleBgActive]          = imgui.ImColor(0, 123, 138, 232):GetVec4() -- 04
		colors[clr.Button]                 = imgui.ImColor(0, 172, 183, 163):GetVec4() -- 04
		colors[clr.ButtonHovered]          = imgui.ImColor(0, 182, 193, 100):GetVec4() -- 04
		colors[clr.ButtonActive]           = imgui.ImColor(0, 122, 133, 100):GetVec4() -- 04
	elseif id == 4 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 0, 0, 230):GetVec4()
		colors[clr.FrameBg]    	 		  = imgui.ImColor(40, 40, 40, 100):GetVec4()
		colors[clr.FrameBgHovered]         = imgui.ImColor(95, 95, 95, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(95, 95, 95, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(7, 7, 7, 232):GetVec4()
		colors[clr.TitleBgActive]          = imgui.ImColor(7, 7, 7, 232):GetVec4()
		colors[clr.Button]                 = imgui.ImColor(30, 30, 30, 163):GetVec4()
		colors[clr.ButtonHovered]          = imgui.ImColor(95, 95, 95, 100):GetVec4()
		colors[clr.ButtonActive]           = imgui.ImColor(50, 50, 50, 100):GetVec4()
	elseif id == 5 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(3, 3, 0, 230):GetVec4()
		colors[clr.FrameBg]    	 		  = imgui.ImColor(210, 210, 0, 100):GetVec4()
		colors[clr.FrameBgHovered]         = imgui.ImColor(210, 210, 0, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(210, 210, 0, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(120, 120, 0, 232):GetVec4()
		colors[clr.TitleBgActive]          = imgui.ImColor(120, 120, 0, 232):GetVec4()
		colors[clr.Button]                 = imgui.ImColor(180, 180, 0, 163):GetVec4()
		colors[clr.ButtonHovered]          = imgui.ImColor(180, 180, 0, 100):GetVec4()
		colors[clr.ButtonActive]           = imgui.ImColor(100, 100, 0, 100):GetVec4()
	elseif id == 6 then
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 7 then
	 colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
      colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
      colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
      colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
      colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
      colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
      colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
      colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
      colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
      colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
      colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
      colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
      colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
      colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
      colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
      colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
      colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
      colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
      colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
      colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
      colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
      colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
      colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
      colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
      colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
      colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
      colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
      colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
      colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
      colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
      colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	  elseif id == 8 then
	  colors[clr.Text] = ImVec4(0.860, 0.930, 0.890, 0.78)
  colors[clr.TextDisabled] = ImVec4(0.860, 0.930, 0.890, 0.28)
  colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
  colors[clr.ChildWindowBg] = ImVec4(0.200, 0.220, 0.270, 0.58)
  colors[clr.PopupBg] = ImVec4(0.200, 0.220, 0.270, 0.9)
  colors[clr.Border] = ImVec4(0.31, 0.31, 1.00, 0.00)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
  colors[clr.FrameBgHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.FrameBgActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.TitleBg] = ImVec4(0.232, 0.201, 0.271, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.200, 0.220, 0.270, 0.75)
  colors[clr.MenuBarBg] = ImVec4(0.200, 0.220, 0.270, 0.47)
  colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
  colors[clr.ScrollbarGrab] = ImVec4(0.09, 0.15, 0.1, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.CheckMark] = ImVec4(0.71, 0.22, 0.27, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.47, 0.77, 0.83, 0.14)
  colors[clr.SliderGrabActive] = ImVec4(0.71, 0.22, 0.27, 1.00)
  colors[clr.Button] = ImVec4(0.47, 0.77, 0.83, 0.14)
  colors[clr.ButtonHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
  colors[clr.ButtonActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.Header] = ImVec4(0.455, 0.198, 0.301, 0.76)
  colors[clr.HeaderHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
  colors[clr.HeaderActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
  colors[clr.ResizeGrip] = ImVec4(0.47, 0.77, 0.83, 0.04)
  colors[clr.ResizeGripHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.ResizeGripActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.PlotLines] = ImVec4(0.860, 0.930, 0.890, 0.63)
  colors[clr.PlotLinesHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.860, 0.930, 0.890, 0.63)
  colors[clr.PlotHistogramHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.455, 0.198, 0.301, 0.43)
  colors[clr.ModalWindowDarkening] = ImVec4(0.200, 0.220, 0.270, 0.73)
  elseif id == 9 then
    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 0.95)
  colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
  colors[clr.ChildWindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
  colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.05, 0.94)
  colors[clr.Border] = ImVec4(0.53, 0.53, 0.53, 0.46)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.00, 0.00, 0.00, 0.85)
  colors[clr.FrameBgHovered] = ImVec4(0.22, 0.22, 0.22, 0.40)
  colors[clr.FrameBgActive] = ImVec4(0.16, 0.16, 0.16, 0.53)
  colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.MenuBarBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.48, 0.48, 0.48, 1.00)
  colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 0.99)
  colors[clr.CheckMark] = ImVec4(0.79, 0.79, 0.79, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.48, 0.47, 0.47, 0.91)
  colors[clr.SliderGrabActive] = ImVec4(0.56, 0.55, 0.55, 0.62)
  colors[clr.Button] = ImVec4(0.50, 0.50, 0.50, 0.63)
  colors[clr.ButtonHovered] = ImVec4(0.67, 0.67, 0.68, 0.63)
  colors[clr.ButtonActive] = ImVec4(0.26, 0.26, 0.26, 0.63)
  colors[clr.Header] = ImVec4(0.54, 0.54, 0.54, 0.58)
  colors[clr.HeaderHovered] = ImVec4(0.64, 0.65, 0.65, 0.80)
  colors[clr.HeaderActive] = ImVec4(0.25, 0.25, 0.25, 0.80)
  colors[clr.Separator] = ImVec4(0.58, 0.58, 0.58, 0.50)
  colors[clr.SeparatorHovered] = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.SeparatorActive] = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.ResizeGrip] = ImVec4(0.87, 0.87, 0.87, 0.53)
  colors[clr.ResizeGripHovered] = ImVec4(0.87, 0.87, 0.87, 0.74)
  colors[clr.ResizeGripActive] = ImVec4(0.87, 0.87, 0.87, 0.74)
  colors[clr.CloseButton] = ImVec4(0.45, 0.45, 0.45, 0.50)
  colors[clr.CloseButtonHovered] = ImVec4(0.70, 0.70, 0.90, 0.60)
  colors[clr.CloseButtonActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
  colors[clr.PlotLines] = ImVec4(0.68, 0.68, 0.68, 1.00)
  colors[clr.PlotLinesHovered] = ImVec4(0.68, 0.68, 0.68, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.90, 0.77, 0.33, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(0.87, 0.55, 0.08, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.47, 0.60, 0.76, 0.47)
  colors[clr.ModalWindowDarkening] = ImVec4(0.88, 0.88, 0.88, 0.35)
  elseif id == 10 then
    colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 11 then
	 colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
    colors[clr.Border]                 = ImVec4(0.73, 0.36, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
    colors[clr.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
    colors[clr.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
    colors[clr.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
    colors[clr.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
    colors[clr.CloseButton]            = colors[clr.FrameBg]
    colors[clr.CloseButtonHovered]     = colors[clr.FrameBgHovered]
    colors[clr.CloseButtonActive]      = colors[clr.FrameBgActive]
	elseif id == 12 then
	colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
	elseif id == 13 then
	 colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
    colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
    colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
    colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
    colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
    colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
    colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	elseif id == 14 then
	 colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.00, 0.00, 0.00, 0.94)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.26, 0.37, 0.98, 0.54)
    colors[clr.FrameBgHovered]       = ImVec4(0.33, 0.33, 0.93, 0.40)
    colors[clr.FrameBgActive]        = ImVec4(0.44, 0.44, 0.99, 0.67)
    colors[clr.TitleBg]              = ImVec4(0.30, 0.33, 0.95, 0.67)
    colors[clr.TitleBgActive]        = ImVec4(0.00, 0.16, 1.00, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.22, 0.19, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(0.39, 0.56, 1.00, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.30, 0.41, 0.99, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.52, 0.52, 0.97, 1.00)
    colors[clr.Button]               = ImVec4(0.11, 0.13, 0.93, 0.65)
    colors[clr.ButtonHovered]        = ImVec4(0.41, 0.57, 1.00, 0.65)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.Header]               = ImVec4(0.15, 0.19, 1.00, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.03, 0.24, 0.57, 0.65)
    colors[clr.HeaderActive]         = ImVec4(0.36, 0.40, 0.95, 0.00)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.20, 0.42, 0.98, 0.54)
    colors[clr.SeparatorActive]      = ImVec4(0.20, 0.40, 0.93, 0.54)
    colors[clr.ResizeGrip]           = ImVec4(0.01, 0.17, 1.00, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.21, 0.51, 0.98, 0.45)
    colors[clr.ResizeGripActive]     = ImVec4(0.04, 0.55, 0.95, 0.66)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.10, 0.21, 0.98, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.02, 0.26, 1.00, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(0.18, 0.15, 1.00, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 15 then
	 colors[clr.Text]                 = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.22, 0.22, 0.22, 1.00)
    colors[clr.WindowBg]             = ImVec4(1.00, 1.00, 1.00, 0.71)
    colors[clr.ChildWindowBg]        = ImVec4(0.92, 0.92, 0.92, 0.00)
    colors[clr.PopupBg]              = ImVec4(1.00, 1.00, 1.00, 0.94)
    colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
    colors[clr.BorderShadow]         = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.77, 0.49, 0.66, 0.54)
    colors[clr.FrameBgHovered]       = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.FrameBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.67)
    colors[clr.TitleBg]              = ImVec4(0.76, 0.51, 0.66, 0.71)
    colors[clr.TitleBgActive]        = ImVec4(0.97, 0.74, 0.88, 0.74)
    colors[clr.TitleBgCollapsed]     = ImVec4(1.00, 1.00, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(1.00, 1.00, 1.00, 0.54)
    colors[clr.ScrollbarBg]          = ImVec4(0.81, 0.81, 0.81, 0.54)
    colors[clr.ScrollbarGrab]        = ImVec4(0.78, 0.28, 0.58, 0.13)
    colors[clr.ScrollbarGrabHovered] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.Button]               = ImVec4(0.78, 0.28, 0.58, 0.54)
    colors[clr.ButtonHovered]        = ImVec4(0.77, 0.52, 0.67, 0.54)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.Header]               = ImVec4(0.78, 0.28, 0.58, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.78, 0.28, 0.58, 0.25)
    colors[clr.HeaderActive]         = ImVec4(0.79, 0.04, 0.48, 0.63)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.79, 0.44, 0.65, 0.64)
    colors[clr.SeparatorActive]      = ImVec4(0.79, 0.17, 0.54, 0.77)
    colors[clr.ResizeGrip]           = ImVec4(0.87, 0.36, 0.66, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.ResizeGripActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.76, 0.46, 0.64, 0.71)
    colors[clr.CloseButtonActive]    = ImVec4(0.78, 0.28, 0.58, 0.79)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 16 then
	   colors[clr.Text]                 = ImVec4(0.83, 0.83, 0.83, 1.00)
                colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.73, 1.00)
                colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
                colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
                colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
                colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
                colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
                colors[clr.FrameBg]              = ImVec4(0.43, 0.71, 0.39, 0.54)
                colors[clr.FrameBgHovered]       = ImVec4(0.66, 0.84, 0.66, 0.40)
                colors[clr.FrameBgActive]        = ImVec4(0.68, 0.84, 0.66, 0.67)
                colors[clr.TitleBg]              = ImVec4(0.24, 0.47, 0.22, 0.67)
                colors[clr.TitleBgActive]        = ImVec4(0.28, 0.47, 0.22, 1.00)
                colors[clr.TitleBgCollapsed]     = ImVec4(0.26, 0.47, 0.22, 0.67)
                colors[clr.MenuBarBg]            = ImVec4(0.18, 0.34, 0.16, 1.00)
                colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
                colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
                colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
                colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
                colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
                colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
                colors[clr.SliderGrab]           = ImVec4(0.45, 0.71, 0.39, 1.00)
                colors[clr.SliderGrabActive]     = ImVec4(0.70, 0.84, 0.66, 1.00)
                colors[clr.Button]               = ImVec4(0.27, 0.47, 0.22, 0.65)
                colors[clr.ButtonHovered]        = ImVec4(0.39, 0.71, 0.39, 0.65)
                colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
                colors[clr.Header]               = ImVec4(0.39, 0.71, 0.41, 0.54)
                colors[clr.HeaderHovered]        = ImVec4(0.68, 0.84, 0.66, 0.65)
                colors[clr.HeaderActive]         = ImVec4(0.66, 0.84, 0.66, 0.00)
                colors[clr.Separator]            = ImVec4(0.43, 0.50, 0.43, 0.50)
                colors[clr.SeparatorHovered]     = ImVec4(0.39, 0.71, 0.42, 0.54)
                colors[clr.SeparatorActive]      = ImVec4(0.43, 0.71, 0.39, 0.54)
                colors[clr.ResizeGrip]           = ImVec4(0.46, 0.71, 0.39, 0.54)
                colors[clr.ResizeGripHovered]    = ImVec4(0.66, 0.84, 0.66, 0.66)
                colors[clr.ResizeGripActive]     = ImVec4(0.67, 0.84, 0.66, 0.66)
                colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
                colors[clr.CloseButtonHovered]   = ImVec4(0.42, 0.98, 0.36, 1.00)
                colors[clr.CloseButtonActive]    = ImVec4(0.38, 0.98, 0.36, 1.00)
                colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
                colors[clr.PlotLinesHovered]     = ImVec4(0.52, 1.00, 0.35, 1.00)
                colors[clr.PlotHistogram]        = ImVec4(0.16, 0.90, 0.00, 1.00)
                colors[clr.PlotHistogramHovered] = ImVec4(0.13, 1.00, 0.00, 1.00)
                colors[clr.TextSelectedBg]       = ImVec4(0.30, 0.98, 0.26, 0.35)
                colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
				elseif id == 17 then
				 colors[clr.FrameBg]                = ImVec4(0.76, 0.6, 0, 0.74)--
    colors[clr.FrameBgHovered]         = ImVec4(0.84, 0.68, 0, 0.83)--
    colors[clr.FrameBgActive]          = ImVec4(0.92, 0.77, 0, 0.87)--
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)--
    colors[clr.TitleBgActive]          = ImVec4(0.92, 0.77, 0, 0.85)--
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)--
    colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Button]                 = ImVec4(0.76, 0.6, 0, 0.85)
    colors[clr.ButtonHovered]          = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Header]                 = ImVec4(0.84, 0.68, 0, 0.75)
    colors[clr.HeaderHovered]          = ImVec4(0.84, 0.68, 0, 0.90)
    colors[clr.HeaderActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.84, 0.68, 0, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.76, 0.6, 0, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.84, 0.68, 0, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.92, 0.77, 0, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.52, 0.34, 0, 0.85)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 18 then
	 colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.MenuBarBg]            = ImVec4(0.12, 0.05, 0.06, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.ScrollbarGrab]        = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.Button]               = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.Header]               = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(1.00, 0.15, 0.29, 0.75)
    colors[clr.HeaderActive]         = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.Separator]            = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 19 then
	 colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
    colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
    colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
    colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
end
setInterfaceStyle(mainIni.settings.style)

local styles = {u8"Êðàñíûé", u8"Ôèîëåòîâûé", u8"Çåëåíûé", u8"Ãîëóáîé", u8"×åðíûé", u8"Æåëòûé", u8"Ñèíèé", u8"Ñåðàÿ", u8"Âèøíåâàÿ", u8"Ñâåòëî-Ñåðàÿ", u8"Òåìíî-Îðàíæåâàÿ", u8"Îðàíæåâàÿ", u8"Òåìíî-Êðàñíàÿ", u8"Òåìíî-Çåëåíàÿ", u8"ßðêî-Ñèíÿÿ", u8"Ðîçîâàÿ", u8"Òåìíî-Çåëåíàÿ 2", u8"Æåòëàÿ 2", u8"ßðêî-Êðàñíàÿ", u8"Ïóðïóðíàÿ"}
local cmd = ""
local give_minigun = ""

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

local arr_plaers = {u8""}
local combo_players = imgui.ImInt(0)  
 

function imgui.Help(text)
    imgui.TextDisabled(u8'(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

local upd = [[
27.05.2021 | 1.0 | Ðåëèç ñêðèïòà.

1.Ãîòîâûå ñîîáùåíèÿ äëÿ /mess
2.Ïàíåëü äëÿ ïðîâåäåíèÿ ìåðîïðèÿòèé
3.Ðàáîòà òîëüêî íà ñåðâåðàõ RDS


28.05.2021 | 1.2 | Ìèíè îáíîâëåíèå

1.Êíîïêà èñïðàâèòü îøèáêè
2.Ôèñê ìåëêèõ îøèáîê
3.Ðàáîòà òîëüêî íà ñåðâåðàõ ÐÄÑ


15.06.2021 | 1.4 | Ãëîáàëüíîå îáíîâëåíèå

1.Ïîëíîñòüþ ïåðåïèñàíî ìåíþ ñêðèïòà
2.Äîáàâëåíà ñèñòåìà àâòîîáíîâëåíèÿ
3.Èçìåíåíèå ñòèëÿ imgui


16.06.2021 | 1.6 | Îáíîâëåíèå

1.Äîáàâëåíî íîâîå ìåðîïðèÿòèå "Fly Jump"
2.Ôèêñ ìåëêèõ îøèáîê
3.Äîáàâëåíû ïðàâèëà äëÿ ÌÏ


26.06.2021 | 2.0 | Îáíîâëåíèå

1.Äîáàâëåíà ñèñòåìà inicfg äëÿ ñîõðàíåíèÿ ôàéëîâ
2.Äîáàâëåíà ôóíêöèÿ èçìåíåíèÿ ñòèëÿ ñêðèïòà


26.06.2021 | 2.2 + 2.4 | Îáíîâëåíèå

1.Äîáàâëåíà íîâàÿ ïðîâåðêà îáíîâëíèÿ
2.Ôèêñ áàãîâ

26.06.2021 | 2.6 + 2.8 + 2.9 | Îáíîâëåíèå

1.Äîáàâëåíà êó÷à íîâûé ñòèëåé imgui
2.Äîáàâëåíà âêëàäêà íàñòðîéêè
3.Äîáàâëåíà ôóíêöèÿ ñáðîñà íàñòðîåê
4.Â ìåíþ Èíôîðìàöèÿ äîáàâëåíà êíîïêà äëÿ íàïèñàíèÿ èäåé ïî ñêðïòó

29.06.2021 | 3.0 | Global Update

1.Äîáàâëåíà ôóíêöèÿ ïîêðàñêè òåêñòà
2.Äîáàâëåíà âêëàäêà õàðàêòåðèñòèêè ÏÊ
3.Äîáàâëåíà èíôîðìàöèÿ î ôàéëàõ
4.Äîáàâëåíà ôóíêöèÿ âûçûâàíèÿ îêíà îøèáêè windows
5.Äîáàâëåíà êíîïêà ïîëíîé î÷èñòêè ÷àòà
6.Äîáàâëåí äèàëîã ïðè çàâåðøåíèè ðàáîòû ñêðèïòà

11.07.2021 | 3.2 | Updane

1.Óáðàíî îêíî ïðîâåðêè îáíîâëåíèÿ
2.Èçìåíåíà ñèñòåìà âûáîðÿ ñòèëÿ
]]



rules = false

local checked_radio_style = imgui.ImInt(mainIni.settings.style)
check_upd = true

function imgui.OnDrawFrame()
   if window_mess.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"RDS Events 3.2 | Nick: "..sampGetPlayerNickname(id).. " | Id: "..id, window_mess)
	
	
	imgui.BeginChild('##Select Setting', imgui.ImVec2(sw/8.4, sh/2.79), true)
        if imgui.Selectable(u8"Èñï. ÏÎ", beginchild == 1) then beginchild = 1 end
        if imgui.Selectable(u8"Ñïàâò ÒÑ", beginchild == 2) then beginchild = 2 end
        if imgui.Selectable(u8"Æá íà Àäì", beginchild == 3) then beginchild = 3 end
        if imgui.Selectable(u8"Öåíòð.Ðûíîê", beginchild == 4) then beginchild = 4 end
		imgui.Separator()
        if imgui.Selectable(u8"Ìåðîïðèÿòèÿ", beginchild == 5) then beginchild = 5 end
        if imgui.Selectable(u8"Èíôîðìàöèÿ", beginchild == 6) then beginchild = 6 end
        if imgui.Selectable(u8"Ëîã îáíîâëåíèé", beginchild == 7) then beginchild = 7 end
       
        if imgui.Selectable(u8"Ñìåíà ñòèëÿ", beginchild == 9) then beginchild = 9 end
      
       imgui.Separator()
		
		if imgui.Button(u8"Rld") then
			imgui.ShowCursor = false
			sampAddChatMessage(tag .. "Ñêðèïò ïåðåçàãðóæàåòñÿ.")
			thisScript():reload()
		end
	imgui.SameLine()
	if imgui.Button(u8"Off") then
			lua_thread.create(function ()
			imgui.Process = false
			wait(200)
			imgui.ShowCursor = false
		thisScript():unload()
	end)
end


if imgui.Button(u8"Chng set") then
mainIni.settings.style = 0
mainIni.settings.Cheats = ""
save()
thisScript():reload()
end


imgui.SameLine() 
if imgui.Button(u8"Clear CH") then
ClearChat()
end
		
		if check_upd then
if imgui.Button("Check UPD") then
update()
check_upd = false
end
end
        imgui.EndChild()
		imgui.SameLine()
		
		if beginchild == 1 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================= Èíôîðìàöèÿ =================')
		imgui.Text(u8'Íà ñåðâåðå çàïðåùåíû Ñòîðîííèå Ïðîãðàììû.')
		imgui.Text(u8'Êîòîðûå äàþò ïðåèìóùåñòâà íàä èãðîêàìè.')
		imgui.Text(u8'Åñëè âû çàìåòèòå èãðîêà ñî Ñòîðîííèìè Ïðîãðàììàìè.')
		imgui.Text(u8'Ïèøèòå àäìèíèñòðàòîðàì:"/report id ïðè÷èíà"')
		imgui.Text(u8'================= Èíôîðìàöèÿ =================')
		if imgui.Button(u8"Îòïðàâèòü", btn_size) then
		sampSendChat("/mess 12 ================= Èíôîðìàöèÿ =================")
		sampSendChat("/mess 6 Íà ñåðâåðå çàïðåùåíû Ñòîðîííèå Ïðîãðàììû.")
		sampSendChat("/mess 6 Êîòîðûå äàþò ïðåèìóùåñòâà íàä èãðîêàìè.")
		sampSendChat("/mess 6 Åñëè âû çàìåòèòå èãðîêà ñî Ñòîðîííèìè Ïðîãðàììàìè.")
		sampSendChat("/mess 6 Ïèøèòå àäìèíèñòðàòîðàì:'/report id ïðè÷èíà' ")
		sampSendChat("/mess 12 ================= Èíôîðìàöèÿ =================")
		window_mess.v = false
		imgui.Process = false
		end
		
		imgui.EndChild()
		end
		
		if beginchild == 2 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================= Ðåñïàâí Àâòî ==========')
		imgui.Text(u8'Óâàæàåìûå èãðîêè, ÷åðåç 15 ñåêóíä áóäåò ïðîèçâåäåí.')
		imgui.Text(u8'Ðåñïàâí Òðàíñïîðòíîãî ñðåäñòâà, ÷òîáû íå ïîòåðÿòü åãî.')
		imgui.Text(u8'Çàéìèòå Âîäèòåëüñêîå/Ïàññàæèðñêîå ìåñòî')
		imgui.Text(u8'Ïðèÿòíîé èãðû íà Russian Drift Server.')
		imgui.Text(u8'================= Ðåñïàâí Àâòî ===============')
		if imgui.Button(u8"Îòïðàâèòü", btn_size) then
		sampSendChat("/mess 12 ====================== Ðåñïàâí Àâòî ========================")
		sampSendChat("/mess 6 Óâàæàåìûå èãðîêè, ÷åðåç 15 ñåêóíä áóäåò ïðîèçâåäåí.")
		sampSendChat("/mess 6 Ðåñïàâí Òðàíñïîðòíîãî ñðåäñòâà, ÷òîáû íå ïîòåðÿòü åãî.")
		sampSendChat("/mess 6 Çàéìèòå Âîäèòåëüñêîå/Ïàññàæèðñêîå ìåñòî")
		sampSendChat("/spawncars 15")
		sampSendChat("/delcarall")
		sampSendChat("/mess 12 ====================== Ðåñïàâí Àâòî ========================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.EndChild()
		end
        

		if beginchild == 3 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================== Èíôîðìàöèÿ ==================')
		imgui.Text(u8'Íå ñîãëàñíû ñ íàêàçàíèå êàêîãî-òî àäìèíèñòðàòîðà ?')
		imgui.Text(u8'Âû ìîæåòå ïîäàòü æàëîáó íà íåãî, ëèáî ðàçáëîêèðîâêó.')
		imgui.Text(u8'Ïðîñòî ïåðåéäèòå â íóæíîå îáñóæäåíèå ïî ññûëêå íèæå.')
		imgui.Text(u8'Ãðóïïà: "https://vk.com/dmdriftgta".')
		imgui.Text(u8'============== Íåâåðíîå íàêàçàíèå ===============')
		if imgui.Button(u8"Îòïðàâèòü", btn_size) then
		sampSendChat("/mess 12 ================== Èíôîðìàöèÿ ==================")
		sampSendChat("/mess 6 Íå ñîãëàñíû ñ íàêàçàíèå êàêîãî-òî àäìèíèñòðàòîðà?")
		sampSendChat("/mess 6 Âû ìîæåòå ïîäàòü æàëîáó íà íåãî, ëèáî ðàçáëîêèðîâêó.")
		sampSendChat("/mess 6 Ïðîñòî ïåðåéäèòå â íóæíîå îáñóæäåíèå ïî ññûëêå íèæå.")
		sampSendChat("/mess 6 Ãðóïïà: https://vk.com/dmdriftgta")
		sampSendChat("/mess 12 ============== Íåâåðíîå íàêàçàíèå ===============")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.EndChild()
		end
		
		
		if beginchild == 4 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'===================== Èíôîðìàöèÿ =====================')
		imgui.Text(u8'Æåëàåòå ïðèîáðåñòè àêñåññóàð çà Âèðòû/Î÷êè/Êîèíû/Ðóáëè?')
		imgui.Text(u8'Äîáðî ïîæàëîâàòü íà ðûíîê, ïî êîìàíäå: "/trade"')
		imgui.Text(u8'Òàê æå, ïîäîéäÿ ê NPC, ìîæíî îáìåíÿòü âàëþòû. ')
		imgui.Text(u8'Íî ó÷òèòå... Íå íóæíî âðåäèòü èãðîêàì.')
		imgui.Text(u8'================= Ðûíîê/Îáìåí âàëþò ==================')
		if imgui.Button(u8"Îòïðàâèòü", btn_size) then
		sampSendChat("/mess 12 ===================== Èíôîðìàöèÿ =====================")
		sampSendChat("/mess 6 Æåëàåòå ïðèîáðåñòè àêñåññóàð çà Âèðòû/Î÷êè/Êîèíû/Ðóáëè?")
		sampSendChat("/mess 6 Äîáðî ïîæàëîâàòü íà ðûíîê, ïî êîìàíäå: /trade")
		sampSendChat("/mess 6 Òàê æå, ïîäîéäÿ ê NPC, ìîæíî îáìåíÿòü âàëþòû.")
		sampSendChat("/mess 6 Íî ó÷òèòå... Íå íóæíî âðåäèòü èãðîêàì.")
		sampSendChat("/mess 12 ================= Ðûíîê/Îáìåí âàëþò ==================")
		window_mess.v = false
		imgui.Process = false
		end
	imgui.EndChild()
		end
		
		
		if beginchild == 5 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 local x, y, z = getCharCoordinates(playerPed)
         local str_cords = string.format("%.2f, %.2f, %.2f", x, y, z)
		
		imgui.Text(u8'Ïîçèöèÿ èãðîêà: '..str_cords)
		imgui.Text(u8'Âûáåðèòå ìåðîïðèÿòèå: ')
		imgui.SameLine()
		imgui.PushItemWidth(150)
		imgui.Combo(u8'', mp_combo, arr_mp, #arr_mp)
		
		imgui.Text(u8"Âûáåðèòå òèï ïðèçà è ââåäèòå åãî êîëè÷åñòâî: ")
		if imgui.Combo(u8"##Prise", mp_prise, arr_prise, #arr_prise) then
		if mp_prise.v == 0 then
		cmd = "/agivemoney"
		prise = "Âèðò"
		end
		if mp_prise.v == 1 then
		cmd = "/givescore"
		prise = "Score"
		end
		if mp_prise.v == 2 then
		cmd = "/givecoin"
		prise = "RDS Coins"
		end
		if mp_prise.v == 3 then
		cmd = "/giverub"
		prise = "Donate Rub"
		end
		if mp_prise.v == 4 then
		cmd = "/mpwin"
		prise_kol.v = ""
		prise = "Ñòàíäàðòíûé"
		end
		end
		imgui.SameLine()
		imgui.InputText("##PriseKol", prise_kol)
		imgui.SameLine()
		imgui.Checkbox(u8"Ïðàâèëà ÌÏ", mp_rules)
		
		
		if imgui.Button(u8"Íà÷àòü ÌÏ") then
		window_mess.v = false
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		sampSendChat("/mess 14 Ïðîõîäèò ÌåðîÏðèÿòèå ".. u8:decode(arr_mp[mp_combo.v + 1]))
		sampSendChat("/mess 14 Òåëåïîðò áóäåò îòêðûò ðîâíî 60 ñåêóíä")
		sampSendChat("/mess 14 Ïðèç äëÿ ïîáåäèòåëÿ: "..prise_kol.v.." "..prise)
		sampSendChat("/mp")
        sampSendDialogResponse(5343, 1, 0)
		wait(500)
		sampSendDialogResponse(5344, 1, _, u8:decode(arr_mp[mp_combo.v + 1]))
		wait(500)
		sampCloseCurrentDialogWithButton(0)
		sampSendChat('/mess 14 ×òîáû ïîïàñòü íà ÌåðîÏðèÿòèå ñëåäóåò ïðîïèñàòü "/tpmp"')
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		local v = 60
		for i=1, 60 do
		v = v - 1
		printString('~p~ '..v, 1000)
		wait(1000)
		end
		sampSendChat('/mess 14 Âðåìÿ íà òåëåïîðò âûøëî.')
		wait(1000)
		sampSendChat('/mess 14 Çàêðûâàþ òåëåïîðò')
		wait(500)
		sampSendChat("/mp")
		wait(500)
		sampSendDialogResponse(5343, 1, 0)
		wait(300)
		sampCloseCurrentDialogWithButton(1)
		wait(3000)
		if mp_rules.v then

sampSendChat("/mess 10 Íà ìåðîïðèÿòèè çàïðåùàþòñÿ ñëåäóþùèå äåéñòâèÿ:")
sampSendChat("/mess 10 Èñïîëüçîâàíèå /heal /s /r /passive, à òàêæå ÄÌ")
sampSendChat("/mess 10 Çà íàðóøåíèå ëþáîãî èç âñåãî âûøåñêàçàííîãî")
sampSendChat("/mess 10 Âû áóäåòå íàêàçàíû. Æåëàþ ïîáåäèòü â Ìåðîïðèÿòèè")
		end
		window_mess.v = false
		end)
		end
		imgui.SameLine()
		if imgui.Button(u8"Çàêîí÷èòü ÌÏ") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		wait(50)
		sampSendChat("/mess 14 Ïîáåäèòåëü ìåðîïðèÿòèÿ ".. u8:decode(arr_mp[mp_combo.v + 1]))
		wait(50)
	    sampSendChat("/mess 14 Ñòàíîâèòñÿ èãðîê: " .. sampGetPlayerNickname(mp_win.v).. "["..mp_win.v.."]")
		wait(50)
	    sampSendChat("/mess 14 Ïîçäðàâëÿåì")
		wait(50)
		sampSendChat(cmd.." "..mp_win.v.." "..prise_kol.v)
		wait(50)
		sampSendChat("/aspawn "..mp_win.v)
		wait(50)
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		sampSendChat("/tweap "..id)
		window_mess.v = false
		end)
		end
		imgui.SameLine()
		imgui.PushItemWidth(140)
		if imgui.Combo(u8"Minigun", minigun_combo, arr_minigun, #arr_minigun) then
		if minigun_combo.v == 0 then
		sampSendChat("/a /setweap ".. id .." 38 4000")
		end
		if minigun_combo.v == 1 then
		sampSendChat("/setweap " .. id .. " 38 4000")
		end
		if minigun_combo.v == 2 then
		give_minigun = "/setweap id 38 4000"
		lua_thread.create(function()
		setVirtualKeyDown(117, true)
        wait(300) -- çàäåðæêà íà ñåêóíäó
        setVirtualKeyDown(117, false)
        sampSetChatInputText(give_minigun)
		end)
		end
		end
		
		
		imgui.Text("")
		imgui.Text(u8"Ââåäèòå ID ïîáåäèòåëÿ: ")
		imgui.SameLine()
		imgui.InputText("##123123123123", mp_win)
	
		
		imgui.EndChild()
		end
		
		if beginchild == 6 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		  imgui.CenterText(u8''..script.this.name.. " | "..script.this.version)
		  

		  
		 if imgui.Button(u8"Ãðóïïà ñêðèïòà") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/coding.lua_yamada"))
end
		  
		 if imgui.Button(u8"Àâòîð ñêðèïòà") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/scr_vrd"))
end

 if imgui.Button(u8"Ïîääåðæàòü ðàçðàáîòêó ñêðèïòà") then
    os.execute(('explorer.exe "%s"'):format("https://www.donationalerts.com/r/dashok_"))
end

 if imgui.Button(u8"Íàïèñàòü èäåþ äëÿ ðàçðàáîòêè ñêðèïòà") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/topic-197475953_47698647"))
end
		 
		 

 imgui.Text(u8'Åñëè âàø Nick èëè âàø Id íå ñîîòâåòñòâóþò îðèãèíàëüíîìó... \n ...òî íàæìèòå íà êíîïêó "Ïåðåçàãðóçèòü" âî âêëàäêå "Íàñòðîéêè"')		 

		
		imgui.EndChild()
		end
		
		if beginchild == 7 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 imgui.TextWrapped(u8(upd))
		imgui.EndChild()
		end
		
		
		
		if beginchild == 9 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 imgui.CenterText(u8"Âûáåðèòå íóæíûé âàì ñòèëü")
		 
		 
for i=1, 19 do
			if i~=6 and i ~=12 and i~=18 then
				if imgui.RadioButton('ST '..i, checked_radio_style, i) then
				mainIni.settings.style = checked_radio_style.v
			   setInterfaceStyle(mainIni.settings.style)
			   save()
				end
				imgui.SameLine()
			else
				if imgui.RadioButton('ST '..i, checked_radio_style, i) then
				mainIni.settings.style = checked_radio_style.v
			setInterfaceStyle(mainIni.settings.style)
			save()
				end
			end
		end
		
		
		imgui.EndChild()
		end
		
		imgui.End()
	end
	
end




function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        if not sampIsDialogActive() then
            showCursor(false, false)
        end
  
        if not noErrorDialog then
        	sampShowDialog(131313, "{E3294D}[ Event ] Ñêðèïò çàâåðøèë ñâîþ ðàáîòó", [[
{E3294D}                                                           ×òî äåëàòü åñëè íå ðàáîòàåò ñêðèïò?{FFC973}

1. Ñêðèïò äîëæåí áûòü óñòàíîâëåí ñòðîãî ïî èíñòðóêöèè.
 - Äàæå åñëè ó âàñ ðàíåå áûëè óñòàíîâëåíû êàêèå-òî ôàéëû âû äîëæíû èõ îáÿçàòåëüíî çàìåíèòü.

2. Åñëè âû óñòàíàâèëè è çàïóñòèëè ñêðèïò âïåðâûå, òî ñêîðåå âñåãî îí ïðîñòî ñêà÷àë
 íóæíûå åìó áèáëèîòåêè. Îò âàñ ëèø òðåáóåòñÿ íàæàòü CTRL + R, â 90 ïðîöåíòàõ ñëó÷àÿõ
 ýòî ïîìîãàåò

3. Åñëè ó âàñ óñòàíîâëåí MVD Helper, òî âàì íóæíî åãî óäàëèòü, îí èñïîëüçóåò ñòàðóþ
 âåðñèþ MonnLoader 0.25, à äàííûé ñêðèïò ðàáîòàåò íà ïîñëåäíåé ñòàáèëüíîé âåðñèè 0.26
 Óäàëèòå MVD Helper è ïîâòîðîíî óñòàíîâèòå Bank Helper

4. Âîçìîæíî ó âàñ óñòàíîâëåíû êîíôëèêòóþùèå ïðîãðàììû
 - Àíòè-ñòèëëåðû
 - Àíòè-âèðóñû
 - Ôàéëû Samp Addon
 - Äðóãèå LUA/CLEO/SF/ASI

5. Äëÿ ðàáîòû ñêðèïòà íóæíû ñëåäóþùèå ôàéëû:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26
 - Áèáëèîòåêè (lib)

6. Åñëè äàííûé ñêðèïò ðàáîòàë ðàíåå è âäðóã ïîÿâèëàñü ýòà îøèáêà, òî ïîïðîáóéòå óäàëèòü íàñòðîéêè
- Â ïàïêå moonloader > Óäàëÿåì ïàïêó Config
- Â ïàïêå moonloader > Óäàëÿåì ïàïêó Event

7. Åñëè äàííûå äåéñòâèÿ íå ïîìîãëè, òî ïîïðîáóéòå óñòàíîâèòü ñêðèïò íà äðóãóþ ñáîðêó
]], "Ïîíÿë", _, 0)
        	setClipboardText('')
	    end
    end
end

function ClearChat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

ffi = require 'ffi'
ffi.cdef[[
typedef uint32_t DWORD;

typedef union _ULARGE_INTEGER {
  struct {
    DWORD LowPart;
    DWORD HighPart;
  };
  struct {
    DWORD LowPart;
    DWORD HighPart;
  } u;
  unsigned __int64 QuadPart;
} ULARGE_INTEGER, *PULARGE_INTEGER;

bool __stdcall GetDiskFreeSpaceExA(
  char* lpDirectoryName,
  int lpFreeBytesAvailable,
  int lpTotalNumberOfBytes,
  int lpTotalNumberOfFreeBytes
);
]]

function save()
inicfg.save(mainIni, directIni)
end


function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)

end

function reload()
reloadScripts()
end



function main()
	 if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

	result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	 id_player = sampGetPlayerIdByCharHandle(PLAYER_PED)
	
	imgui.Process = false
	edit = false
	
	sampfuncsRegisterConsoleCommand("reloadscripts", reload) --registering sf console command
	
	imgui.ShowCursor = false
   sampAddChatMessage(tag .. "Èäåò ïðîâåðêà ñåðâåðà.")
	wait(1000)
	  if not checkServer(select(1, sampGetCurrentServerAddress())) then
		sampAddChatMessage(tag .. "Ñêðèïò ðàáîòàåò òîëüêî íà ñåðâåðàõ RDS!")
		wait(1000)
		thisScript():unload()
	end
	 wait(1000)
	if not doesDirectoryExist(getWorkingDirectory() .. "/config") then
       sampAddChatMessage(tag .. "Ó âàñ îòñóòñòâóåò ïàïêà config, ñîçäàþ ïàïêó.")
		createDirectory(getWorkingDirectory() .. "/config")
		wait(600)
		sampAddChatMessage(tag .. "Ïàïêà ñîçäàíà.")
end
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/Event") then
	    sampAddChatMessage(tag .. "Ñîçäàþ ïàïêó Event")
		createDirectory(getWorkingDirectory() .. "/config/Event")
		wait(300)
		 sampAddChatMessage(tag .. "Ïàïêà Event ñîçäàíà.")
	end
	
	
	



f = io.open(getGameDirectory().."//moonloader//config//Event//PO.txt","r+");
if f == nil then 
      -- Ñîçäàåò ôàéë â ðåæèìå "çàïèñè"
      f = io.open(getGameDirectory().."//moonloader//config//Event//PO.txt","w"); 
	  sampAddChatMessage(tag .. "Îòñóòñòâóåò ôàéë PO, ñîçäàþ ôàéë.")
      -- Çàêðûâàåò ôàéë
      f:close();
   end;
  

	
	
	 sampRegisterChatCommand('event', function() 
	 window_mess.v = not window_mess.v
	 end)
     

	
	lua_thread.create(function()
	while true do
		wait(0)
	
	
   imgui.Process = window_mess.v
	
	
	end
	
	
	end)
end

function update()
  local fpath = os.getenv('TEMP') .. '\\testing_version.json' -- êóäà áóäåò êà÷àòüñÿ íàø ôàéëèê äëÿ ñðàâíåíèÿ âåðñèè
  downloadUrlToFile('https://raw.githubusercontent.com/Vrednaya1234/Scripts-SAMP/main/update.json', fpath, function(id, status, p1, p2) -- ññûëêó íà âàø ãèòõàá ãäå åñòü ñòðî÷êè êîòîðûå ÿ ââ¸ë â òåìå èëè ëþáîé äðóãîé ñàéò
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    local f = io.open(fpath, 'r') -- îòêðûâàåò ôàéë
    if f then
      local info = decodeJson(f:read('*a')) -- ÷èòàåò
      updatelink = info.updateurl
      if info and info.latest then
        version = tonumber(info.latest) -- ïåðåâîäèò âåðñèþ â ÷èñëî
        if version > tonumber(thisScript().version) then -- åñëè âåðñèÿ áîëüøå ÷åì âåðñèÿ óñòàíîâëåííàÿ òî...
          lua_thread.create(goupdate) -- àïäåéò
        else -- åñëè ìåíüøå, òî
          update = false -- íå äà¸ì îáíîâèòüñÿ 
          sampAddChatMessage(tag ..'Ó âàñ è òàê ïîñëåäíÿÿ âåðñèÿ ñêðèïòà! Îòìåíÿþ îáíîâëåíèå.')
        end
      end
    end
  end
end)
end
--ñêà÷èâàíèå àêòóàëüíîé âåðñèè
function goupdate()
sampAddChatMessage(tag ..'Îáíàðóæåíî íîâîå îáíîâëåíèå. Îáíîâëÿþñü...')
sampAddChatMessage(tag ..'Òåêóùàÿ âåðñèÿ: '..thisScript().version.." Íîâàÿ âåðñèÿ: "..version)
wait(3000)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- êà÷àåò âàø ôàéëèê ñ latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  wait(3000)
  sampAddChatMessage(tag ..'Îáíîâëåíèå çàâåðøåíî! Îçíàêîìèòñÿ ñ íèì ìîæíî â ìåíþ ñêðèïòà: /event > Ëîã îáíîâëåíèé')
  wait(4000)
  thisScript():reload()
end
end)
end

function ShowMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end
