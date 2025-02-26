--[[
  Exemple d'extension du plugin Source Table Generator
  Ce fichier montre comment ajouter des signatures personnalisées pour des jeux spécifiques
]]

-- Fonction pour attendre que le plugin principal soit chargé
local function waitForSourceTableGenerator()
  if SourceTableGenerator then
    initializeCustomSignatures()
  else
    -- Attendre et réessayer après un court délai
    local timer = createTimer(nil)
    timer.Interval = 1000 -- 1 seconde
    timer.OnTimer = function()
      if SourceTableGenerator then
        timer.Enabled = false
        initializeCustomSignatures()
      end
    end
    timer.Enabled = true
  end
end

-- Fonction d'initialisation des signatures personnalisées
function initializeCustomSignatures()
  -- Ajouter un nouveau jeu
  SourceTableGenerator.GameProfiles["GarrysMod"] = {
    processName = "gmod.exe",
    clientModule = "client.dll",
    engineModule = "engine.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "8B 0D ? ? ? ? 83 C4 ? 8B 01 FF 90", offset = 2},
      ["EntityList"] = {signature = "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08", offset = 1},
      ["ViewMatrix"] = {signature = "0F 10 05 ? ? ? ? 8D 85", offset = 3}
    },
    commonStructures = {
      ["Player"] = {
        {name = "Health", offset = 0xFC, type = vtInt},
        {name = "Armor", offset = 0x100, type = vtInt},
        {name = "Team", offset = 0x140, type = vtInt},
        {name = "Position", offset = 0x260, type = vtSingle, isVector = true},
        {name = "Velocity", offset = 0x26C, type = vtSingle, isVector = true},
        {name = "ViewAngles", offset = 0x2A0, type = vtSingle, isVector = true}
      },
      ["Weapon"] = {
        {name = "Clip", offset = 0x15C0, type = vtInt},
        {name = "Ammo", offset = 0x15C4, type = vtInt}
      }
    }
  }

  -- Mettre à jour les signatures pour un jeu existant
  SourceTableGenerator.GameProfiles["CSGO"].commonPointers["GameRules"] = {
    signature = "48 8B 0D ? ? ? ? 48 85 C9 74 0A", 
    offset = 3
  }

  -- Ajouter une nouvelle structure pour un jeu existant
  SourceTableGenerator.GameProfiles["CSGO"].commonStructures = SourceTableGenerator.GameProfiles["CSGO"].commonStructures or {}
  SourceTableGenerator.GameProfiles["CSGO"].commonStructures["Player"] = {
    {name = "Health", offset = 0x100, type = vtInt},
    {name = "Armor", offset = 0x117C, type = vtInt},
    {name = "Team", offset = 0xF4, type = vtInt},
    {name = "Position", offset = 0x138, type = vtSingle, isVector = true},
    {name = "Velocity", offset = 0x114, type = vtSingle, isVector = true},
    {name = "ViewAngles", offset = 0x108, type = vtSingle, isVector = true},
    {name = "Spotted", offset = 0x93D, type = vtByte},
    {name = "FlashDuration", offset = 0xABE8, type = vtFloat}
  }

  -- Ajouter des signatures pour CS2 (Counter-Strike 2)
  SourceTableGenerator.GameProfiles["CS2"].commonStructures = SourceTableGenerator.GameProfiles["CS2"].commonStructures or {}
  SourceTableGenerator.GameProfiles["CS2"].commonStructures["Player"] = {
    {name = "Health", offset = 0x32C, type = vtInt},
    {name = "Armor", offset = 0x330, type = vtInt},
    {name = "Team", offset = 0x3BF, type = vtByte},
    {name = "Position", offset = 0x1224, type = vtSingle, isVector = true},
    {name = "ViewAngles", offset = 0x1510, type = vtSingle, isVector = true},
    {name = "Spotted", offset = 0x1621, type = vtByte},
    {name = "FlashDuration", offset = 0x1458, type = vtFloat}
  }

  -- Ajouter une fonction personnalisée
  function SourceTableGenerator.ScanForPlayerWeapons(playerAddress)
    local weaponList = {}
    
    -- Dans CSGO, les armes sont stockées dans un tableau à partir de l'offset 0x2DF8
    local weaponArrayBase = readPointer(playerAddress + 0x2DF8)
    if not weaponArrayBase then return weaponList end
    
    -- Parcourir les 8 premiers emplacements d'armes
    for i = 0, 7 do
      local weaponPtr = readPointer(weaponArrayBase + (i * 0x4))
      if weaponPtr and weaponPtr ~= 0 then
        local weaponId = readInteger(weaponPtr + 0x2FAA)
        local weaponName = "Unknown"
        
        -- Table de correspondance des IDs d'armes CSGO
        local weaponNames = {
          [1] = "Desert Eagle",
          [7] = "AK-47",
          [9] = "AWP",
          [16] = "M4A4",
          [60] = "M4A1-S",
          [61] = "USP-S"
          -- Ajoutez d'autres armes selon vos besoins
        }
        
        if weaponNames[weaponId] then
          weaponName = weaponNames[weaponId]
        end
        
        table.insert(weaponList, {
          address = weaponPtr,
          id = weaponId,
          name = weaponName
        })
      end
    end
    
    return weaponList
  end

  -- Ajouter un bouton personnalisé à l'interface
  local oldCreateMenu = SourceTableGenerator.CreateMenu
  SourceTableGenerator.CreateMenu = function()
    -- Appeler la fonction originale
    oldCreateMenu()
    
    -- Ajouter un bouton personnalisé
    local mainForm = getFormByCaption("Source Table Generator")
    if mainForm then
      local customButton = createButton(mainForm)
      customButton.Parent = mainForm
      customButton.Left = 20
      customButton.Top = 350
      customButton.Width = 450
      customButton.Caption = "Scanner les armes du joueur"
      
      customButton.OnClick = function()
        if not SourceTableGenerator.FoundPointers or not SourceTableGenerator.FoundPointers["LocalPlayer"] then
          messageDialog("Veuillez d'abord scanner les pointeurs!", mtError, mbOK)
          return
        end
        
        local playerAddress = readPointer(SourceTableGenerator.FoundPointers["LocalPlayer"])
        if not playerAddress or playerAddress == 0 then
          messageDialog("Joueur local non trouvé!", mtError, mbOK)
          return
        end
        
        local weapons = SourceTableGenerator.ScanForPlayerWeapons(playerAddress)
        if #weapons == 0 then
          messageDialog("Aucune arme trouvée!", mtInformation, mbOK)
          return
        end
        
        -- Ajouter les armes à la table
        local weaponsHeader = AddressList.createMemoryRecord()
        weaponsHeader.Description = "Weapons"
        weaponsHeader.Address = string.format("%X", playerAddress)
        weaponsHeader.Type = vtAutoAssembler
        weaponsHeader.IsGroupHeader = true
        
        for _, weapon in ipairs(weapons) do
          local entry = AddressList.createMemoryRecord()
          entry.Description = weapon.name
          entry.Address = string.format("%X", weapon.address)
          entry.Type = vtPointer
          
          weaponsHeader.appendToEntry(entry)
          
          -- Ajouter les propriétés de l'arme
          local clipEntry = AddressList.createMemoryRecord()
          clipEntry.Description = "Clip"
          clipEntry.Address = string.format("%X+%X", entry.Address, 0x15C0)
          clipEntry.Type = vtInt
          
          local ammoEntry = AddressList.createMemoryRecord()
          ammoEntry.Description = "Ammo"
          ammoEntry.Address = string.format("%X+%X", entry.Address, 0x15C4)
          ammoEntry.Type = vtInt
          
          entry.appendToEntry(clipEntry)
          entry.appendToEntry(ammoEntry)
        end
        
        messageDialog("Armes ajoutées à la table!", mtInformation, mbOK)
      end
    end
  end

  -- Ajouter des signatures pour Half-Life: Alyx (jeu Source 2)
  SourceTableGenerator.GameProfiles["HalfLifeAlyx"] = {
    processName = "hlvr.exe",
    clientModule = "client.dll",
    engineModule = "engine2.dll",
    commonPointers = {
      ["LocalPlayer"] = {signature = "48 8B 05 ? ? ? ? 48 8B 88 ? ? ? ? 48 85 C9 74 06 48 8B 01", offset = 3},
      ["EntityList"] = {signature = "48 8B 0D ? ? ? ? 48 89 7C 24 ? 8B FA C1 EB", offset = 3},
      ["ViewMatrix"] = {signature = "48 8D 0D ? ? ? ? 48 C1 E0 06", offset = 3}
    },
    commonStructures = {
      ["Player"] = {
        {name = "Health", offset = 0x518, type = vtInt},
        {name = "Position", offset = 0x1224, type = vtSingle, isVector = true},
        {name = "ViewAngles", offset = 0x1510, type = vtSingle, isVector = true}
      }
    }
  }

  print("Extensions personnalisées pour Source Table Generator chargées avec succès!")
end

-- Démarrer le processus d'attente
waitForSourceTableGenerator()
