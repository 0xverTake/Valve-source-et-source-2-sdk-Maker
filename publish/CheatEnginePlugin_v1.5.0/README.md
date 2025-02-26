# Source Table Generator pour Cheat Engine

## Description
Source Table Generator est un plugin pour Cheat Engine qui permet de générer rapidement et facilement des tables pour les jeux basés sur le moteur Source. Il automatise la recherche des pointeurs et structures communes, ce qui vous fait gagner beaucoup de temps lors de la création de tables Cheat Engine.

## Fonctionnalités
- Détection automatique des jeux Source
- Scan automatique des pointeurs et structures communes (LocalPlayer, EntityList, ViewMatrix, etc.)
- Interface utilisateur conviviale pour ajouter facilement des entrées à la table
- Modèles prédéfinis pour les jeux Source populaires (Black Mesa, Half-Life 2, CS:GO)
- Génération automatique de structures pour les joueurs, armes, etc.

## Installation
1. Ouvrez Cheat Engine
2. Cliquez sur "Table" dans la barre de menu
3. Cliquez sur "Show Cheat Engine Lua Script" pour ouvrir l'éditeur de script Lua
4. Dans l'éditeur, cliquez sur "File" > "Load" et sélectionnez le fichier "SourceTableGenerator.lua"
5. Cliquez sur "File" > "Execute" pour charger le plugin

Alternativement, vous pouvez placer le fichier "SourceTableGenerator.lua" dans le dossier "autorun" de Cheat Engine pour qu'il soit chargé automatiquement au démarrage.

## Utilisation

### Générer une table pour un jeu Source
1. Lancez le jeu cible (Black Mesa, Half-Life 2, CS:GO, etc.)
2. Ouvrez Cheat Engine et attachez-le au processus du jeu
3. Dans la barre de menu de Cheat Engine, cliquez sur "Source Table Generator"
4. Le plugin détectera automatiquement le jeu en cours d'exécution
5. Cliquez sur "Scanner" pour rechercher les pointeurs et structures communes
6. Une fois le scan terminé, cliquez sur "Générer Table" pour créer la table

### Personnaliser la table générée
Après avoir généré une table, vous pouvez la personnaliser en ajoutant, modifiant ou supprimant des entrées selon vos besoins. La table générée contient déjà les pointeurs et structures les plus couramment utilisés, ce qui vous donne une base solide pour commencer.

### Ajouter de nouveaux jeux
Si vous souhaitez ajouter un nouveau jeu à la liste des jeux supportés, vous pouvez modifier le fichier "SourceTableGenerator.lua" et ajouter une nouvelle entrée dans la table `SourceTableGenerator.GameProfiles`.

Exemple:
```lua
["MonJeu"] = {
  processName = "monjeu.exe",
  clientModule = "client.dll",
  engineModule = "engine.dll",
  commonPointers = {
    ["LocalPlayer"] = {signature = "8B 0D ? ? ? ? 83 C4 ? 8B 01 FF 90", offset = 2},
    ["EntityList"] = {signature = "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08", offset = 1}
  },
  commonStructures = {
    ["Player"] = {
      {name = "Health", offset = 0x100, type = vtByte},
      {name = "Team", offset = 0x128, type = vtInt}
    }
  }
}
```

## Jeux supportés
- Black Mesa (bms.exe)
- Half-Life 2 (hl2.exe)
- Counter-Strike: Global Offensive (csgo.exe)

## Dépannage

### Le plugin ne détecte pas mon jeu
- Assurez-vous que le jeu est en cours d'exécution avant d'ouvrir le plugin
- Vérifiez que le nom du processus du jeu correspond à celui défini dans `GameProfiles`
- Si votre jeu n'est pas dans la liste, vous pouvez l'ajouter manuellement

### Les pointeurs ne sont pas trouvés
- Les signatures peuvent changer après les mises à jour du jeu
- Essayez de mettre à jour les signatures dans le fichier "SourceTableGenerator.lua"
- Utilisez l'outil de scan de signature de Cheat Engine pour trouver les nouvelles signatures

### Erreurs lors de l'exécution du plugin
- Vérifiez que vous utilisez une version récente de Cheat Engine (7.0 ou supérieure)
- Consultez la console Lua de Cheat Engine pour voir les messages d'erreur détaillés

## Contribution
Les contributions sont les bienvenues ! N'hésitez pas à améliorer ce plugin en ajoutant de nouveaux jeux, en mettant à jour les signatures, ou en ajoutant de nouvelles fonctionnalités.

## Licence
Ce plugin est distribué sous licence MIT. Vous êtes libre de l'utiliser, de le modifier et de le redistribuer selon les termes de cette licence.

## Avertissement
Ce plugin est destiné uniquement à des fins éducatives et de recherche. L'utilisation de Cheat Engine et de ce plugin pour tricher dans des jeux multijoueurs peut entraîner des bannissements et est contraire aux conditions d'utilisation de la plupart des jeux. Utilisez-le à vos propres risques et uniquement dans des jeux solo ou sur des serveurs privés où la triche est autorisée.
