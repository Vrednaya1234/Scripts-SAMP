script_name('Event')
script_properties("Event.lua")
script_version('1.2')

-- Áèáëèîòåêè
require "lib.moonloader"
local tag = "{E3294D}RDS Events: {FFFFFF}"
local ev = require 'samp.events'
local sampev = require 'lib.samp.events'
local time = 11000
local real_time = os.date("%c")

local encoding							= require "encoding"
encoding.default 						= "CP1251"
u8 										= encoding.UTF8

local script_author = "Dashok."
local script_version = "Âåðñèÿ ñêðèïòà: 1.2"

local inicfg = require "inicfg"
local memory = require "memory"
local imgui = require("imgui")
local vkeys	= require "lib.vkeys"
local window_mess = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local mp_combo = imgui.ImInt(0)
local arr_mp = {u8"Ïðÿòêè íà êîðàáëå", u8"Ïðÿòêè", u8"Ðóññêàÿ Ðóëåòêà", u8"Êîðîëü Äèãëà", u8"Fall Guys", u8"UFC"}
local arr_prise = {u8"Âèðòû", u8"Î÷êè", u8"Êîèíû", u8"Ðóáëè", u8"Ñòàíäàðò"}
local arr_minigun = {u8"Ïîïðîñèòü", u8"Âûäàòü ñåáå", u8"Âûäàòü äðóãîìó"}
local minigun_combo = imgui.ImInt(0)
local mp_prise = imgui.ImInt(0)
local prise_kol = imgui.ImBuffer(200)
local mp_win = imgui.ImBuffer(200)
local player_id, player_nick

local mainIni = inicfg.load({
    config =
    {
        qx = 0,
        qy= 0
    }
}, 'Event_Set.ini')


tServers = {
	'46.174.52.246', -- 01
        '46.174.55.87', -- 02
        '46.174.49.170', -- 03
        '46.174.55.169', -- 04
		"46.174.49.47" -- ðàçðàáîòêà
}

function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage(tag .. '[Mono Tools]{FFFFFF} Äîñòóïíî íîâîå îáíîâëåíèå! Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Ñêðèïò óñïåøíî îáíîâë¸í.')
					  sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Îçíàêîìèòüñÿ ñî âñåìè îáíîâëåíèÿìè âû ñìîæåòå â Ìåíþ ñêðèïòà.')
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Íå óäàëîñü îáíîâèòü ñêðèïò! Îáðàòèòåñü ê àâòîðó ñêðèïòà.')
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
            end
          end
        else
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end


function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 8.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.ChildWindowRounding = 8.0
	style.FrameRounding = 8.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 8.0
	style.GrabMinSize = 8.0
	style.GrabRounding = 8.0
	-- style.Alpha =
	-- style.WindowPadding =
	-- style.WindowMinSize =
	-- style.FramePadding =
	-- style.ItemInnerSpacing =
	-- style.TouchExtraPadding =
	-- style.IndentSpacing =
	-- style.ColumnsMinSpacing = ?
	-- style.ButtonTextAlign =
	-- style.DisplayWindowPadding =
	-- style.DisplaySafeAreaPadding =
	-- style.AntiAliasedLines =
	-- style.AntiAliasedShapes =
	-- style.CurveTessellationTol =

	 colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
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
end
apply_custom_style()

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

function imgui.OnDrawFrame()
   if window_mess.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2.5, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"RDS Events", window_mess)
		
		imgui.CenterText(u8"Âàø Nick: " .. sampGetPlayerNickname(id))
		imgui.CenterText(u8"Âàø ID: " .. id)
	
	imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Òåêñò êíîïêè").x) / 2)
	if imgui.Button(u8"Èñïðàâèòü áàãè") then
		thisScript():reload()
	end
	imgui.SameLine()
	imgui.Help(u8"Åñëè èíôîðìàöèÿ î âàñ íå êîððåêòíàÿ, ñëåäóåò íàæàòü íà äàííóþ êíîïêó")
		if imgui.CollapsingHeader(u8"Ñòîðîííèå Ïðîãðàììû") then
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
		imgui.Separator()
		end
        
			if imgui.CollapsingHeader(u8"Ñïàâí Òðàíñïîðòà") then
		imgui.Text(u8'====================== Ðåñïàâí Àâòî ========================')
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
		imgui.Separator()
		end
		
		if imgui.CollapsingHeader(u8"Æàëîáà íà Àäìèíèñòðàöèþ") then
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
		imgui.Separator()
		end
		
		if imgui.CollapsingHeader(u8"Öåíòðàëüíûé Ðûíîê") then
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
		imgui.Separator()
		end
		 local x, y, z = getCharCoordinates(playerPed)
         local str_cords = string.format("%.2f, %.2f, %.2f", x, y, z)
		if imgui.CollapsingHeader(u8"Ìåðîïðèÿòèÿ") then
		imgui.Text(u8'Ïîçèöèÿ èãðîêà: '..str_cords)
		imgui.Text(u8'Âûáåðèòå ìåðîïðèÿòèå: ')
		imgui.SameLine()
		imgui.PushItemWidth(190)
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
		
		if imgui.Button(u8"Íà÷àòü ÌÏ") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		sampSendChat("/mess 14 Ïðîõîäèò ÌåðîÏðèÿòèå ".. u8:decode(arr_mp[mp_combo.v + 1]))
		sampSendChat("/mess 14 Òåëåïîðò áóäåò îòêðûò ðîâíî 60 ñåêóíä")
		sampSendChat("/mess 14 Ïðèç äëÿ ïîáåäèòåëÿ: "..prise_kol.v.." "..prise)
		sampSendChat("/mp")
        sampSendDialogResponse(5343, 1, 0)
		wait(900)
		sampSendDialogResponse(5344, 1, _, u8:decode(arr_mp[mp_combo.v + 1]))
		wait(900)
		sampSendDialogResponse(1)
		sampSendChat('/mess 14 ×òîáû ïîïàñòü íà ÌåðîÏðèÿòèå ñëåäóåò ïðîïèñàòü "/tpmp"')
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		window_mess.v = false
		local v = 60
		for i=1, 60 do
		v = v - 1
		printString('~g~ '..v, 1000)
		wait(1000)
		end
		sampSendChat('/mess 14 Âðåìÿ íà òåëåïîðò âûøëî.')
		wait(1000)
		sampSendChat('/mess 14 Çàêðûâàþ òåëåïîðò')
		wait(500)
		sampSendChat("/mp")
		wait(700)
		sampSendDialogResponse(5343, 1, 0)
		window_mess.v = false
		end)
		end
		imgui.SameLine()
		if imgui.Button(u8"Çàêîí÷èòü ÌÏ è âûäàòü ïðèç") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ÌåðîÏðèÿòèå =====================")
		wait(50)
		sampSendChat("/mess 14 Ïîáåäèòåëü ìåðîïðèÿòèÿ ".. u8:decode(arr_mp[mp_combo.v + 1]))
		wait(50)
	    sampSendChat("/mess 14 Ñòàíîâèòñÿ èãðîê: " .. sampGetPlayerNickname(mp_win.v))
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
	
		
		end
		
		imgui.End()
	end
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
	
	sampfuncsRegisterConsoleCommand("reloadscripts", reload) --registering sf console command
	
	sampAddChatMessage("NEEEEEEEEEEEEEEEEEEEEEEEEEEEEEW", -1)
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
	sampAddChatMessage(tag .. "Ñêðèïò ãîòîâ ê ðàáîòå!")
	sampAddChatMessage(tag .. "Àâòîð ñêðèïòà: " .. script_author)
	sampAddChatMessage(tag .. "Âåðñèÿ ñêðèïòà: " .. script_version)
	

	
	 sampRegisterChatCommand('event', function() 
	 window_mess.v = not window_mess.v
	 end)
     imgui.Process = false

 sampRegisterChatCommand("save_set", function()
 inicfg.save(config, directIni)
 end)
	
	config = inicfg.load(defTable, directIni)
	
	lua_thread.create(function()
	while true do
		wait(0)
	


   imgui.Process = window_mess.v
	
	
	end
	end)
end
