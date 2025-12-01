local playerAnimations = {}

-- Load player's saved animation from database
RegisterNetEvent('fd_radiomenu:requestAnimation', function()
    local source = source
    local identifier = GetPlayerIdentifierByType(source, 'license')
    
    if not identifier then
        TriggerClientEvent('fd_radiomenu:receiveAnimation', source, 1)
        return
    end
    
    -- Try to get from MySQL
    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:execute('SELECT animation FROM fd_radiomenu WHERE identifier = ?', {identifier}, function(result)
            if result and result[1] then
                local anim = tonumber(result[1].animation) or 1
                playerAnimations[source] = anim
                TriggerClientEvent('fd_radiomenu:receiveAnimation', source, anim)
            else
                -- No saved animation, use default
                TriggerClientEvent('fd_radiomenu:receiveAnimation', source, 1)
            end
        end)
    else
        -- No database, use default
        TriggerClientEvent('fd_radiomenu:receiveAnimation', source, 1)
    end
end)

-- Save player's animation choice
RegisterNetEvent('fd_radiomenu:saveAnimation', function(animIndex)
    local source = source
    local identifier = GetPlayerIdentifierByType(source, 'license')
    
    if not identifier then return end
    
    animIndex = tonumber(animIndex)
    if not animIndex or animIndex < 1 then return end
    
    playerAnimations[source] = animIndex
    
    -- Save to MySQL
    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:execute('INSERT INTO fd_radiomenu (identifier, animation) VALUES (?, ?) ON DUPLICATE KEY UPDATE animation = ?', 
            {identifier, animIndex, animIndex}
        )
    end
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    if playerAnimations[source] then
        playerAnimations[source] = nil
    end
end)
