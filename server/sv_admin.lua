<<<<<<< fork
if it.getCoreName() == 'esx' then

    local ESX = exports['es_extended']:getSharedObject()

    ESX.RegisterCommand({_U('COMMAND__ADMINMENU')}, 'user', function(xPlayer, args, showError)
        local src = xPlayer.source
        if IsPlayerAceAllowed(src, 'admin') then
            if args[1] == nil then
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
                return
            end
            local menuType = args[1]
            if menuType == 'plants' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'plants'})
            elseif menuType == 'tables' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'tables'})
            else
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
            end
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
||||||| base
if it.getCoreName() == 'esx' then

    local ESX = exports['es_extended']:getSharedObject()

    ESX.RegisterCommand({_U('COMMAND__ADMINMENU')}, 'user', function(xPlayer, args, showError)
        local src = xPlayer.source
        if IsPlayerAceAllowed(src, 'it-drugs') then
            if args[1] == nil then
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
                return
            end
            local menuType = args[1]
            if menuType == 'plants' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'plants'})
            elseif menuType == 'tables' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'tables'})
            else
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
            end
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
=======
lib.addCommand(_U('COMMAND__ADMINMENU'), {
    help = _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')),
    params = {
        {
            name = 'type',
            help = 'plants/tables',
            type = 'string',
            optional = false,
        }
    }
}, function(source, args, raw)
    local src = source
    if IsPlayerAceAllowed(src, 'it-drugs') then
        if args.type == nil then
            ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
            return
>>>>>>> upstream
        end
<<<<<<< fork
    end, {help = _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), validate = true, arguments = {{name = 'type', help = 'plants/tables', type = 'string', optional = false, default = 'plants'}}})

    ESX.RegisterCommand({_U('COMMAND__GROUNDHASH')}, 'user', function(xPlayer, args, showError)
        local src = xPlayer.source
        if IsPlayerAceAllowed(src, 'admin') then
            TriggerClientEvent('it-drugs:client:showGroundHash', src)
||||||| base
    end, {help = _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), validate = true, arguments = {{name = 'type', help = 'plants/tables', type = 'string', optional = false, default = 'plants'}}})

    ESX.RegisterCommand({_U('COMMAND__GROUNDHASH')}, 'user', function(xPlayer, args, showError)
        local src = xPlayer.source
        if IsPlayerAceAllowed(src, 'it-drugs') then
            TriggerClientEvent('it-drugs:client:showGroundHash', src)
=======
        local menuType = args.type
        if menuType == 'plants' then
            TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'plants'})
        elseif menuType == 'tables' then
            TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'tables'})
>>>>>>> upstream
        else
            ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
        end
    else
        -- get user license
        local userLicense = GetPlayerIdentifiers(src)[1]
        local username = GetPlayerName(src)

        TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
    end
end)

<<<<<<< fork
    QbCore.Commands.Add(_U('COMMAND__ADMINMENU'), _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), {{name= 'type', help = 'plants/tables'}}, true, function(source, args)
        local src = source
        if IsPlayerAceAllowed(src, 'admin') then
    
            if args[1] == nil then
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
                return
            end
            local menuType = args[1]
            if menuType == 'plants' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'plants'})
            elseif menuType == 'tables' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'tables'})
            else
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
            end
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
        end
    end)
||||||| base
    QbCore.Commands.Add(_U('COMMAND__ADMINMENU'), _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), {{name= 'type', help = 'plants/tables'}}, true, function(source, args)
        local src = source
        if IsPlayerAceAllowed(src, 'it-drugs') then
    
            if args[1] == nil then
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
                return
            end
            local menuType = args[1]
            if menuType == 'plants' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'plants'})
            elseif menuType == 'tables' then
                TriggerClientEvent('it-drugs:client:showMainAdminMenu', src, {menuType = 'tables'})
            else
                ShowNotification(src, _U('NOTIFICATION__ADMINMENU__USAGE'):format(_U('COMMAND__ADMINMENU')), "info")
            end
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
        end
    end)
=======
lib.addCommand(_U('COMMAND__GROUNDHASH'), {
    help = _U('COMMAND__GROUNDHASH__HELP')
}, function(source, args, raw)
    local src = source
    if IsPlayerAceAllowed(src, 'it-drugs') then
        TriggerClientEvent('it-drugs:client:showGroundHash', src)
    else
        -- get user license
        local userLicense = GetPlayerIdentifiers(src)[1]
        local username = GetPlayerName(src)
>>>>>>> upstream

<<<<<<< fork
    QbCore.Commands.Add(_U('COMMAND__GROUNDHASH'), _U('COMMAND__GROUNDHASH__HELP'), {}, false, function(source, args)
        local src = source
        if IsPlayerAceAllowed(src, 'admin') then
            TriggerClientEvent('it-drugs:client:showGroundHash', src)
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
        end
    end)
end
||||||| base
    QbCore.Commands.Add(_U('COMMAND__GROUNDHASH'), _U('COMMAND__GROUNDHASH__HELP'), {}, false, function(source, args)
        local src = source
        if IsPlayerAceAllowed(src, 'it-drugs') then
            TriggerClientEvent('it-drugs:client:showGroundHash', src)
        else
            -- get user license
            local userLicense = GetPlayerIdentifiers(src)[1]
            local username = GetPlayerName(src)
    
            TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
        end
    end)
end
=======
        TriggerClientEvent('it-drugs:client:showAdminAlertBox', src, {userLicense = userLicense, username = username})
    end
end)
>>>>>>> upstream
