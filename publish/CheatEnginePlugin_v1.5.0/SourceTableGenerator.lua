--[[
  Source Table Generator
  Plugin pour Cheat Engine permettant de générer rapidement des tables pour les jeux Source Engine
  
  Fonctionnalités:
  - Détection automatique des jeux Source
  - Scan automatique des pointeurs et structures communes
  - Interface utilisateur pour ajouter facilement des entrées à la table
  - Modèles prédéfinis pour les jeux Source populaires
  - Export/Import de configurations
]]

-- Variables globales
local SourceTableGenerator = {}
SourceTableGenerator.GameProfiles = {
  ["BlackMesa"] = {
    processName = "bms.exe",
    clientModule = "client.dll",
    engineModule = "engine.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "8B 0D ? ? ? ? 83 C4 ? 8B 01 FF 90", offset = 2},
      ["EntityList"] = {signature = "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08", offset = 1},
      ["ViewMatrix"] = {signature = "0F 10 05 ? ? ? ? 8D 85", offset = 3}
    },
    commonStructures = {
      ["Player"] = {
        {name = "Health", offset = 0x100, type = vtByte},
        {name = "Team", offset = 0x128, type = vtInt},
        {name = "Position", offset = 0x138, type = vtSingle, isVector = true},
        {name = "Velocity", offset = 0x144, type = vtSingle, isVector = true},
        {name = "ViewAngles", offset = 0x158, type = vtSingle, isVector = true}
      },
      ["Weapon"] = {
        {name = "Clip", offset = 0x15C0, type = vtInt},
        {name = "Ammo", offset = 0x15C4, type = vtInt}
      }
    }
  },
  ["HalfLife2"] = {
    processName = "hl2.exe",
    clientModule = "client.dll",
    engineModule = "engine.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "8B 0D ? ? ? ? 83 C4 ? 8B 01 FF 90", offset = 2},
      ["EntityList"] = {signature = "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08", offset = 1}
    }
  },
  ["CSGO"] = {
    processName = "csgo.exe",
    clientModule = "client.dll",
    engineModule = "engine.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "A1 ? ? ? ? 33 C9 83 C4", offset = 1},
      ["EntityList"] = {signature = "B9 ? ? ? ? E8 ? ? ? ? 83 7D DC 00", offset = 1},
      ["ViewMatrix"] = {signature = "0F 10 05 ? ? ? ? 8D 85 ? ? ? ? B9", offset = 3}
    }
  },
  ["CS2"] = {
    processName = "cs2.exe",
    clientModule = "client.dll",
    engineModule = "engine2.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "48 8B 05 ? ? ? ? 48 8B 88 ? ? ? ? 48 85 C9 74 06 48 8B 01", offset = 3},
      ["EntityList"] = {signature = "48 8B 0D ? ? ? ? 48 89 7C 24 ? 8B FA C1 EB", offset = 3},
      ["ViewMatrix"] = {signature = "48 8D 0D ? ? ? ? 48 C1 E0 06", offset = 3}
    },
    commonStructures = {
      ["Player"] = {
        {name = "Health", offset = 0x32C, type = vtInt},
        {name = "Team", offset = 0x3BF, type = vtByte},
        {name = "Position", offset = 0x1224, type = vtSingle, isVector = true},
        {name = "ViewAngles", offset = 0x1510, type = vtSingle, isVector = true}
      }
    }
  }
}

-- Fonctions utilitaires
function SourceTableGenerator.GetModuleBase(moduleName)
  -- Utiliser une méthode alternative pour obtenir l'adresse de base du module
  -- Cette fonction sera appelée plus tard avec les informations fournies par l'utilisateur
  
  -- Pour l'instant, nous pouvons utiliser getAddress qui est plus fiable
  -- Si le module est chargé, getAddress devrait pouvoir le trouver
  local moduleAddress = getAddress(moduleName)
  if moduleAddress ~= nil and moduleAddress ~= 0 then
    return moduleAddress
  end
  
  -- Sinon, demander à l'utilisateur de fournir l'adresse
  local result = inputQuery("Adresse du module", "Veuillez entrer l'adresse de base de " .. moduleName .. " (en hexadécimal):", "")
  if result then
    local address = tonumber(result, 16)
    if address then
      return address
    end
  end
  
  return nil
end

function SourceTableGenerator.FindSignature(signature, moduleBase, moduleSize)
  -- Vérifier si moduleBase est nil
  if moduleBase == nil then
    return nil
  end
  
  -- Si moduleSize n'est pas fourni, utiliser une taille par défaut
  if moduleSize == nil then
    moduleSize = 0x1000000 -- 16 MB, taille raisonnable pour la plupart des modules
  end
  
  local scanResult = AOBScan(signature, '+W', 0, moduleBase, moduleBase + moduleSize)
  if scanResult == nil or scanResult.Count == 0 then
    return nil
  end
  return scanResult[0]
end

function SourceTableGenerator.ReadPointer(address, offset)
  if offset then
    local pointerOffset = readInteger(address + offset)
    if pointerOffset then
      return address + offset + 4 + pointerOffset
    end
  end
  return readPointer(address)
end

function SourceTableGenerator.DetectGame()
  -- Utiliser une approche plus simple pour détecter le jeu
  -- Vérifier si nous pouvons obtenir le nom du processus d'une autre manière
  -- Par exemple, en demandant à l'utilisateur de sélectionner le jeu manuellement
  
  -- Cette fonction sera appelée plus tard lorsque l'utilisateur sélectionnera un jeu dans l'interface
  return nil, nil
end

function SourceTableGenerator.AddVectorEntry(name, address, description)
  local entry = AddressList.createMemoryRecord()
  entry.Description = description or name
  entry.Address = string.format("%X", address)
  entry.Type = vtSingle
  entry.IsGroupHeader = true
  entry.Options = "moHideChildren"
  
  local xEntry = AddressList.createMemoryRecord()
  xEntry.Description = "X"
  xEntry.Address = string.format("%X", address)
  xEntry.Type = vtSingle
  
  local yEntry = AddressList.createMemoryRecord()
  yEntry.Description = "Y"
  yEntry.Address = string.format("%X", address + 4)
  yEntry.Type = vtSingle
  
  local zEntry = AddressList.createMemoryRecord()
  zEntry.Description = "Z"
  zEntry.Address = string.format("%X", address + 8)
  zEntry.Type = vtSingle
  
  entry.appendToEntry(xEntry)
  entry.appendToEntry(yEntry)
  entry.appendToEntry(zEntry)
  
  return entry
end

function SourceTableGenerator.AddStructureToTable(name, baseAddress, structure)
  local header = AddressList.createMemoryRecord()
  header.Description = name
  header.Address = string.format("%X", baseAddress)
  header.Type = vtAutoAssembler
  header.IsGroupHeader = true
  
  for _, field in ipairs(structure) do
    local entry
    local address = baseAddress + field.offset
    
    if field.isVector then
      entry = SourceTableGenerator.AddVectorEntry(field.name, address, field.name)
    else
      entry = AddressList.createMemoryRecord()
      entry.Description = field.name
      entry.Address = string.format("%X", address)
      entry.Type = field.type
    end
    
    header.appendToEntry(entry)
  end
  
  return header
end

-- Interface utilisateur
function SourceTableGenerator.CreateMenu()
  local mainForm = createForm(true)
  mainForm.Caption = "Source Table Generator"
  mainForm.Width = 500
  mainForm.Height = 400
  
  -- Créer les contrôles
  local gameLabel = createLabel(mainForm)
  gameLabel.Caption = "Jeu:"
  gameLabel.Left = 10
  gameLabel.Top = 10
  
  local gameComboBox = createComboBox(mainForm)
  gameComboBox.Left = 10
  gameComboBox.Top = 30
  gameComboBox.Width = 200
  
  local scanButton = createButton(mainForm)
  scanButton.Caption = "Scanner"
  scanButton.Left = 220
  scanButton.Top = 30
  scanButton.Width = 100
  
  local generateButton = createButton(mainForm)
  generateButton.Caption = "Générer Table"
  generateButton.Left = 330
  generateButton.Top = 30
  generateButton.Width = 150
  generateButton.Enabled = false
  
  local progressBar = createProgressBar(mainForm)
  progressBar.Left = 10
  progressBar.Top = 70
  progressBar.Width = 470
  
  local resultsMemo = createMemo(mainForm)
  resultsMemo.Left = 10
  resultsMemo.Top = 100
  resultsMemo.Width = 470
  resultsMemo.Height = 250
  resultsMemo.ReadOnly = true
  
  -- Sélectionner le premier jeu par défaut
  gameComboBox.Text = "Sélectionnez un jeu"
  
  -- Remplir la liste des jeux
  for name, _ in pairs(SourceTableGenerator.GameProfiles) do
    gameComboBox.Items.add(name)
  end
  
  -- Événements
  scanButton.OnClick = function()
    local selectedGame = gameComboBox.Text
    local profile = SourceTableGenerator.GameProfiles[selectedGame]
    
    if not profile then
      messageDialog("Veuillez sélectionner un jeu valide", mtError, mbOK)
      return
    end
    
    resultsMemo.Lines.Clear()
    resultsMemo.Lines.add("Début du scan pour " .. selectedGame .. "...")
    progressBar.Position = 0
    
    -- Trouver les modules
    local clientBase = SourceTableGenerator.GetModuleBase(profile.clientModule)
    local engineBase = SourceTableGenerator.GetModuleBase(profile.engineModule)
    
    if not clientBase then
      resultsMemo.Lines.add("Erreur: Module client non trouvé!")
      return
    end
    
    if not engineBase then
      resultsMemo.Lines.add("Erreur: Module engine non trouvé!")
      return
    end
    
    resultsMemo.Lines.add("Module client: " .. string.format("%X", clientBase))
    resultsMemo.Lines.add("Module engine: " .. string.format("%X", engineBase))
    
    -- Scan des pointeurs communs
    local foundPointers = {}
    local totalPointers = 0
    for _, _ in pairs(profile.commonPointers) do
      totalPointers = totalPointers + 1
    end
    
    local pointerIndex = 0
    for name, info in pairs(profile.commonPointers) do
      pointerIndex = pointerIndex + 1
      progressBar.Position = math.floor((pointerIndex / totalPointers) * 100)
      
      resultsMemo.Lines.add("Recherche de " .. name .. "...")
      local moduleBase = name:find("View") and engineBase or clientBase
      -- Utiliser une taille par défaut au lieu de getModuleSize
      -- local moduleSize = name:find("View") and getModuleSize(profile.engineModule) or getModuleSize(profile.clientModule)
      local moduleSize = 0x1000000 -- 16 MB, taille raisonnable pour la plupart des modules
      
      local address = SourceTableGenerator.FindSignature(info.signature, moduleBase, moduleSize)
      if address then
        local pointerAddress = SourceTableGenerator.ReadPointer(address, info.offset)
        if pointerAddress then
          foundPointers[name] = pointerAddress
          resultsMemo.Lines.add("  Trouvé à " .. string.format("%X", pointerAddress))
        else
          resultsMemo.Lines.add("  Pointeur non trouvé!")
        end
      else
        resultsMemo.Lines.add("  Signature non trouvée!")
      end
    end
    
    -- Activer le bouton de génération si des pointeurs ont été trouvés
    if next(foundPointers) then
      generateButton.Enabled = true
      SourceTableGenerator.FoundPointers = foundPointers
      SourceTableGenerator.CurrentProfile = profile
    end
    
    resultsMemo.Lines.add("Scan terminé!")
    progressBar.Position = 100
  end
  
  generateButton.OnClick = function()
    -- Créer une nouvelle table
    local tableName = gameComboBox.Text .. " Table"
    AddressList.Clear()
    
    -- Ajouter les pointeurs trouvés
    for name, address in pairs(SourceTableGenerator.FoundPointers) do
      local entry = AddressList.createMemoryRecord()
      entry.Description = name
      entry.Address = string.format("%X", address)
      entry.Type = vtPointer
      entry.IsGroupHeader = true
      
      -- Si c'est un pointeur vers une structure connue, ajouter les champs
      if name == "LocalPlayer" and SourceTableGenerator.CurrentProfile.commonStructures and SourceTableGenerator.CurrentProfile.commonStructures["Player"] then
        local playerStructure = SourceTableGenerator.CurrentProfile.commonStructures["Player"]
        for _, field in ipairs(playerStructure) do
          local fieldEntry
          
          if field.isVector then
            local vectorAddress = string.format("%X+%X", entry.Address, field.offset)
            fieldEntry = SourceTableGenerator.AddVectorEntry(field.name, vectorAddress, field.name)
          else
            fieldEntry = AddressList.createMemoryRecord()
            fieldEntry.Description = field.name
            fieldEntry.Address = string.format("%X+%X", entry.Address, field.offset)
            fieldEntry.Type = field.type
          end
          
          entry.appendToEntry(fieldEntry)
        end
      end
    end
    
    messageDialog("Table générée avec succès!", mtInformation, mbOK)
  end
  
  mainForm.show()
end

-- Enregistrement du plugin dans Cheat Engine
local mi = createMenuItem(MainForm.Menu)
mi.Caption = "Source Table Generator"
MainForm.Menu.Items.insert(MainForm.Menu.Items.Count-1, mi)

mi.OnClick = function()
  SourceTableGenerator.CreateMenu()
end

-- Fonction d'initialisation appelée au chargement du plugin
function SourceTableGenerator.Initialize()
  print("Source Table Generator chargé avec succès!")
end

SourceTableGenerator.Initialize()

return SourceTableGenerator
