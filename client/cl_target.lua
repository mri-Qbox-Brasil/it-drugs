lib.print.info('GetServerInteraction', exports.it_bridge:GetServerInteraction())
if not exports.it_bridge:GetServerInteraction() then return end

local plantOptions = nil
local tableOptions = nil
local dealerOptions = nil
local sellOptions = nil
-- ┌────────────────────────────────────────────────────────┐
-- │ ____  _             _     _____                    _   │
-- │|  _ \| | __ _ _ __ | |_  |_   _|_ _ _ __ __ _  ___| |_ │
-- │| |_) | |/ _` | '_ \| __|   | |/ _` | '__/ _` |/ _ \ __|│
-- │|  __/| | (_| | | | | |_    | | (_| | | | (_| |  __/ |_ │
-- │|_|   |_|\__,_|_| |_|\__|   |_|\__,_|_|  \__, |\___|\__|│
-- │                                         |___/          │
-- └────────────────────────────────────────────────────────┘
for _, v in pairs(Config.PlantTypes) do
    for _, plant in pairs(v) do
        plantOptions = exports.it_bridge:AddTargetModel(plant[1], {
            {
                label = _U('TARGET__PLANT__LABEL'),
                name = 'it-drugs-check-plant',
                icon = 'fas fa-eye',
                onSelect = function(entity)
                    local networkId = NetworkGetNetworkIdFromEntity(entity)
                    lib.callback("it-drugs:server:getPlantByNetId", false, function(plantData)
                        if not plantData then
                            lib.print.error('[it-drugs] Unable to get plant data by network id')
                        else
                            if Config.Debug then
                                lib.print.info('[plantSelect] Current plant data: ', plantData)
                            end
<<<<<<< fork
                        }
                    },
                    distance = 1.5,
                })
            end
        end
        if Config.Debug then lib.print.info(_U('DEBUG__REGISTERED_ALL_PLANTS')) end -- DEBUG
    elseif Config.Target == 'ox_target' then
        if Config.Debug then lib.print.info(_U('DEBUG__DETECTED_TARGET_SYSTEM'):format('ox_target')) end -- DEBUG
||||||| base
                        }
                    },
                    distance = 1.5,
                })
            end
        end
        if Config.Debug then lib.print.info('Registerd all Plant Targets') end -- DEBUG
    elseif Config.Target == 'ox_target' then
        if Config.Debug then lib.print.info('Detected Target System: ox_target') end -- DEBUG
=======
                            TriggerEvent('it-drugs:client:showPlantMenu', plantData)
                        end
                    end, networkId)
                end,
                canInteract = function(_, _)
                    return true
                end,
                distance = 1.5
            }
        })
    end
end
>>>>>>> upstream

<<<<<<< fork
        if not exports.ox_target then
            if Config.Debug then lib.print.info(_U('DEBUG__TARGET_SYSTEM_STATUS'):format('false')) end -- DEBUG
        else
            if Config.Debug then lib.print.info(_U('DEBUG__TARGET_SYSTEM_STATUS'):format('true')) end -- DEBUG
        end
        -- Check if ox target is running
        if not exports.ox_target then return end
        for k, v in pairs(Config.PlantTypes) do
            for _, plant in pairs(v) do
                exports.ox_target:addModel(plant[1], {
                    {
                        label = _U('TARGET__PLANT__LABEL'),
                        name = 'it-drugs-check-plant',
                        icon = 'fas fa-eye',
                        onSelect = function(data)
                            TriggerEvent('it-drugs:client:checkPlant', {entity = data.entity})
                        end,
                        distance = 1.5
                    }
                })
            end
||||||| base
        if not exports.ox_target then 
            if Config.Debug then lib.print.info('Target System Running: false') end -- DEBUG
        else 
            if Config.Debug then lib.print.info('Target System Running: true') end -- DEBUG
        end
        -- Check if ox target is running
        if not exports.ox_target then return end
        for k, v in pairs(Config.PlantTypes) do
            for _, plant in pairs(v) do
                exports.ox_target:addModel(plant[1], {
                    {
                        label = _U('TARGET__PLANT__LABEL'),
                        name = 'it-drugs-check-plant',
                        icon = 'fas fa-eye',
                        onSelect = function(data)
                            TriggerEvent('it-drugs:client:checkPlant', {entity = data.entity})
                        end,
                        distance = 1.5
                    }
                })
            end
=======

local function createDealerTargets()
    for k, v in pairs(Config.DrugDealers) do
        if v.ped ~= nil then
            dealerOptions = exports.it_bridge:AddTargetModel(v.ped, {
                {
                    label = _U('TARGET__DEALER__LABLE'),
                    name = 'it-drugs-talk-dealer',
                    icon = 'fas fa-eye',
                    onSelect = function(_)
                        TriggerEvent('it-drugs:client:showDealerActionMenu', k)
                    end,
                    canInteract = function(_, _)
                        return true
                    end,
                    distance = 1.5
                }
            })
>>>>>>> upstream
        end
    end
<<<<<<< fork
    if Config.Debug then lib.print.info(_U('DEBUG__REGISTERED_ALL_PLANTS')) end -- DEBUG
end)


if Config.EnableDealers then
    CreateThread(function()
        if Config.Target == 'qb-target' then
            for k, v in pairs(Config.DrugDealers) do
                if v.ped ~= nil then
                    exports['qb-target']:AddTargetModel(v.ped, {
                        options = {
                            {
                                icon = 'fas fa-eye',
                                label = _U('TARGET__DEALER__LABEL'),
                                action = function (entity)
                                    TriggerEvent('it-drugs:client:showDealerMenu', k)
                                end
                            }
                        },
                        distance = 1.5,
                    })
                end
            end
        elseif Config.Target == 'ox_target' then
            -- Check if ox target is running
            if not exports.ox_target then return end
            for k, v in pairs(Config.DrugDealers) do
                if v.ped ~= nil then
                    exports.ox_target:addModel(v.ped, {
                        {
                            label = _U('TARGET__DEALER__LABEL'),
                            name = 'it-drugs-talk-dealer',
                            icon = 'fas fa-eye',
                            onSelect = function(data)
                                TriggerEvent('it-drugs:client:showDealerMenu', k)
                            end,
                            distance = 1.5
                        }
                    })
                end
            end
        end
    end)
||||||| base
    if Config.Debug then lib.print.info('Registerd all Plant Targets') end -- DEBUG
end)


if Config.EnableDealers then
    CreateThread(function()
        if Config.Target == 'qb-target' then
            for k, v in pairs(Config.DrugDealers) do
                if v.ped ~= nil then
                    exports['qb-target']:AddTargetModel(v.ped, {
                        options = {
                            {
                                icon = 'fas fa-eye',
                                label = _U('TARGET__DEALER__LABLE'),
                                action = function (entity)
                                    TriggerEvent('it-drugs:client:showDealerMenu', k)
                                end
                            }
                        },
                        distance = 1.5,
                    })
                end
            end
        elseif Config.Target == 'ox_target' then
            -- Check if ox target is running
            if not exports.ox_target then return end
            for k, v in pairs(Config.DrugDealers) do
                if v.ped ~= nil then
                    exports.ox_target:addModel(v.ped, {
                        {
                            label = _U('TARGET__DEALER__LABLE'),
                            name = 'it-drugs-talk-dealer',
                            icon = 'fas fa-eye',
                            onSelect = function(data)
                                TriggerEvent('it-drugs:client:showDealerMenu', k)
                            end,
                            distance = 1.5
                        }
                    })
                end
            end
        end
    end)
=======
>>>>>>> upstream
end

-- ┌────────────────────────────────────────────────────────────────────────────────────┐
-- │ ____                                  _               _____                    _   │
-- │|  _ \ _ __ ___   ___ ___ ___  ___ ___(_)_ __   __ _  |_   _|_ _ _ __ __ _  ___| |_ │
-- │| |_) | '__/ _ \ / __/ __/ _ \/ __/ __| | '_ \ / _` |   | |/ _` | '__/ _` |/ _ \ __|│
-- │|  __/| | | (_) | (_| (_|  __/\__ \__ \ | | | | (_| |   | | (_| | | | (_| |  __/ |_ │
-- │|_|   |_|  \___/ \___\___\___||___/___/_|_| |_|\__, |   |_|\__,_|_|  \__, |\___|\__|│
-- │                                               |___/                 |___/          │
-- └────────────────────────────────────────────────────────────────────────────────────┘
-- Proccesing Target
local function createProccessingTargets()
    for _, v in pairs(Config.ProcessingTables) do
        if v.model ~= nil then
            tableOptions = exports.it_bridge:AddTargetModel(v.model, {
                {
                    label = _U('TARGET__TABLE__LABEL'),
                    name = 'it-drugs-use-table',
                    icon = 'fas fa-eye',
                    onSelect = function(entity)
                        local networkId = NetworkGetNetworkIdFromEntity(entity)
                        lib.callback("it-drugs:server:getTableByNetId", false, function(tableData)
                            if not tableData then
                                lib.print.error('[it-drugs] Unable to get table data by network id')
                            else
                                if Config.Debug then
                                    lib.print.info('[createProccessingTargets] Current table data: ', tableData)
                                end
                                TriggerEvent('it-drugs:client:showRecipesMenu', {tableId = tableData.id})
                            end
                        end, networkId)
                    end,
                    canInteract = function(_, _)
                        return true
                    end,
                    distance = 1.5
                }
            })
        end
    end
end

local function isPedBlacklisted(ped)
	local model = GetEntityModel(ped)
	for i = 1, #Config.BlacklistPeds do
		if model == GetHashKey(Config.BlacklistPeds[i]) then
			return true
		end
	end
	return false
end

-- ┌─────────────────────────────────────────────────────────────┐
-- │ ____       _ _ _               _____                    _   │
-- │/ ___|  ___| | (_)_ __   __ _  |_   _|_ _ _ __ __ _  ___| |_ │
-- │\___ \ / _ \ | | | '_ \ / _` |   | |/ _` | '__/ _` |/ _ \ __|│
-- │ ___) |  __/ | | | | | | (_| |   | | (_| | | | (_| |  __/ |_ │
-- │|____/ \___|_|_|_|_| |_|\__, |   |_|\__,_|_|  \__, |\___|\__|│
-- │                        |___/                 |___/          │
-- └─────────────────────────────────────────────────────────────┘
function CreateSellingTargets()
    sellOptions = exports.it_bridge:AddGlobalPed({
        {
            label = _U('TARGET__SELL__LABEL'),
            name = 'it-drugs-sell',
            icon = 'fas fa-comment',
            onSelect = function(entity)
                TriggerEvent('it-drugs:client:checkSellOffer', entity)
            end,
            canInteract = function(entity, _)
                if not IsPedDeadOrDying(entity, false) and not IsPedInAnyVehicle(entity, false) and (GetPedType(entity)~=28) and (not IsPedAPlayer(entity)) and (not isPedBlacklisted(entity)) and not IsPedInAnyVehicle(PlayerPedId(), false) then
                    return true
                end
                return false
            end,
            distance = 4
        }
    })
end

if Config.EnableDealers then
    createDealerTargets()
end
if Config.EnableProcessing then
    createProccessingTargets()
end

for _, dealerData in pairs(Config.DrugDealers) do
    if dealerData.ped ~= nil then
        table.insert(Config.BlacklistPeds, dealerData.ped)
    end
end

if Config.EnableSelling and Config.SellEverywhere['enabled'] then
    CreateSellingTargets()
end

RemoveSellTarget = function()
    exports.it_bridge:RemoveGlobalPed(sellOptions)
end

-- Remove all Targets
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, v in pairs(Config.PlantTypes) do
        for _, plant in pairs(v) do
            exports.it_bridge:RemoveTargetModel(plant[1], plantOptions)
            
        end
    end
    
    if Config.EnableProcessing then
        for _, v in pairs(Config.ProcessingTables) do
            if v.model ~= nil then
                exports.it_bridge:RemoveTargetModel(v.model, tableOptions)
            end
        end
    end

    if Config.EnableDealers then
        for k, v in pairs(Config.DrugDealers) do
            if v.ped ~= nil then
                exports.it_bridge:RemoveTargetModel(v.ped, dealerOptions)
            end
        end
    end
    if Config.EnableSelling then
        RemoveSellTarget()
    end
end)