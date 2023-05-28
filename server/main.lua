local dutyPlayers = {}
local trees = {}

ESX.RegisterServerCallback('map_lumberjack:duty', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    if not Config.FreelanceJob and job.name ~= Config.JobName then
        return false
    end

    if dutyPlayers[source] then
        dutyPlayers[source] = nil
        cb(false)
    else
        dutyPlayers[source] = true
        cb(true)
    end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Trees) do
        table.insert(trees, { 
            coords = v, health = 100 
        })
    end
end)

ESX.RegisterServerCallback('map_lumberjack:getTreesWithData', function(_, cb)
   cb(trees)
end)

ESX.RegisterServerCallback('map_lumberjack:hasItem', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    cb(xPlayer.getInventoryItem('water').count)
end)

RegisterNetEvent('map_lumberjack:makeDamage', function(index)
    local data = trees[index]
    local xPlayer = ESX.GetPlayerFromId(source)

    if not data or not dutyPlayers[source] then
        return false
    end

    trees[index].health -= 20
    syncTrees()
    if data.health == 0 then
        xPlayer.addInventoryItem('wood', 1)
        Citizen.SetTimeout(Config.GrowingTime, function()
            trees[index].health = 100
            syncTrees()
        end)
    end
end)

function syncTrees()
    TriggerClientEvent('map_lumberjack:syncTrees', -1, trees)
end

RegisterNetEvent('map_lumberjack:sellAllWood', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventory = xPlayer.getInventory(true)
    for k,v in pairs(inventory) do
        if k == 'wood' then
            xPlayer.addAccountMoney('money', v * Config.WoodPrice)
            xPlayer.removeInventoryItem('wood', v)
        end
    end
end)