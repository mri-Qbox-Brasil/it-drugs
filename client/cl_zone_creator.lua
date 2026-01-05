ZoneCreator = ZoneCreator or {}

local isCreating = false
local points = {}
local currentThickness = 10.0
local helpModalOpen = false

local freecamActive = false
local freecam = nil
local camCoords = vector3(0.0, 0.0, 0.0)
local camRot = vector3(0.0, 0.0, 0.0)
local camFov = 50.0
local camSpeed = 0.5
local rotationSpeed = 2.0

print('[IT-DRUGS ZONE_CREATOR] Módulo de criação de zonas poligonais carregado')

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoord()
    local distance = #(camCoords - vector3(x, y, z))
    
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function DrawText2D(x, y, text, scale, font, color, outline, center)
    scale = scale or 0.4
    font = font or 4
    color = color or {r = 255, g = 255, b = 255, a = 255}
    outline = outline ~= false
    center = center or false
    
    SetTextFont(font)
    SetTextProportional(1)
    SetTextScale(0.0, scale)
    SetTextColour(color.r, color.g, color.b, color.a)
    if outline then
        SetTextOutline()
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    SetTextEntry("STRING")
    if center then
        SetTextCentre(1)
    end
    AddTextComponentString(text)
    DrawText(x, y)
end

local function DrawInstructionsUI(pointsCount, thickness, fov)
    local screenW, screenH = GetActiveScreenResolution()
    if not screenW or screenW == 0 then screenW = 1920 end
    if not screenH or screenH == 0 then screenH = 1080 end
    
    local scaleX = screenW / 1920.0
    local scaleY = screenH / 1080.0
    
    local boxX = 20.0
    local boxY = 20.0
    local boxW = 500.0 * scaleX
    local boxH = 320.0 * scaleY
    
    DrawRect(boxX + boxW/2, boxY + boxH/2, boxW, boxH, 0, 0, 0, 180)
    DrawRect(boxX + boxW/2, boxY + 12, boxW, 24, 57, 136, 255, 220)
    
    DrawText2D(boxX + 10, boxY + 5, "~b~CÂMERA LIVRE - CRIAR ZONA DE DROGAS", 0.5, 4, {r = 255, g = 255, b = 255, a = 255}, true, false)
    
    local yOffset = 35
    DrawText2D(boxX + 10, boxY + yOffset, string.format("~w~Pontos: ~g~%d ~w~| ~w~Altura: ~g~%.1fm ~w~| ~w~FOV: ~g~%.0f°", pointsCount, thickness, fov), 0.35, 4, {r = 255, g = 255, b = 255, a = 255}, true, false)
    
    yOffset = yOffset + 30
    DrawText2D(boxX + 10, boxY + yOffset, "~b~MOVIMENTAÇÃO:", 0.38, 4, {r = 255, g = 255, b = 255, a = 255}, true, false)
    yOffset = yOffset + 20
    DrawText2D(boxX + 15, boxY + yOffset, "~w~[WASD] ~s~Mover câmera  ~w~[Shift/Ctrl] ~s~Subir/Descer  ~w~[Alt] ~s~Velocidade", 0.32, 4, {r = 200, g = 200, b = 200, a = 255}, false, false)
    
    yOffset = yOffset + 25
    DrawText2D(boxX + 10, boxY + yOffset, "~b~ROTAÇÃO E ZOOM:", 0.38, 4, {r = 255, g = 255, b = 255, a = 255}, true, false)
    yOffset = yOffset + 20
    DrawText2D(boxX + 15, boxY + yOffset, "~w~[Mouse] ~s~Rotacionar  ~w~[Setas] ~s~Rotacionar  ~w~[Scroll/+/-] ~s~Zoom", 0.32, 4, {r = 200, g = 200, b = 200, a = 255}, false, false)
    
    yOffset = yOffset + 25
    DrawText2D(boxX + 10, boxY + yOffset, "~b~AÇÕES:", 0.38, 4, {r = 255, g = 255, b = 255, a = 255}, true, false)
    yOffset = yOffset + 20
    DrawText2D(boxX + 15, boxY + yOffset, "~w~[E] ~g~Adicionar Ponto  ~w~[G] ~y~Finalizar  ~w~[X] ~r~Cancelar  ~w~[Backspace] ~o~Remover", 0.32, 4, {r = 200, g = 200, b = 200, a = 255}, false, false)
    
    yOffset = yOffset + 25
    DrawText2D(boxX + 15, boxY + yOffset, "~w~[Page Up/Down] ~s~Ajustar Altura", 0.32, 4, {r = 200, g = 200, b = 200, a = 255}, false, false)
end

local function DrawPolygon()
    if #points < 2 then return end
    
    for i = 1, #points do
        local p1 = points[i]
        local p2 = points[(i % #points) + 1]
        
        local onScreen1, screenX1, screenY1 = World3dToScreen2d(p1.x, p1.y, p1.z)
        local onScreen2, screenX2, screenY2 = World3dToScreen2d(p2.x, p2.y, p2.z)
        
        if onScreen1 and onScreen2 then
            DrawLine(screenX1, screenY1, screenX2, screenY2, 255, 0, 0, 200)
        end
        
        local onScreen1Top, screenX1Top, screenY1Top = World3dToScreen2d(p1.x, p1.y, p1.z + currentThickness)
        local onScreen2Top, screenX2Top, screenY2Top = World3dToScreen2d(p2.x, p2.y, p2.z + currentThickness)
        
        if onScreen1Top and onScreen2Top then
            DrawLine(screenX1Top, screenY1Top, screenX2Top, screenY2Top, 0, 255, 0, 200)
        end
    end
    
    for i, point in ipairs(points) do
        DrawMarker(1, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 200, false, true, 2, false, nil, nil, false)
        
        DrawMarker(1, point.x, point.y, point.z + currentThickness, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 150, false, true, 2, false, nil, nil, false)
        
        local onScreenBottom, screenXBottom, screenYBottom = World3dToScreen2d(point.x, point.y, point.z)
        local onScreenTop, screenXTop, screenYTop = World3dToScreen2d(point.x, point.y, point.z + currentThickness)
        
        if onScreenBottom and onScreenTop then
            DrawLine(screenXBottom, screenYBottom, screenXTop, screenYTop, 255, 255, 0, 150)
        end
        
        DrawText3D(point.x, point.y, point.z + 1.0, string.format("Ponto %d", i))
    end
end

local function GetGroundZ(x, y, z)
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if found then
        return groundZ
    end
    return z
end

local function StartFreecam()
    if freecam then
        DestroyCam(freecam, false)
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    camCoords = vector3(coords.x, coords.y, coords.z + 5.0)
    camRot = vector3(0.0, 0.0, GetEntityHeading(ped))
    camFov = 50.0
    
    freecam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(freecam, camCoords.x, camCoords.y, camCoords.z)
    SetCamRot(freecam, camRot.x, camRot.y, camRot.z, 2)
    SetCamFov(freecam, camFov)
    SetCamActive(freecam, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    freecamActive = true
    
    SetEntityAlpha(ped, 0, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
end

local function StopFreecam()
    if freecam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(freecam, false)
        freecam = nil
    end
    
    freecamActive = false
    
    local ped = PlayerPedId()
    SetEntityAlpha(ped, 255, false)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
end

local function GetCamForwardVector(rot)
    local radX = math.rad(rot.x)
    local radZ = math.rad(rot.z)
    
    return vector3(
        -math.sin(radZ) * math.cos(radX),
        math.cos(radZ) * math.cos(radX),
        math.sin(radX)
    )
end

local function UpdateFreecam()
    if not freecamActive or not freecam then return end
    
    local forward = vector3(0.0, 0.0, 0.0)
    local right = vector3(0.0, 0.0, 0.0)
    local up = vector3(0.0, 0.0, 0.0)
    
    local camForward = GetCamForwardVector(camRot)
    local camRight = vector3(-math.cos(math.rad(camRot.z)), -math.sin(math.rad(camRot.z)), 0.0)
    
    if IsControlPressed(0, 32) then
        forward = camForward
    elseif IsControlPressed(0, 33) then
        forward = camForward * -1.0
    end
    
    if IsControlPressed(0, 34) then
        right = camRight
    elseif IsControlPressed(0, 35) then
        right = camRight * -1.0
    end
    
    if IsControlPressed(0, 21) then
        up = vector3(0.0, 0.0, 1.0)
    elseif IsControlPressed(0, 36) then
        up = vector3(0.0, 0.0, -1.0)
    end
    
    local moveVector = forward + right + up
    if moveVector.x ~= 0 or moveVector.y ~= 0 or moveVector.z ~= 0 then
        local moveSpeed = camSpeed
        if IsControlPressed(0, 19) then
            moveSpeed = moveSpeed * 3.0
        end
        camCoords = camCoords + (moveVector * moveSpeed)
    end
    
    DisableControlAction(0, 1, true)
    DisableControlAction(0, 2, true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 106, true)
    
    local rotX = 0.0
    local rotZ = 0.0
    
    local mouseX = GetDisabledControlNormal(0, 1) * rotationSpeed * 5.0
    local mouseY = GetDisabledControlNormal(0, 2) * rotationSpeed * 5.0
    
    if math.abs(mouseX) > 0.01 or math.abs(mouseY) > 0.01 then
        rotZ = rotZ - mouseX
        rotX = rotX - mouseY
    end
    
    if IsControlPressed(0, 172) then
        rotX = rotX - rotationSpeed
    elseif IsControlPressed(0, 173) then
        rotX = rotX + rotationSpeed
    end
    
    if IsControlPressed(0, 174) then
        rotZ = rotZ + rotationSpeed
    elseif IsControlPressed(0, 175) then
        rotZ = rotZ - rotationSpeed
    end
    
    camRot = vector3(
        math.max(-90.0, math.min(90.0, camRot.x + rotX)),
        camRot.y,
        camRot.z + rotZ
    )
    
    DisableControlAction(0, 14, true)
    DisableControlAction(0, 15, true)
    
    local scroll = GetDisabledControlNormal(0, 14) - GetDisabledControlNormal(0, 15)
    if math.abs(scroll) > 0.01 then
        camFov = math.max(10.0, math.min(120.0, camFov - scroll * 3.0))
    end
    
    if IsControlPressed(0, 96) then
        camFov = math.max(10.0, camFov - 1.0)
    elseif IsControlPressed(0, 97) then
        camFov = math.min(120.0, camFov + 1.0)
    end
    
    SetCamCoord(freecam, camCoords.x, camCoords.y, camCoords.z)
    SetCamRot(freecam, camRot.x, camRot.y, camRot.z, 2)
    SetCamFov(freecam, camFov)
end

local function GetCameraTargetPosition()
    if freecamActive and freecam then
        local camForward = GetCamForwardVector(camRot)
        local distance = 5.0
        
        local targetPos = camCoords + (camForward * distance)
        local groundZ = GetGroundZ(targetPos.x, targetPos.y, targetPos.z)
        
        return vector3(targetPos.x, targetPos.y, groundZ)
    end
    return nil
end

-- Função para mostrar modal de ajuda com as teclas
local function ShowHelpModal()
    if helpModalOpen then return end
    
    helpModalOpen = true
    
    lib.alertDialog({
        header = '🎮 Controles - Criação de Zona',
        content = 
            '📌 AÇÕES PRINCIPAIS:\n' ..
            '[E] - Adicionar Ponto\n' ..
            '[G] - Finalizar e Criar Zona (mínimo 3 pontos)\n' ..
            '[X] - Cancelar Criação\n' ..
            '[Backspace] - Remover Último Ponto\n' ..
            '[H] - Mostrar esta ajuda\n\n' ..
            '🎥 MOVIMENTAÇÃO DA CÂMERA:\n' ..
            '[WASD] - Mover Câmera\n' ..
            '[Shift] - Subir\n' ..
            '[Ctrl] - Descer\n' ..
            '[Alt] - Aumentar Velocidade\n\n' ..
            '🔄 ROTAÇÃO E ZOOM:\n' ..
            '[Mouse] - Rotacionar Câmera\n' ..
            '[Setas] - Rotacionar Câmera\n' ..
            '[Scroll] - Zoom In/Out\n' ..
            '[+/-] - Zoom In/Out\n\n' ..
            '📏 AJUSTES:\n' ..
            '[Page Up] - Aumentar Altura da Zona\n' ..
            '[Page Down] - Diminuir Altura da Zona',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Fechar',
            confirm = 'Entendi'
        }
    })
    
    helpModalOpen = false
end

function ZoneCreator.startCreator(options)
    options = options or {}
    local onCreated = options.onCreated
    local onCanceled = options.onCanceled
    
    if isCreating then
        lib.notify({ type = 'error', description = 'Já existe uma criação de zona em andamento!' })
        return
    end
    
    isCreating = true
    points = {}
    
    -- Carregar pontos iniciais se fornecidos (para edição)
    if options.initialPoints and #options.initialPoints > 0 then
        for _, point in ipairs(options.initialPoints) do
            table.insert(points, vector3(point.x, point.y, point.z))
        end
    end
    
    currentThickness = options.thickness or 10.0
    
    StartFreecam()
    
    -- Mostrar modal de ajuda automaticamente
    Wait(500) -- Pequeno delay para garantir que a câmera está ativa
    ShowHelpModal()
    
    lib.notify({ 
        type = 'info', 
        description = 'Modo de Criação de Zona Ativado\n[E] Adicionar Ponto | [G] Finalizar | [X] Cancelar\n[WASD] Mover | [Setas] Rotacionar | [Scroll] Zoom\nPressione [H] para ver os controles novamente' 
    })
    
    CreateThread(function()
        while isCreating do
            Wait(0)
            
            UpdateFreecam()
            
            local previewPoint = GetCameraTargetPosition()
            
            if previewPoint then
                DrawMarker(1, previewPoint.x, previewPoint.y, previewPoint.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 255, 200, false, true, 2, false, nil, nil, false)
                DrawText3D(previewPoint.x, previewPoint.y, previewPoint.z + 1.0, "Próximo Ponto")
            end
            
            DrawPolygon()
            
            if IsControlJustPressed(0, 38) then -- E
                if previewPoint then
                    table.insert(points, previewPoint)
                    lib.notify({ type = 'success', description = string.format('Ponto %d adicionado!', #points) })
                    PlaySoundFrontend(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 1)
                end
            elseif IsControlJustPressed(0, 47) then -- G
                if #points >= 3 then
                    isCreating = false
                    StopFreecam()
                    if onCreated then
                        onCreated({
                            points = points,
                            thickness = currentThickness
                        })
                    end
                    lib.notify({ type = 'success', description = 'Zona criada com sucesso!' })
                    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
                else
                    lib.notify({ type = 'error', description = 'Adicione pelo menos 3 pontos para criar uma zona!' })
                end
            elseif IsControlJustPressed(0, 73) then -- X
                isCreating = false
                StopFreecam()
                points = {}
                lib.notify({ type = 'info', description = 'Criação de zona cancelada.' })
                if onCanceled then
                    onCanceled()
                end
            elseif IsControlJustPressed(0, 194) then -- Backspace
                if #points > 0 then
                    table.remove(points)
                    lib.notify({ type = 'info', description = string.format('Último ponto removido. Pontos restantes: %d', #points) })
                end
            elseif IsControlJustPressed(0, 74) then -- H (para reabrir ajuda)
                ShowHelpModal()
            end
            
            if IsControlPressed(0, 10) then -- Page Up
                currentThickness = math.min(currentThickness + 0.2, 50.0)
            elseif IsControlPressed(0, 11) then -- Page Down
                currentThickness = math.max(currentThickness - 0.2, 1.0)
            end
            
            DrawInstructionsUI(#points, currentThickness, camFov)
        end
        
        StopFreecam()
        helpModalOpen = false
    end)
end

function ZoneCreator.cancel()
    isCreating = false
    points = {}
    StopFreecam()
    helpModalOpen = false
end

print('[IT-DRUGS ZONE_CREATOR] Funções definidas. startCreator disponível: ' .. tostring(ZoneCreator.startCreator ~= nil))

