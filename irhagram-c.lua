
print('^1[^9irhagram^1]^3|----------------------------------anoni4m-----------------------------------------|')
print('^1[^9irhagram^1]^3|                 Script Ngepot Booster Made by Roy/anoni4m 2021                   |')
print('^1[^9irhagram^1]^3|                              versi anoni-1.3                                     |')
print('^1[^9irhagram^1]^3|             https://github.com/irhagram/irhagram-ngepotbooster                   |')
print('^1[^9irhagram^1]^3|----------------------------------anoni4m-----------------------------------------|')
--[PANGGILAN KEPADA NITRO]
local nitro = 0
local nitroUsed = false
local nitroveh = nil
local soundofnitro
local sound = false
local exhausts = {}
local engineon

--[PANGGILAN KEPADA NGEPOT]
local score = 0
local screenScore = 0
local tick
local idleTime
local driftTime
local tablemultiplier = {350,1400,4200,11200}
local mult = 0.2
local previous = 0
local total = 0
local curAlpha = 0

local SaveAtEndOfDrift = nil
local SaveTime = nil

ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

--[NGEPOT MULAI DARI SINI]
Citizen.CreateThread( function()
	
	-- Save/Load functions -- 
	TriggerServerEvent("RequestConfig")
	
	-- function SaveScore()
	-- 	_,PlayerScore = StatGetInt("MP0_DRIFT_SCORE", -1)
	-- 	TriggerServerEvent("SaveScore", PlayerScore)
	-- 	SetTimeout(SaveTime, SaveScore)
	-- end	
		
	-- RegisterNetEvent("RecieveConfig")
	-- AddEventHandler("RecieveConfig", function(SaveAtEndOfDriftS, SaveTimeS)
	-- 	SaveAtEndOfDrift = SaveAtEndOfDriftS
	-- 	SaveTime = SaveTimeS
	-- 	if not SaveAtEndOfDrift then
	-- 		SetTimeout(SaveTime, SaveScore)
	-- 	end
	-- end)
	
	-- RegisterNetEvent("LoadScore")
	-- AddEventHandler("LoadScore", function(PlayerSavedScore)
	-- 	StatSetInt("MP0_DRIFT_SCORE", PlayerSavedScore, true)
	-- 	print("Score set to "..PlayerSavedScore)
	-- 	data = {score = PlayerSavedScore}
	-- 	TriggerServerEvent("SaveScore", GetPlayerServerId(PlayerId()), data)
	-- end)	
	
	
	-- local FirstTime = true
	-- AddEventHandler("playerSpawned", function()
	-- 	if FirstTime then
	-- 		TriggerServerEvent("LoadScoreData")
	-- 		FirstTime = false
	-- 	end
	-- end)
	
	
	-- PREP FUNCTIONS --
	
	function round(number)
		number = tonumber(number)
		number = math.floor(number)
		
		if number < 0.01 then
			number = 0
		elseif number > 999999999 then
			number = 999999999
		end
		return number
	end
	
	function calculateBonus(previous)
		local points = previous
		local points = round(points)
		return points or 0
	end
	function math.precentage(a,b)
		return (a*100)/b
	end
	
	function angle(veh)
		if not veh then return false end
		local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
		local modV = math.sqrt(vx*vx + vy*vy)
		
		
		local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
		local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
		
		if GetEntitySpeed(veh)* 3.6 < 30 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --speed over 30 km/h
		
		local cosX = (sn*vx + cs*vy)/modV
		if cosX > 0.966 or cosX < 0 then return 0,modV end
		return math.deg(math.acos(cosX))*0.5, modV
	end
	
	function DrawHudText(text,colour,coordsx,coordsy,scalex,scaley)
		SetTextFont(1)
		SetTextProportional(7)
		SetTextScale(scalex, scaley)
		local colourr,colourg,colourb,coloura = table.unpack(colour)
		SetTextColour(colourr,colourg,colourb, coloura)
		SetTextDropshadow(0, 0, 0, 0, coloura)
		SetTextEdge(1, 0, 0, 0, coloura)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		AddTextComponentString(text)
		EndTextCommandDisplayText(coordsx,coordsy)
	end
	
	-- END PREP FUNCTIONS --
	
	-- RegisterNetEvent("SetPlayerNativeMoney")
	-- AddEventHandler("SetPlayerNativeMoney", function(money)
	-- 	local _,pm = StatGetInt( "MP0_WALLET_BALANCE", -1)
	-- 	StatSetInt("MP0_WALLET_BALANCE", pm+money, true)
	-- end)
	
	
	while true do
		Citizen.Wait(1)
		PlayerPed = PlayerPedId()
		tick = GetGameTimer()
		if not IsPedDeadOrDying(PlayerPed, 1) and GetVehiclePedIsUsing(PlayerPed) and GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPed), -1) == PlayerPed and IsVehicleOnAllWheels(GetVehiclePedIsUsing(PlayerPed)) and not IsPedInFlyingVehicle(PlayerPed) then
			PlayerVeh = GetVehiclePedIsIn(PlayerPed,false)
			local angle,velocity = angle(PlayerVeh)
			local tempBool = tick - (idleTime or 0) < 1850
			if not tempBool and score ~= 0 then
				previous = score
				previous = calculateBonus(previous)
				
				total = total+previous
				nitro = previous/400
				nitro = round(nitro)
				TriggerServerEvent("driftcounter:payDrift", nitro )
				TriggerEvent("driftcounter:DriftFinished", previous)
				_,oldScore = StatGetInt("MP0_DRIFT_SCORE",-1)
				StatSetInt("MP0_DRIFT_SCORE", oldScore+previous, true)
				_,newScore = StatGetInt("MP0_DRIFT_SCORE",-1)
				local data = {score = newScore}
				TriggerServerEvent("SaveScore", GetPlayerServerId(PlayerId()), data) 
				score = 0
			end
			if angle ~= 0 then
				if score == 0 then
					drifting = true
					driftTime = tick
				end
				if tempBool then
					score = score + math.floor(angle*velocity)*mult
				else
					score = math.floor(angle*velocity)*mult
				end
				screenScore = calculateBonus(score)
				
				idleTime = tick
			end
		end
		
		if tick - (idleTime or 0) < 3000 then
			if curAlpha < 255 and curAlpha+10 < 255 then
				curAlpha = curAlpha+10
			elseif curAlpha > 255 then
				curAlpha = 255
			elseif curAlpha == 255 then
				curAlpha = 255
			elseif curAlpha == 250 then
				curAlpha = 255
			end
		else
			if curAlpha > 0 and curAlpha-10 > 0 then
				curAlpha = curAlpha-10			elseif curAlpha < 0 then
				curAlpha = 0

			elseif curAlpha == 5 then
				curAlpha = 0
			end
		end
		if not screenScore then screenScore = 0 end
		DrawHudText(string.format("\n Skor Ngepot = %s",tostring(screenScore)), {255,102,191,curAlpha},0.5,0.0,0.7,0.7)

	end
end)






function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end

-- BASE NYA EFEK NGEPOT BOOSTER

function flame (veh, count)
  if exhausts then
    if not HasNamedPtfxAssetLoaded("core") then
      RequestNamedPtfxAsset("core")
      while not HasNamedPtfxAssetLoaded("core") do
        Wait(1)
      end
    end
    if count == 1 then
      UseParticleFxAssetNextCall("core")
      fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
      Wait(0)
      StopParticleFxLooped(fire, false)
    elseif count == 2 then
      UseParticleFxAssetNextCall("core")
      fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
      Wait(0)
      StopParticleFxLooped(fire, false)
      StopParticleFxLooped(fire2, false)
    elseif count == 3 then
      UseParticleFxAssetNextCall("core")
      fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire3 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[3], 1.0, 0, 0, 0)
      Wait(0)
      StopParticleFxLooped(fire, false)
      StopParticleFxLooped(fire2, false)
      StopParticleFxLooped(fire3, false)
    elseif count == 4 then
      UseParticleFxAssetNextCall("core")
      fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire3 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[3], 1.0, 0, 0, 0)
      UseParticleFxAssetNextCall("core")
      fire4 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[4], 1.0, 0, 0, 0)
      Wait(0)
      StopParticleFxLooped(fire, false)
      StopParticleFxLooped(fire2, false)
      StopParticleFxLooped(fire3, false)
      StopParticleFxLooped(fire4, false)
    end
  end
end

Citizen.CreateThread(function()
  while true do
    Wait(0)

    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped, false)

    if engineon == false then
      SetVehicleEngineOn(veh, false, false, false)
      SetVehicleUndriveable(veh, false, false, false)
    end

    if GetPedInVehicleSeat(veh, -1) == ped then
       DrawAdvancedText(-0.035, 0.7990, 0.150, 0.0028, 0.4, "~p~Ngepot Booster:  ~s~" .. nitro, 255, 255, 255, 255, 6, 1)
    end

    if IsControlPressed(0, 27) and GetPedInVehicleSeat(veh, -1) == ped and nitro > 0 then
      Citizen.InvokeNative(0xB59E4BD37AE292DB, veh, 50.0)
      Citizen.InvokeNative(0x93A3996368C94158, veh, 50.0)
      nitroUsed = true

      if sound == false then
        soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", veh, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
        sound = true
      end
    else
      nitroUsed = false
      Citizen.InvokeNative(0xB59E4BD37AE292DB, veh, 1.0)
      Citizen.InvokeNative(0x93A3996368C94158, veh, 1.0)

      if sound == true then
        StopSound(soundofnitro)
        ReleaseSoundId(soundofnitro)
        sound = false
      end
    end
  end
end)


-- UPDATE STATUS NGEPOT BOOSTER
Citizen.CreateThread(function()
  while true do
    Wait(0)

    local ped = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(ped, false)
    local hash = GetEntityModel(veh)

    if nitroUsed then
      Wait(100)
      nitro = nitro - 1
    end

    if IsThisModelACar(hash) and veh ~= nitroveh then
        exhausts = {}

        for i=1,12 do

          local exhaust = GetEntityBoneIndexByName(veh, "exhaust_" .. i)

          if i == 1 and GetEntityBoneIndexByName(veh, "exhaust") ~= -1 then
            table.insert(exhausts, GetEntityBoneIndexByName(veh, "exhaust"))
          end
          if exhaust ~= -1 then
            table.insert(exhausts, exhaust)
          end
        end
    end

  end
end)

-- EFEK NGEPOT BOOSTER
Citizen.CreateThread(function()
  while true do
    Wait(10)
    if nitroUsed then

      local ped = GetPlayerPed(-1)
      local veh = GetVehiclePedIsIn(ped, false)

      if exhausts ~= {} then
        flame(veh, #exhausts)
      end

    end
  end
end)
