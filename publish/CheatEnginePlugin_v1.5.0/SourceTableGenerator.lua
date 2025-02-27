-- SourceTableGenerator.lua
-- This script is designed to automatically generate Cheat Engine tables
-- for Valve Source 1 games like Black Mesa, Half-Life 1 and 2.

-- Function to parse signatures
function parseSignatures(signatures)
    -- Placeholder for parsing logic
    -- This function will take a list of signatures and extract necessary information
end

-- Function to create signatures from memory
function createSignatures(memoryData)
    -- Placeholder for signature creation logic
    -- This function will take binary data or memory snapshots
    -- and generate unique signatures
end

-- Function to generate Cheat Engine table
function generateCheatTable(parsedData)
    -- Placeholder for table generation logic
    -- This function will use the parsed data to create a Cheat Engine table
end

-- Function to generate signatures from a base address
function generateSignaturesFromBaseAddress(baseAddress)
    local signatures = {}
    local maxBytes = 0x1000  -- Limite de recherche
    local chunkSize = 16     -- Taille de chaque signature

    -- Fonction pour convertir un byte en hex
    local function byteToHex(byte)
        return string.format("%02X", byte)
    end

    -- Fonction pour lire la mémoire en toute sécurité
    local function safeReadBytes(address, size)
        local bytes = {}
        for i = 0, size - 1 do
            local success, byte = pcall(function()
                return readBytes(address + i, 1, true)[1]
            end)
            if success then
                table.insert(bytes, byte)
            else
                return nil
            end
        end
        return bytes
    end

    -- Fonction pour obtenir le type d'instance à une adresse
    local function getInstanceType(address)
        -- Table des noms de classes connus
        local knownClasses = {
            "CBlackMesaPlayer",
            "CSoundEnt",
            "CPlayerResource",
            "CBM_SP_GameRulesProxy",
            "CAI_NetworkManager",
            "CSteamJet",
            "CFuncWall",
            "CBaseEntity",
            "CBaseAnimating",
            "CBaseFlex",
            "CBasePlayer"
        }
        
        -- Lire le pointeur
        local value = readPointer(address)
        if value then
            -- Lire la vtable
            local vtable = readPointer(value)
            if vtable then
                -- Lire le RTTI
                local rtti = readPointer(vtable - 8)
                if rtti then
                    local classNamePtr = readPointer(rtti + 8)
                    if classNamePtr then
                        -- Lire le nom de la classe
                        local className = readString(classNamePtr + 16)
                        if className then
                            -- Nettoyer le nom de la classe
                            className = className:match("class ([^%s]+)") or className
                            return "Pointer to instance of " .. className
                        end
                    end
                end
                
                -- Si on n'a pas trouvé le nom via RTTI, essayer de deviner par la structure
                for _, className in ipairs(knownClasses) do
                    -- Vérifier si la structure correspond à une classe connue
                    if readBytes(value, 16, true) then  -- Vérifier si on peut lire la mémoire
                        return "Pointer to instance of " .. className
                    end
                end
            end
        end
        
        -- Vérifier si c'est une valeur de 4 bytes
        local value4bytes = readInteger(address)
        if value4bytes then
            return "4 Bytes (Hex)"
        end
        
        return "Pointer"
    end

    -- Génération des signatures
    local currentAddress = baseAddress
    local endAddress = baseAddress + maxBytes

    while currentAddress < endAddress do
        local bytes = safeReadBytes(currentAddress, chunkSize)
        if bytes then
            local signature = ""
            local address = string.format("0x%X", currentAddress)
            
            -- Obtenir le type d'instance
            local instanceType = getInstanceType(currentAddress)
            
            -- Conversion des bytes en signature hex
            for _, byte in ipairs(bytes) do
                signature = signature .. byteToHex(byte) .. " "
            end
            
            -- Ajouter la signature à la liste
            table.insert(signatures, {
                address = address,
                signature = signature:trim(),  -- Enlever l'espace final
                instanceType = instanceType
            })
        end
        
        currentAddress = currentAddress + chunkSize
    end

    return signatures
end

-- Global variables
local processAttached = false
local targetProcess = 'bms.exe'

-- Function to safely check if process exists
function findProcess(processName)
    if getProcessList == nil then return nil end
    local processList = getProcessList()
    for pid, name in pairs(processList) do
        if name:lower() == processName:lower() then
            return pid
        end
    end
    return nil
end

-- Function to safely attach to process
function attachToProcess(pid)
    if openProcess == nil then return false end
    local success = pcall(function() 
        openProcess(pid)
    end)
    return success
end

-- Main UI creation with status updates
function createUI()
    synchronize(function()
        local form = createForm(false)
        form.Caption = 'Black Mesa Signature Generator'
        form.BorderStyle = bsSingle
        form.Width = 500
        form.Height = 500
        form.Position = poScreenCenter
        form.Color = 0x2D2D30

        -- Title and other existing elements remain the same
        local titleLabel = createLabel(form)
        titleLabel.Caption = 'Black Mesa Signature Generator'
        titleLabel.Font.Size = 14
        titleLabel.Font.Color = 0xFFFFFF
        titleLabel.Left = 10
        titleLabel.Top = 10
        titleLabel.Font.Style = '[fsBold]'
        titleLabel.Width = 480

        -- Status panel
        local statusPanel = createPanel(form)
        statusPanel.Left = 10
        statusPanel.Top = 40
        statusPanel.Width = 480
        statusPanel.Height = 60
        statusPanel.BevelOuter = bvNone
        statusPanel.Color = 0x333337

        local statusLabel = createLabel(statusPanel)
        statusLabel.Caption = 'Game Not Detected'
        statusLabel.Font.Size = 10
        statusLabel.Font.Color = 0x0000FF
        statusLabel.Left = 10
        statusLabel.Top = 20
        statusLabel.Font.Style = '[fsBold]'

        -- Input panel
        local inputPanel = createPanel(form)
        inputPanel.Left = 10
        inputPanel.Top = 110
        inputPanel.Width = 480
        inputPanel.Height = 120
        inputPanel.BevelOuter = bvNone
        inputPanel.Color = 0x333337

        local addressLabel = createLabel(inputPanel)
        addressLabel.Caption = 'Base Address (Hex):'
        addressLabel.Font.Color = 0xFFFFFF
        addressLabel.Left = 10
        addressLabel.Top = 15

        local baseAddressInput = createEdit(inputPanel)
        baseAddressInput.Left = 10
        baseAddressInput.Top = 35
        baseAddressInput.Width = 200
        baseAddressInput.Height = 25
        baseAddressInput.Color = 0x252526
        baseAddressInput.Font.Color = 0xFFFFFF
        baseAddressInput.Text = ''

        -- Output panel for signatures
        local outputPanel = createPanel(form)
        outputPanel.Left = 10
        outputPanel.Top = 240
        outputPanel.Width = 480
        outputPanel.Height = 200
        outputPanel.BevelOuter = bvNone
        outputPanel.Color = 0x333337

        local outputLabel = createLabel(outputPanel)
        outputLabel.Caption = 'Generated Signatures:'
        outputLabel.Font.Color = 0xFFFFFF
        outputLabel.Left = 10
        outputLabel.Top = 10

        local outputMemo = createMemo(outputPanel)
        outputMemo.Left = 10
        outputMemo.Top = 30
        outputMemo.Width = 460
        outputMemo.Height = 120
        outputMemo.Color = 0x252526
        outputMemo.Font.Color = 0xFFFFFF
        outputMemo.ReadOnly = true
        outputMemo.ScrollBars = ssBoth

        -- Copy button
        local copyButton = createButton(outputPanel)
        copyButton.Caption = 'Copy All'
        copyButton.Left = 10
        copyButton.Top = 160
        copyButton.Width = 100
        copyButton.Height = 30
        copyButton.Font.Style = '[fsBold]'
        copyButton.OnClick = function()
            if outputMemo.Text ~= '' then
                writeToClipboard(outputMemo.Text)
                showMessage('Signatures copied to clipboard!')
            end
        end

        local generateButton = createButton(inputPanel)
        generateButton.Caption = 'Generate Signatures'
        generateButton.Left = 10
        generateButton.Top = 70
        generateButton.Width = 200
        generateButton.Height = 30
        generateButton.Font.Style = '[fsBold]'

        generateButton.OnClick = function()
            if not processAttached then
                showMessage('Please wait for the game to be detected and attached.')
                return
            end
            
            local baseAddress = tonumber(baseAddressInput.Text, 16)
            if baseAddress then
                -- Disable the button while generating
                generateButton.Enabled = false
                
                -- Clear previous output
                synchronize(function()
                    outputMemo.Lines.Clear()
                    outputMemo.Lines.Add("Generating signatures...")
                end)
                
                -- Generate signatures in a separate thread
                createThread(function()
                    local signatures = generateSignaturesFromBaseAddress(baseAddress)
                    
                    -- Update UI with results
                    synchronize(function()
                        outputMemo.Lines.Clear()
                        if #signatures > 0 then
                            for _, sig in ipairs(signatures) do
                                outputMemo.Lines.Add(string.format("%s - %s", sig.address, sig.instanceType))
                                outputMemo.Lines.Add(string.format("Signature: %s", sig.signature))
                                outputMemo.Lines.Add("") -- Empty line for readability
                            end
                            showMessage(string.format("Generated %d signatures!", #signatures))
                        else
                            outputMemo.Lines.Add("No signatures were generated.")
                            showMessage("No signatures were generated. Please check the base address.")
                        end
                        -- Re-enable the button
                        generateButton.Enabled = true
                    end)
                end)
            else
                showMessage('Invalid base address. Please enter a valid hexadecimal address.')
            end
        end

        -- Status update thread
        local function updateStatus()
            while true do
                local pid = findProcess(targetProcess)
                if pid then
                    if not processAttached then
                        if attachToProcess(pid) then
                            processAttached = true
                            synchronize(function()
                                statusLabel.Caption = 'Attached to Black Mesa'
                                statusLabel.Font.Color = 0x00FF00
                            end)
                        end
                    end
                else
                    processAttached = false
                    synchronize(function()
                        statusLabel.Caption = 'Game Not Detected'
                        statusLabel.Font.Color = 0x0000FF
                    end)
                end
                sleep(5000)
            end
        end

        createThread(function()
            local status, err = pcall(updateStatus)
            if not status then
                synchronize(function()
                    print("Error in update thread: " .. tostring(err))
                end)
            end
        end)

        form.Show()
    end)
end

-- Add menu to Cheat Engine's navigation bar
function addMenu()
    local mainMenu = getMainForm().Menu
    local newMenuItem = createMenuItem(mainMenu)
    newMenuItem.Caption = 'Generate Signatures for Black Mesa'
    newMenuItem.OnClick = function()
        createUI()
    end
    mainMenu.Items.add(newMenuItem)
end

-- Initialize the script
addMenu()
createUI()
