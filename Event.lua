script_name('Event')
script_properties("Event.lua")
script_version('1.2')

-- Библиотеки
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
local script_version = "Версия скрипта: 1.2"

local inicfg = require "inicfg"
local memory = require "memory"
local imgui = require("imgui")
local vkeys	= require "lib.vkeys"
local window_mess = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local mp_combo = imgui.ImInt(0)
local arr_mp = {u8"Прятки на корабле", u8"Прятки", u8"Русская Рулетка", u8"Король Дигла", u8"Fall Guys", u8"UFC"}
local arr_prise = {u8"Вирты", u8"Очки", u8"Коины", u8"Рубли", u8"Стандарт"}
local arr_minigun = {u8"Попросить", u8"Выдать себе", u8"Выдать другому"}
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
		"46.174.49.47" -- разработка
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
                sampAddChatMessage(tag .. '[Mono Tools]{FFFFFF} Доступно новое обновление! Пытаюсь обновиться c '..thisScript().version..' на '..updateversion)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Скрипт успешно обновлён.')
					  sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Ознакомиться со всеми обновлениями вы сможете в Меню скрипта.')
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage(tag ..'[Mono Tools]{FFFFFF} Не удалось обновить скрипт! Обратитесь к автору скрипта.')
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
		
		imgui.CenterText(u8"Ваш Nick: " .. sampGetPlayerNickname(id))
		imgui.CenterText(u8"Ваш ID: " .. id)
	
	imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Текст кнопки").x) / 2)
	if imgui.Button(u8"Исправить баги") then
		thisScript():reload()
	end
	imgui.SameLine()
	imgui.Help(u8"Если информация о вас не корректная, следует нажать на данную кнопку")
		if imgui.CollapsingHeader(u8"Сторонние Программы") then
		imgui.Text(u8'================= Информация =================')
		imgui.Text(u8'На сервере запрещены Сторонние Программы.')
		imgui.Text(u8'Которые дают преимущества над игроками.')
		imgui.Text(u8'Если вы заметите игрока со Сторонними Программами.')
		imgui.Text(u8'Пишите администраторам:"/report id причина"')
		imgui.Text(u8'================= Информация =================')
		if imgui.Button(u8"Отправить", btn_size) then
		sampSendChat("/mess 12 ================= Информация =================")
		sampSendChat("/mess 6 На сервере запрещены Сторонние Программы.")
		sampSendChat("/mess 6 Которые дают преимущества над игроками.")
		sampSendChat("/mess 6 Если вы заметите игрока со Сторонними Программами.")
		sampSendChat("/mess 6 Пишите администраторам:'/report id причина' ")
		sampSendChat("/mess 12 ================= Информация =================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.Separator()
		end
        
			if imgui.CollapsingHeader(u8"Спавн Транспорта") then
		imgui.Text(u8'====================== Респавн Авто ========================')
		imgui.Text(u8'Уважаемые игроки, через 15 секунд будет произведен.')
		imgui.Text(u8'Респавн Транспортного средства, чтобы не потерять его.')
		imgui.Text(u8'Займите Водительское/Пассажирское место')
		imgui.Text(u8'Приятной игры на Russian Drift Server.')
		imgui.Text(u8'================= Респавн Авто ===============')
		if imgui.Button(u8"Отправить", btn_size) then
		sampSendChat("/mess 12 ====================== Респавн Авто ========================")
		sampSendChat("/mess 6 Уважаемые игроки, через 15 секунд будет произведен.")
		sampSendChat("/mess 6 Респавн Транспортного средства, чтобы не потерять его.")
		sampSendChat("/mess 6 Займите Водительское/Пассажирское место")
		sampSendChat("/spawncars 15")
		sampSendChat("/delcarall")
		sampSendChat("/mess 12 ====================== Респавн Авто ========================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.Separator()
		end
		
		if imgui.CollapsingHeader(u8"Жалоба на Администрацию") then
		imgui.Text(u8'================== Информация ==================')
		imgui.Text(u8'Не согласны с наказание какого-то администратора ?')
		imgui.Text(u8'Вы можете подать жалобу на него, либо разблокировку.')
		imgui.Text(u8'Просто перейдите в нужное обсуждение по ссылке ниже.')
		imgui.Text(u8'Группа: "https://vk.com/dmdriftgta".')
		imgui.Text(u8'============== Неверное наказание ===============')
		if imgui.Button(u8"Отправить", btn_size) then
		sampSendChat("/mess 12 ================== Информация ==================")
		sampSendChat("/mess 6 Не согласны с наказание какого-то администратора?")
		sampSendChat("/mess 6 Вы можете подать жалобу на него, либо разблокировку.")
		sampSendChat("/mess 6 Просто перейдите в нужное обсуждение по ссылке ниже.")
		sampSendChat("/mess 6 Группа: https://vk.com/dmdriftgta")
		sampSendChat("/mess 12 ============== Неверное наказание ===============")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.Separator()
		end
		
		if imgui.CollapsingHeader(u8"Центральный Рынок") then
		imgui.Text(u8'===================== Информация =====================')
		imgui.Text(u8'Желаете приобрести аксессуар за Вирты/Очки/Коины/Рубли?')
		imgui.Text(u8'Добро пожаловать на рынок, по команде: "/trade"')
		imgui.Text(u8'Так же, подойдя к NPC, можно обменять валюты. ')
		imgui.Text(u8'Но учтите... Не нужно вредить игрокам.')
		imgui.Text(u8'================= Рынок/Обмен валют ==================')
		if imgui.Button(u8"Отправить", btn_size) then
		sampSendChat("/mess 12 ===================== Информация =====================")
		sampSendChat("/mess 6 Желаете приобрести аксессуар за Вирты/Очки/Коины/Рубли?")
		sampSendChat("/mess 6 Добро пожаловать на рынок, по команде: /trade")
		sampSendChat("/mess 6 Так же, подойдя к NPC, можно обменять валюты.")
		sampSendChat("/mess 6 Но учтите... Не нужно вредить игрокам.")
		sampSendChat("/mess 12 ================= Рынок/Обмен валют ==================")
		window_mess.v = false
		imgui.Process = false
		end
		imgui.Separator()
		end
		 local x, y, z = getCharCoordinates(playerPed)
         local str_cords = string.format("%.2f, %.2f, %.2f", x, y, z)
		if imgui.CollapsingHeader(u8"Мероприятия") then
		imgui.Text(u8'Позиция игрока: '..str_cords)
		imgui.Text(u8'Выберите мероприятие: ')
		imgui.SameLine()
		imgui.PushItemWidth(190)
		imgui.Combo(u8'', mp_combo, arr_mp, #arr_mp)
		
		imgui.Text(u8"Выберите тип приза и введите его количество: ")
		if imgui.Combo(u8"##Prise", mp_prise, arr_prise, #arr_prise) then
		if mp_prise.v == 0 then
		cmd = "/agivemoney"
		prise = "Вирт"
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
		prise = "Стандартный"
		end
		end
		imgui.SameLine()
		imgui.InputText("##PriseKol", prise_kol)
		
		if imgui.Button(u8"Начать МП") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== МероПриятие =====================")
		sampSendChat("/mess 14 Проходит МероПриятие ".. u8:decode(arr_mp[mp_combo.v + 1]))
		sampSendChat("/mess 14 Телепорт будет открыт ровно 60 секунд")
		sampSendChat("/mess 14 Приз для победителя: "..prise_kol.v.." "..prise)
		sampSendChat("/mp")
        sampSendDialogResponse(5343, 1, 0)
		wait(900)
		sampSendDialogResponse(5344, 1, _, u8:decode(arr_mp[mp_combo.v + 1]))
		wait(900)
		sampSendDialogResponse(1)
		sampSendChat('/mess 14 Чтобы попасть на МероПриятие следует прописать "/tpmp"')
		sampSendChat("/mess 13 ===================== МероПриятие =====================")
		window_mess.v = false
		local v = 60
		for i=1, 60 do
		v = v - 1
		printString('~g~ '..v, 1000)
		wait(1000)
		end
		sampSendChat('/mess 14 Время на телепорт вышло.')
		wait(1000)
		sampSendChat('/mess 14 Закрываю телепорт')
		wait(500)
		sampSendChat("/mp")
		wait(700)
		sampSendDialogResponse(5343, 1, 0)
		window_mess.v = false
		end)
		end
		imgui.SameLine()
		if imgui.Button(u8"Закончить МП и выдать приз") then
		lua_thread.create(function()
		sampSendChat("/mess 13 ===================== МероПриятие =====================")
		wait(50)
		sampSendChat("/mess 14 Победитель мероприятия ".. u8:decode(arr_mp[mp_combo.v + 1]))
		wait(50)
	    sampSendChat("/mess 14 Становится игрок: " .. sampGetPlayerNickname(mp_win.v))
		wait(50)
	    sampSendChat("/mess 14 Поздравляем")
		wait(50)
		sampSendChat(cmd.." "..mp_win.v.." "..prise_kol.v)
		wait(50)
		sampSendChat("/aspawn "..mp_win.v)
		wait(50)
		sampSendChat("/mess 13 ===================== МероПриятие =====================")
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
        wait(300) -- задержка на секунду
        setVirtualKeyDown(117, false)
        sampSetChatInputText(give_minigun)
		end)
		end
		end
		
		
		imgui.Text("")
		imgui.Text(u8"Введите ID победителя: ")
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
	
	imgui.ShowCursor = false
   sampAddChatMessage(tag .. "Идет проверка сервера.")
	wait(1000)
	  if not checkServer(select(1, sampGetCurrentServerAddress())) then
		sampAddChatMessage(tag .. "Скрипт работает только на серверах RDS!")
		wait(1000)
		thisScript():unload()
	end
	 wait(1000)
	if not doesDirectoryExist(getWorkingDirectory() .. "/config") then
       sampAddChatMessage(tag .. "У вас отсутствует папка config, создаю папку.")
		createDirectory(getWorkingDirectory() .. "/config")
		wait(600)
		sampAddChatMessage(tag .. "Папка создана.")
end
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/Event") then
	    sampAddChatMessage(tag .. "Создаю папку Event")
		createDirectory(getWorkingDirectory() .. "/config/Event")
		wait(300)
		 sampAddChatMessage(tag .. "Папка Event создана.")
	end
	
	sampAddChatMessage(tag .. "Идет проверка обновления")
	wait(1000)
	autoupdate("https://raw.githubusercontent.com/Vrednaya1234/Scripts-SAMP/main/update.json", '['..string.upper(thisScript().name)..']: ')
	sampAddChatMessage(tag .. "NEW")
	sampAddChatMessage(tag .. "NEW")
	sampAddChatMessage(tag .. "NEW")
	sampAddChatMessage(tag .. "NEW")
	sampAddChatMessage(tag .. "Скрипт готов к работе!")
	sampAddChatMessage(tag .. "Автор скрипта: " .. script_author)
	sampAddChatMessage(tag .. "Версия скрипта: " .. script_version)
	

	
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
