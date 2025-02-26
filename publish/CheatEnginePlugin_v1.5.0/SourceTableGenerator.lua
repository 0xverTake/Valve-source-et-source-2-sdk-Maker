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
  }
}

-- Fonctions utilitaires
function SourceTableGenerator.GetModuleBase(moduleName)
  local modules = enumModules()
  for i=1, #modules do
    if string.lower(modules[i].Name) == string.lower(moduleName) then
      return modules[i].BaseAddress
    end
  end
  return nil
end

function SourceTableGenerator.FindSignature(signature, moduleBase, moduleSize)
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
  local processName = getProcessName()
  for name, profile in pairs(SourceTableGenerator.GameProfiles) do
    if string.lower(processName) == string.lower(profile.processName) then
      return name, profile
    end
  end
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
  mainForm.Position = "poScreenCenter"
  mainForm.BorderStyle = "bsSizeable"
  
  -- Création des composants
  local gameComboBox = createComboBox(mainForm)
  gameComboBox.Parent = mainForm
  gameComboBox.Left = 120
  gameComboBox.Top = 20
  gameComboBox.Width = 200
  
  local gameLabel = createLabel(mainForm)
  gameLabel.Parent = mainForm
  gameLabel.Left = 20
  gameLabel.Top = 23
  gameLabel.Caption = "Jeu détecté:"
  
  local scanButton = createButton(mainForm)
  scanButton.Parent = mainForm
  scanButton.Left = 350
  scanButton.Top = 18
  scanButton.Width = 120
  scanButton.Caption = "Scanner"
  
  local progressBar = createProgressBar(mainForm)
  progressBar.Parent = mainForm
  progressBar.Left = 20
  progressBar.Top = 60
  progressBar.Width = 450
  
  local resultsMemo = createMemo(mainForm)
  resultsMemo.Parent = mainForm
  resultsMemo.Left = 20
  resultsMemo.Top = 100
  resultsMemo.Width = 450
  resultsMemo.Height = 200
  resultsMemo.ReadOnly = true
  resultsMemo.ScrollBars = "ssVertical"
  
  local generateButton = createButton(mainForm)
  generateButton.Parent = mainForm
  generateButton.Left = 20
  generateButton.Top = 320
  generateButton.Width = 220
  generateButton.Caption = "Générer Table"
  generateButton.Enabled = false
  
  local closeButton = createButton(mainForm)
  closeButton.Parent = mainForm
  closeButton.Left = 250
  closeButton.Top = 320
  closeButton.Width = 220
  closeButton.Caption = "Fermer"
  
  -- Détection du jeu
  local gameName, gameProfile = SourceTableGenerator.DetectGame()
  if gameName then
    gameComboBox.Text = gameName
  else
    gameComboBox.Text = "Jeu non reconnu"
  end
  
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
      local moduleSize = name:find("View") and getModuleSize(profile.engineModule) or getModuleSize(profile.clientModule)
      
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
  
  closeButton.OnClick = function()
    mainForm.close()
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
