script_name('Event.lua by Dashok.')
script_properties("Event.lua")
script_version('2.0')

-- ����������
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
local arr_mp = {u8"������ �� �������", u8"������", u8"������� �������", u8"������ �����", u8"Fall Guys", u8"UFC", u8"Derby", u8"Fly Jump"}
local arr_prise = {u8"�����", u8"����", u8"�����", u8"�����", u8"��������"}
local arr_minigun = {u8"���������", u8"������ ����", u8"������ �������"}
local minigun_combo = imgui.ImInt(0)
local mp_prise = imgui.ImInt(0)
local prise_kol = imgui.ImBuffer(200)
local mp_win = imgui.ImBuffer(200)
local player_id, player_nick
local mp_rules = imgui.ImBool(false)

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
		"46.174.49.47" -- ����������
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
27.05.2021 | 1.0 | ����� �������.

1.������� ��������� ��� /mess
2.������ ��� ���������� �����������
3.������ ������ �� �������� RDS


28.05.2021 | 1.2 | ���� ����������

1.������ ��������� ������
2.���� ������ ������
3.������ ������ �� �������� ���


15.06.2021 | 1.4 | ���������� ����������

1.��������� ���������� ���� �������
2.��������� ������� ��������������
3.��������� ����� imgui


16.06.2021 | 1.6 | ����������

1.��������� ����� ����������� "Fly Jump"
2.���� ������ ������
3.��������� ������� ��� ��


26.06.2021 | 2.0 | ����������

1.��������� ������� inicfg ��� ���������� ������
2.��������� ������� ��������� ����� �������

]]



rules = false

function imgui.OnDrawFrame()
   if window_mess.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"RDS Events 2.0 | Nick: "..sampGetPlayerNickname(id).. " | Id: "..id, window_mess)
	
	
	imgui.BeginChild('##Select Setting', imgui.ImVec2(sw/8.4, sh/2.79), true)
        if imgui.Selectable(u8"���. ��", beginchild == 1) then beginchild = 1 end
        if imgui.Selectable(u8"����� ��", beginchild == 2) then beginchild = 2 end
        if imgui.Selectable(u8"�� �� ���", beginchild == 3) then beginchild = 3 end
        if imgui.Selectable(u8"�����.�����", beginchild == 4) then beginchild = 4 end
		imgui.Separator()
        if imgui.Selectable(u8"�����������", beginchild == 5) then beginchild = 5 end
        if imgui.Selectable(u8"����������", beginchild == 6) then beginchild = 6 end
        if imgui.Selectable(u8"��� ����������", beginchild == 7) then beginchild = 7 end
	
		
        imgui.EndChild()
		imgui.SameLine()
		
		if beginchild == 1 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================= ���������� =================')
		imgui.Text(u8'�� ������� ��������� ��������� ���������.')
		imgui.Text(u8'������� ���� ������������ ��� ��������.')
		imgui.Text(u8'���� �� �������� ������ �� ���������� �����������.')
		imgui.Text(u8'������ ���������������:"/report id �������"')
		imgui.Text(u8'================= ���������� =================')
		if imgui.Button(u8"���������", btn_size) then
		sampSendChat("/mess 12 ================= ���������� =================")
		sampSendChat("/mess 6 �� ������� ��������� ��������� ���������.")
		sampSendChat("/mess 6 ������� ���� ������������ ��� ��������.")
		sampSendChat("/mess 6 ���� �� �������� ������ �� ���������� �����������.")
		sampSendChat("/mess 6 ������ ���������������:'/report id �������' ")
		sampSendChat("/mess 12 ================= ���������� =================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.EndChild()
		end
		
		if beginchild == 2 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================= ������� ���� ==========')
		imgui.Text(u8'��������� ������, ����� 15 ������ ����� ����������.')
		imgui.Text(u8'������� ������������� ��������, ����� �� �������� ���.')
		imgui.Text(u8'������� ������������/������������ �����')
		imgui.Text(u8'�������� ���� �� Russian Drift Server.')
		imgui.Text(u8'================= ������� ���� ===============')
		if imgui.Button(u8"���������", btn_size) then
		sampSendChat("/mess 12 ====================== ������� ���� ========================")
		sampSendChat("/mess 6 ��������� ������, ����� 15 ������ ����� ����������.")
		sampSendChat("/mess 6 ������� ������������� ��������, ����� �� �������� ���.")
		sampSendChat("/mess 6 ������� ������������/������������ �����")
		sampSendChat("/spawncars 15")
		sampSendChat("/delcarall")
		sampSendChat("/mess 12 ====================== ������� ���� ========================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.EndChild()
		end
        

		if beginchild == 3 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'================== ���������� ==================')
		imgui.Text(u8'�� �������� � ��������� ������-�� �������������� ?')
		imgui.Text(u8'�� ������ ������ ������ �� ����, ���� �������������.')
		imgui.Text(u8'������ ��������� � ������ ���������� �� ������ ����.')
		imgui.Text(u8'������: "https://vk.com/dmdriftgta".')
		imgui.Text(u8'============== �������� ��������� ===============')
		if imgui.Button(u8"���������", btn_size) then
		sampSendChat("/mess 12 ================== ���������� ==================")
		sampSendChat("/mess 6 �� �������� � ��������� ������-�� ��������������?")
		sampSendChat("/mess 6 �� ������ ������ ������ �� ����, ���� �������������.")
		sampSendChat("/mess 6 ������ ��������� � ������ ���������� �� ������ ����.")
		sampSendChat("/mess 6 ������: https://vk.com/dmdriftgta")
		sampSendChat("/mess 12 ============== �������� ��������� ===============")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.EndChild()
		end
		
		
		if beginchild == 4 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		imgui.Text(u8'===================== ���������� =====================')
		imgui.Text(u8'������� ���������� ��������� �� �����/����/�����/�����?')
		imgui.Text(u8'����� ���������� �� �����, �� �������: "/trade"')
		imgui.Text(u8'��� ��, ������� � NPC, ����� �������� ������. ')
		imgui.Text(u8'�� ������... �� ����� ������� �������.')
		imgui.Text(u8'================= �����/����� ����� ==================')
		if imgui.Button(u8"���������", btn_size) then
		sampSendChat("/mess 12 ===================== ���������� =====================")
		sampSendChat("/mess 6 ������� ���������� ��������� �� �����/����/�����/�����?")
		sampSendChat("/mess 6 ����� ���������� �� �����, �� �������: /trade")
		sampSendChat("/mess 6 ��� ��, ������� � NPC, ����� �������� ������.")
		sampSendChat("/mess 6 �� ������... �� ����� ������� �������.")
		sampSendChat("/mess 12 ================= �����/����� ����� ==================")
		window_mess.v = false
		imgui.Process = false
		end
	imgui.EndChild()
		end
		
		
		if beginchild == 5 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 local x, y, z = getCharCoordinates(playerPed)
         local str_cords = string.format("%.2f, %.2f, %.2f", x, y, z)
		
		imgui.Text(u8'������� ������: '..str_cords)
		imgui.Text(u8'�������� �����������: ')
		imgui.SameLine()
		imgui.PushItemWidth(150)
		imgui.Combo(u8'', mp_combo, arr_mp, #arr_mp)
		
		imgui.Text(u8"�������� ��� ����� � ������� ��� ����������: ")
		if imgui.Combo(u8"##Prise", mp_prise, arr_prise, #arr_prise) then
		if mp_prise.v == 0 then
		cmd = "/agivemoney"
		prise = "����"
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
		prise = "�����������"
		end
		end
		imgui.SameLine()
		imgui.InputText("##PriseKol", prise_kol)
		imgui.SameLine()
		imgui.Checkbox(u8"������� ��", mp_rules)
		
		
		if imgui.Button(u8"������ ��") then
		window_mess.v = false
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ����������� =====================")
		sampSendChat("/mess 14 �������� ����������� ".. u8:decode(arr_mp[mp_combo.v + 1]))
		sampSendChat("/mess 14 �������� ����� ������ ����� 60 ������")
		sampSendChat("/mess 14 ���� ��� ����������: "..prise_kol.v.." "..prise)
		sampSendChat("/mp")
        sampSendDialogResponse(5343, 1, 0)
		wait(500)
		sampSendDialogResponse(5344, 1, _, u8:decode(arr_mp[mp_combo.v + 1]))
		wait(500)
		sampCloseCurrentDialogWithButton(0)
		sampSendChat('/mess 14 ����� ������� �� ����������� ������� ��������� "/tpmp"')
		sampSendChat("/mess 13 ===================== ����������� =====================")
		local v = 60
		for i=1, 60 do
		v = v - 1
		printString('~p~ '..v, 1000)
		wait(1000)
		end
		sampSendChat('/mess 14 ����� �� �������� �����.')
		wait(1000)
		sampSendChat('/mess 14 �������� ��������')
		wait(500)
		sampSendChat("/mp")
		wait(500)
		sampSendDialogResponse(5343, 1, 0)
		wait(300)
		sampCloseCurrentDialogWithButton(1)
		wait(3000)
		if mp_rules.v then

sampSendChat("/mess 10 �� ����������� ����������� ��������� ��������:")
sampSendChat("/mess 10 ������������� /heal /s /r /passive, � ����� ��")
sampSendChat("/mess 10 �� ��������� ������ �� ����� ��������������")
sampSendChat("/mess 10 �� ������ ��������. ����� �������� � �����������")
		end
		window_mess.v = false
		end)
		end
		imgui.SameLine()
		if imgui.Button(u8"��������� ��") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== ����������� =====================")
		wait(50)
		sampSendChat("/mess 14 ���������� ����������� ".. u8:decode(arr_mp[mp_combo.v + 1]))
		wait(50)
	    sampSendChat("/mess 14 ���������� �����: " .. sampGetPlayerNickname(mp_win.v).. "["..mp_win.v.."]")
		wait(50)
	    sampSendChat("/mess 14 �����������")
		wait(50)
		sampSendChat(cmd.." "..mp_win.v.." "..prise_kol.v)
		wait(50)
		sampSendChat("/aspawn "..mp_win.v)
		wait(50)
		sampSendChat("/mess 13 ===================== ����������� =====================")
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
        wait(300) -- �������� �� �������
        setVirtualKeyDown(117, false)
        sampSetChatInputText(give_minigun)
		end)
		end
		end
		
		
		imgui.Text("")
		imgui.Text(u8"������� ID ����������: ")
		imgui.SameLine()
		imgui.InputText("##123123123123", mp_win)
	
		
		imgui.EndChild()
		end
		
		if beginchild == 6 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		  imgui.CenterText(u8''..script.this.name.. " | "..script.this.version)
		  

		  
		 if imgui.Button(u8"������ �������") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/coding.lua_yamada"))
end
		  
		 if imgui.Button(u8"����� �������") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/scr_vrd"))
end

 if imgui.Button(u8"���������� ���������� �������") then
    os.execute(('explorer.exe "%s"'):format("https://clck.ru/VWCuJ"))
end
		 
 imgui.Text(u8'���� ��� Nick ��� ��� Id �� ������������� �������������... \n ...�� ������� �� ������ "�������������"')		 
if imgui.Button(u8"���������") then
			lua_thread.create(function ()
			imgui.Process = false
			wait(200)
			imgui.ShowCursor = false
		thisScript():unload()
	end)
end
imgui.SameLine()
if imgui.Button(u8"�������������") then
			imgui.ShowCursor = false
			sampAddChatMessage(tag .. "������ ���������������.")
			thisScript():reload()
		end

imgui.PushItemWidth(130)
local styles = {u8"�������", u8"����������", u8"�������", u8"�������", u8"������", u8"������"}
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
	
	imgui.ShowCursor = false
   sampAddChatMessage(tag .. "���� �������� �������.")
	wait(1000)
	  if not checkServer(select(1, sampGetCurrentServerAddress())) then
		sampAddChatMessage(tag .. "������ �������� ������ �� �������� RDS!")
		wait(1000)
		thisScript():unload()
	end
	 wait(1000)
	if not doesDirectoryExist(getWorkingDirectory() .. "/config") then
       sampAddChatMessage(tag .. "� ��� ����������� ����� config, ������ �����.")
		createDirectory(getWorkingDirectory() .. "/config")
		wait(600)
		sampAddChatMessage(tag .. "����� �������.")
end
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/Event") then
	    sampAddChatMessage(tag .. "������ ����� Event")
		createDirectory(getWorkingDirectory() .. "/config/Event")
		wait(300)
		 sampAddChatMessage(tag .. "����� Event �������.")
	end
	
	sampAddChatMessage(tag .."���� �������� ����������.")
	wait(100)
	update()
	 sampRegisterChatCommand('event', function() 
	 window_mess.v = not window_mess.v
	 end)
     imgui.Process = false

	
	lua_thread.create(function()
	while true do
		wait(0)
	
	
   imgui.Process = window_mess.v
	
	
	end
	end)
end

function update()
  local fpath = os.getenv('TEMP') .. '\\testing_version.json' -- ���� ����� �������� ��� ������ ��� ��������� ������
  downloadUrlToFile('https://raw.githubusercontent.com/Vrednaya1234/Scripts-SAMP/main/update.json', fpath, function(id, status, p1, p2) -- ������ �� ��� ������ ��� ���� ������� ������� � ��� � ���� ��� ����� ������ ����
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    local f = io.open(fpath, 'r') -- ��������� ����
    if f then
      local info = decodeJson(f:read('*a')) -- ������
      updatelink = info.updateurl
      if info and info.latest then
        version = tonumber(info.latest) -- ��������� ������ � �����
        if version > tonumber(thisScript().version) then -- ���� ������ ������ ��� ������ ������������� ��...
          lua_thread.create(goupdate) -- ������
        else -- ���� ������, ��
          update = false -- �� ��� ���������� 
          sampAddChatMessage(tag .. '� ��� � ��� ��������� ������! ���������� ��������')
        end
      end
    end
  end
end)
end
--���������� ���������� ������
function goupdate()
sampAddChatMessage(tag .. '���������� ����� ����������. ����������...')
sampAddChatMessage(tag .. '������� ������: '..thisScript().version..". ����� ������: "..version)
wait(300)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- ������ ��� ������ � latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  sampAddChatMessage(tag .. '���������� ���������! ����������� � ��� ����� � ���� �������.')
  thisScript():reload()
end
end)
end