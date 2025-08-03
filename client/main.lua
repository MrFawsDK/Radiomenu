local currentAnim = 1
local playing = false
local prop = nil
local dict = nil
local model = Config.Performance.propModel
local ready = false
local startTime = 0

local dicts = {}
local retries = 0

function checkPlayer()
    local ped = PlayerPedId()
    return ped and DoesEntityExist(ped) and not IsEntityDead(ped)
end

function checkBone(ped, bone)
    if not checkPlayer() then return false end
    return GetPedBoneIndex(ped, bone) ~= -1
end

function loadDicts()
    for _, anim in ipairs(Config.RadioAnimations) do
        if anim.dict and not dicts[anim.dict] then
            RequestAnimDict(anim.dict)
            dicts[anim.dict] = {loaded = false, time = GetGameTimer()}
        end
    end
end

function isDictLoaded(d)
    if not d or d == "" then return false end
    
    if not dicts[d] then
        RequestAnimDict(d)
        dicts[d] = {loaded = false, time = GetGameTimer()}
    end
    
    if HasAnimDictLoaded(d) then
        dicts[d].loaded = true
        return true
    end
    
    if GetGameTimer() - dicts[d].time > Config.Performance.timeoutMs then
        return false
    end
    return false
end

function handleProp(create)
    if not checkPlayer() then return false end
    
    if create and not prop then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        
        if not HasModelLoaded(model) then
            RequestModel(model)
            local wait = 0
            while not HasModelLoaded(model) and wait < 3000 do
                Wait(50)
                wait = wait + 50
            end
            if not HasModelLoaded(model) then return false end
        end
        
        prop = CreateObject(model, pos.x, pos.y, pos.z, true, true, false)
        if not DoesEntityExist(prop) then
            prop = nil
            return false
        end
        
        local anim = Config.RadioAnimations[currentAnim]
        if not anim then
            DeleteEntity(prop)
            prop = nil
            return false
        end
        
        if not checkBone(ped, anim.boneIndex) then
            DeleteEntity(prop)
            prop = nil
            return false
        end
        
        local bone = GetPedBoneIndex(ped, anim.boneIndex)
        SetEntityCollision(prop, false, false)
        SetEntityAsMissionEntity(prop, true, true)
        
        AttachEntityToEntity(
            prop, ped, bone,
            anim.offset.x, anim.offset.y, anim.offset.z,
            anim.rotation.x, anim.rotation.y, anim.rotation.z,
            true, true, false, true, 1, true
        )
        
        return DoesEntityExist(prop) and IsEntityAttached(prop)
        
    elseif not create and prop then
        if DoesEntityExist(prop) then
            DetachEntity(prop, true, false)
            DeleteEntity(prop)
        end
        prop = nil
        retries = 0
    end
    
    return false
end

function stopAnim()
    if not playing then return end
    
    local ped = PlayerPedId()
    if checkPlayer() then
        ClearPedTasks(ped)
        if dict and dict ~= "" then
            StopAnimTask(ped, dict, "", 1.0)
        end
    end
    
    handleProp(false)
    playing = false
    startTime = 0
    dict = nil
    
    if Config.Validation then
        Wait(Config.Validation.cleanupDelay or 50)
    end
end

function playAnim(index)
    if not ready then return false end
    if not checkPlayer() then return false end
    if not Config.RadioAnimations[index] then return false end
    
    if playing then
        stopAnim()
        Wait(50)
    end
    
    local anim = Config.RadioAnimations[index]
    dict = anim.dict
    
    if not anim.dict or not anim.anim then return false end
    
    local ped = PlayerPedId()
    if not checkBone(ped, anim.boneIndex) then return false end
    
    if not isDictLoaded(anim.dict) then
        RequestAnimDict(anim.dict)
        local wait = 0
        while not HasAnimDictLoaded(anim.dict) and wait < 3000 do
            Wait(50)
            wait = wait + 50
        end
        if not HasAnimDictLoaded(anim.dict) then return false end
    end
    
    TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, 49, 0, false, false, false)
    
    local start = GetGameTimer()
    while not IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3) do
        if GetGameTimer() - start > 1000 then return false end
        Wait(50)
    end
    
    playing = true
    currentAnim = index
    startTime = GetGameTimer()
    
    if anim.useProp then
        handleProp(true)
    end
    
    return true
end

function onRadio(active)
    if not ready or not checkPlayer() then return end
    
    if active and not playing then
        playAnim(currentAnim)
    elseif not active and playing then
        stopAnim()
    end
end

function openMenu()
    if not ready then return end
    
    local name = "None"
    if Config.RadioAnimations[currentAnim] and Config.RadioAnimations[currentAnim].label then
        name = Config.RadioAnimations[currentAnim].label
    end
    
    local options = {}
    
    table.insert(options, {
        title = '📻 Radio Animations',
        description = 'Currently active: ' .. name,
        icon = 'radio',
        iconColor = '#4A90E2',
        disabled = true
    })
    
    table.insert(options, {
        title = '────────────────',
        disabled = true
    })
    
    for i, anim in ipairs(Config.RadioAnimations) do
        if anim and anim.label and anim.description then
            local selected = (currentAnim == i)
            
            table.insert(options, {
                title = (selected and '● ' or '○ ') .. anim.label,
                description = anim.description,
                icon = 'radio',
                iconColor = selected and '#00D26A' or '#FFFFFF',
                onSelect = function()
                    if playAnim(i) then
                        lib.notify({
                            title = 'Radio Animation',
                            description = anim.label .. ' activated',
                            type = 'success'
                        })
                        CreateThread(function()
                            Wait(100)
                            openMenu()
                        end)
                    else
                        lib.notify({
                            title = 'Animation Error', 
                            description = 'Failed to activate ' .. anim.label,
                            type = 'error'
                        })
                    end
                end
            })
        end
    end

    lib.registerContext({
        id = 'radio_menu',
        title = '📻 Radio System',
        options = options
    })
    lib.showContext('radio_menu')
end

RegisterCommand('radiomenu', function()
    if ready then openMenu() end
end, false)

RegisterNetEvent('pma-voice:radioActive', function(talking)
    if talking ~= nil then onRadio(talking) end
end)

RegisterNetEvent('saltychat:radioActive', function(talking)
    if talking ~= nil then onRadio(talking) end
end)

RegisterNetEvent('fawsdev-radio:setRadioState', function(active)
    onRadio(active)
end)

CreateThread(function()
    local lastPos = nil
    local lastCheck = 0
    
    while true do
        Wait(100)
        
        if ready and playing then
            local time = GetGameTimer()
            
            if time - lastCheck > 1000 then
                if not checkPlayer() then
                    stopAnim()
                    lastPos = nil
                    lastCheck = time
                    goto continue
                end
                lastCheck = time
            end
            
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            
            if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedBeingStunned(ped) or 
               IsPedInAnyVehicle(ped, false) or IsPedSwimming(ped) or IsPedClimbing(ped) then
                stopAnim()
                lastPos = nil
                goto continue
            end
            
            if Config.Validation and Config.Validation.maxAnimationTime then
                if startTime > 0 and time - startTime > Config.Validation.maxAnimationTime then
                    stopAnim()
                    lastPos = nil
                    goto continue
                end
            end
            
            if prop then
                if not DoesEntityExist(prop) then
                    prop = nil
                    local anim = Config.RadioAnimations[currentAnim]
                    if anim and anim.useProp then
                        handleProp(true)
                    end
                elseif not IsEntityAttached(prop) then
                    local anim = Config.RadioAnimations[currentAnim]
                    if anim and checkBone(ped, anim.boneIndex) then
                        local bone = GetPedBoneIndex(ped, anim.boneIndex)
                        AttachEntityToEntity(
                            prop, ped, bone,
                            anim.offset.x, anim.offset.y, anim.offset.z,
                            anim.rotation.x, anim.rotation.y, anim.rotation.z,
                            true, true, false, true, 1, true
                        )
                    end
                end
            elseif Config.RadioAnimations[currentAnim] and Config.RadioAnimations[currentAnim].useProp then
                handleProp(true)
            end
            
            lastPos = pos
        else
            lastPos = nil
        end
        
        ::continue::
    end
end)

CreateThread(function()
    loadDicts()
    
    RequestModel(model)
    local start = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - start > 5000 then break end
        Wait(100)
    end
    
    local loaded = false
    local dictStart = GetGameTimer()
    
    while not loaded and GetGameTimer() - dictStart < 10000 do
        loaded = true
        for i, anim in ipairs(Config.RadioAnimations) do
            if not isDictLoaded(anim.dict) then
                loaded = false
                break
            end
        end
        if not loaded then Wait(100) end
    end
    
    ready = true
end)

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() == name then
        stopAnim()
        
        for d, _ in pairs(dicts) do
            if HasAnimDictLoaded(d) then
                RemoveAnimDict(d)
            end
        end
        
        if HasModelLoaded(model) then
            SetModelAsNoLongerNeeded(model)
        end
        
        ready = false
        dicts = {}
    end
end)

exports('playRadioAnimation', function(index)
    if not ready then return false end
    return playAnim(index)
end)

exports('stopRadioAnimation', function()
    if not ready then return false end
    stopAnim()
    return true
end)

exports('getCurrentAnimation', function()
    return currentAnim
end)

exports('isPlayingAnimation', function()
    return playing
end)

exports('getResourceStatus', function()
    return {
        ready = ready,
        playing = playing,
        currentAnim = currentAnim,
        propExists = prop ~= nil
    }
end)
