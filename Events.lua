script_name('Event.lua by Dashok.')
script_properties("Event.lua")
script_version('2.4')

-- Áèáëèîòåêè
require "lib.moonloader"
local tag = "{E3294D}RDS Events: {FFFFFF}"
local ev = require 'samp.events'
local sampev = require 'lib.samp.events'
local time = 11000
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

-- imgui update
local window_update = imgui.ImBool(false)
-- inicfg
local directIni	= "Event\\settings.ini"

local mainIni = inicfg.load({
  settings =
  {
    style = 0
  }

}, directIni) 

tServers = {
	'46.174.52.246', -- 01
        '46.174.55.87', -- 02
        '46.174.49.170', -- 03
        '46.174.55.169', -- 04
		"46.174.49.47" -- ðàçðàáîòêà
}

local style = imgui.ImInt(mainIni.settings.style)

function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
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
	end
end
setInterfaceStyle(mainIni.settings.style)

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


27.06.2021 | 2.2 + 2.4 | Îáíîâëåíèå

1.Äîáàâëåíà íîâàÿ ïðîâåðêà îáíîâëíèÿ
2.Ôèêñ áàãîâ


]]



rules = false

local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- âìåñòî 30 ëþáîé íóæíûé ðàçìåð
    end
end

text_update = ""

function imgui.OnDrawFrame()
   if window_mess.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"RDS Events 2.4 | Nick: "..sampGetPlayerNickname(id).. " | Id: "..id, window_mess)
	
	
	imgui.BeginChild('##Select Setting', imgui.ImVec2(sw/8.4, sh/2.79), true)
        if imgui.Selectable(u8"Èñï. ÏÎ", beginchild == 1) then beginchild = 1 end
        if imgui.Selectable(u8"Ñïàâò ÒÑ", beginchild == 2) then beginchild = 2 end
        if imgui.Selectable(u8"Æá íà Àäì", beginchild == 3) then beginchild = 3 end
        if imgui.Selectable(u8"Öåíòð.Ðûíîê", beginchild == 4) then beginchild = 4 end
		imgui.Separator()
        if imgui.Selectable(u8"Ìåðîïðèÿòèÿ", beginchild == 5) then beginchild = 5 end
        if imgui.Selectable(u8"Èíôîðìàöèÿ", beginchild == 6) then beginchild = 6 end
        if imgui.Selectable(u8"Ëîã îáíîâëåíèé", beginchild == 7) then beginchild = 7 end
	
		
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
    os.execute(('explorer.exe "%s"'):format("https://clck.ru/VWCuJ"))
end
		 
 imgui.Text(u8'Åñëè âàø Nick èëè âàø Id íå ñîîòâåòñòâóþò îðèãèíàëüíîìó... \n ...òî íàæìèòå íà êíîïêó "Ïåðåçàãðóçèòü"')		 
if imgui.Button(u8"Îòêëþ÷èòü") then
			lua_thread.create(function ()
			imgui.Process = false
			wait(200)
			imgui.ShowCursor = false
		thisScript():unload()
	end)
end
imgui.SameLine()
if imgui.Button(u8"Ïåðåçàãðóçèòü") then
			imgui.ShowCursor = false
			sampAddChatMessage(tag .. "Ñêðèïò ïåðåçàãðóæàåòñÿ.")
			thisScript():reload()
		end

imgui.PushItemWidth(130)
local styles = {u8"Êðàñíûé", u8"Ôèîëåòîâûé", u8"Çåëåíûé", u8"Ãîëóáîé", u8"×åðíûé", u8"Æåëòûé"}
if imgui.Combo(u8"Style Edit", style, styles) then
			mainIni.settings.style = style.v
			setInterfaceStyle(mainIni.settings.style)
			inicfg.save(mainIni, directIni)
		end
		
		
		imgui.EndChild()
		end
		
		if beginchild == 7 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 imgui.TextWrapped(u8(upd))
		imgui.EndChild()
		end
		imgui.End()
	end
	
	
	if window_update.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Ïðîâåðêà îáíîâëåíèÿ", window_update)
		 imgui.PushFont(fontsize)
        imgui.CenterText(u8"Èäåò ïðîâåðêà îáíîâëåíèÿ.")
		imgui.Separator()
		imgui.CenterText(u8(text_update))
    imgui.PopFont()
	end
	imgui.End()
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
	
	window_update.v = true
	text_update = "Ïðîâåðêà..."
	func_update()
	
	
	
	 sampRegisterChatCommand('event', function() 
	 window_mess.v = not window_mess.v
	 end)
     

	
	lua_thread.create(function()
	while true do
		wait(0)
	
	
   imgui.Process = window_mess.v or window_update.v
	
	
	end
	
	
	end)
end

function func_update()
lua_thread.create(function()
wait(3000)
update()
wait(6000)
window_update.v = false
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
          text_update = 'Ó âàñ è òàê ïîñëåäíÿÿ âåðñèÿ ñêðèïòà!\nÎòìåíÿþ îáíîâëåíèå.'
        end
      end
    end
  end
end)
end
--ñêà÷èâàíèå àêòóàëüíîé âåðñèè
function goupdate()
text_update = 'Îáíàðóæåíî íîâîå îáíîâëåíèå. Îáíîâëÿþñü...\n Òåêóùàÿ âåðñèÿ: '..thisScript().version..". Íîâàÿ âåðñèÿ: "..version
wait(3000)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- êà÷àåò âàø ôàéëèê ñ latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  wait(3000)
  text_update = 'Îáíîâëåíèå çàâåðøåíî! Îçíàêîìèòñÿ ñ íèì ìîæíî â ìåíþ ñêðèïòà.'
  wait(3000)
  thisScript():reload()
end
end)
end
