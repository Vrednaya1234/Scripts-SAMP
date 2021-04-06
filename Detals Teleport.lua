script_name("Detals Teleport")
script_author("Vrednaya.")

-- ����������
require "lib.moonloader"
local tag = "{741DCE}Detals Teleport: {FFFFFF}"
local ev = require 'samp.events'
local time = 11000
local encoding = require 'encoding'
encoding.default = 'CP1252'
u8 = encoding.UTF8
local inicfg = require 'inicfg'
local dlstatus = require('moonloader').download_status

-- ��������������


-- inicfg
local mainIni = inicfg.load({
  settings =
  {
    vers = 1,
    vers_text = "Relis"
  }
 
}, "DL.ini")

tServers = {
	'46.174.52.246', -- 01
        '46.174.55.87', -- 02
        '46.174.49.170', -- 03
        '46.174.55.169' -- 04
}

function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

function main()
	 if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
	  
	
	sampAddChatMessage(tag .. "���� �������� �� ������.")
	 wait(1000)
	  if not checkServer(select(1, sampGetCurrentServerAddress())) then
		sampAddChatMessage(tag .. "������ �������� ������ �� �������� RDS!")
		wait(4000)
		thisScript():unload()
	end
   wait(2000)
 sampAddChatMessage(tag .. "�������� ������ �������")
   
	sampAddChatMessage(tag .. "������� ��������!")
	
	 sampRegisterChatCommand("update", cmd_update)
	sampRegisterChatCommand('gotpdl', function()
	lua_thread.create(function()
	setCharCoordinates(PLAYER_PED, 281.095, -1751.71, 4.53825)
	wait(time)
	setCharCoordinates(PLAYER_PED, 170.083, -1752.91, 5.29688)
	wait(time)
	setCharCoordinates(PLAYER_PED, 278.414, -1587.94, 17.8593)
	wait(time)
    setCharCoordinates(PLAYER_PED, 299.685, -1592.32, 17.8593)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1568.06, -1889.85, 13.5589)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1161.13, -1891.91, 18.4668)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1038.73, -1845.34, 13.558)
	wait(time)
	setCharCoordinates(PLAYER_PED, 594.45, -1768.93, 14.4036)
	wait(time)
	setCharCoordinates(PLAYER_PED, 150.617, -1464.3, 27.3857)
	wait(time)
	setCharCoordinates(PLAYER_PED, 768.876, -1851.21, 5.83193)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1141.39, -2090.34, 70.3096)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1856.91, -2694.2, 13.5469)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2809.55, -1523.44, 17.4023)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2354.84, -1032.99, 54.6135)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2449.54, 157.105, 25.183)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2391.2, 273.688, 19.6307)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2087.54, 619.053, 10.8203)
	wait(time)
	setCharCoordinates(PLAYER_PED, 1975.55, 757.661, 10.8203)
	wait(time)
	setCharCoordinates(PLAYER_PED, 2467.09, 2796.79, 10.8203)
	sampAddChatMessage(tag .. "���, �� ��� ��������� ����� :(")
	wait(time)
	end)
	end)
	
	
	sampAddChatMessage(tag .. "���� �������� ����������.")
    update()
	
	while true do
		wait(0)
		

		
	end
end

function update()
  local fpath = os.getenv('TEMP') .. '\\testing_version.json' -- ���� ����� �������� ��� ������ ��� ��������� ������
  downloadUrlToFile('', fpath, function(id, status, p1, p2) -- ������ �� ��� ������ ��� ���� ������� ������� � ��� � ���� ��� ����� ������ ����
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
          sampAddChatMessage((tag.. '� ��� ������������ ���������� ������ �������.'), color)
        end
      end
    end
  end
end)
end
--���������� ���������� ������
function goupdate()
sampAddChatMessage(tag .. '���������� ����� ������ �������! �������� ����������!')
sampAddChatMessage(tag .. '������� ������: '..thisScript().version..". ����� ������: "..version)
wait(300)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- ������ ��� ������ � latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  sampAddChatMessage(tag .. "���������� ���������!")
  thisScript():reload()
end
end)
end

-- �Ѩ!
