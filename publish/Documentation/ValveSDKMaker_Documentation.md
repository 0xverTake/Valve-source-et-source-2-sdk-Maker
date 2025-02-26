# Documentation Valve Source SDK Tools

## Table des matières
1. [Introduction](#introduction)
2. [SDK Generator](#sdk-generator)
3. [Cheat Engine Plugin](#cheat-engine-plugin)
4. [Tutoriels](#tutoriels)
5. [Référence API](#référence-api)
6. [FAQ](#faq)

## Introduction

Valve Source SDK Tools est une suite d'outils conçue pour faciliter le développement et la modification des jeux basés sur les moteurs Source et Source 2 de Valve. Cette documentation couvre l'installation, la configuration et l'utilisation des différents outils inclus dans la suite.

## SDK Generator

### Vue d'ensemble
Le SDK Generator permet de générer automatiquement un SDK compatible avec les jeux Source et Source 2, en extrayant les structures de données, les classes et les fonctions directement de la mémoire du jeu en cours d'exécution.

### Prérequis
- Windows 10 ou 11 (64 bits)
- Droits d'administrateur
- Visual Studio 2019 ou supérieur (pour compiler les projets générés)

### Installation
1. Téléchargez et extrayez le fichier SDKGenerator_v2.1.0.zip
2. Exécutez ValveSDKMaker.exe en tant qu'administrateur

### Utilisation
1. Lancez le jeu cible
2. Ouvrez ValveSDKMaker.exe
3. Sélectionnez le jeu dans la liste déroulante
4. Configurez les options de génération
5. Cliquez sur "Générer SDK"
6. Une fois la génération terminée, le SDK sera disponible dans le dossier de sortie spécifié

### Configuration avancée
Le fichier config.ini permet de personnaliser le comportement du générateur :

```ini
[General]
OutputDirectory=C:\SDKs
LogLevel=1
AutoDetectGame=1

[Extraction]
ExtractClasses=1
ExtractInterfaces=1
ExtractEnums=1
ExtractOffsets=1
```

## Cheat Engine Plugin

### Vue d'ensemble
Le plugin Cheat Engine étend les fonctionnalités de Cheat Engine pour faciliter l'analyse des jeux Source et Source 2, en ajoutant des signatures personnalisées et un générateur de tables.

### Prérequis
- Cheat Engine 7.2 ou supérieur
- Windows 10 ou 11

### Installation
1. Téléchargez et extrayez le fichier CheatEnginePlugin_v1.5.0.zip
2. Exécutez install.bat pour installer automatiquement les scripts
3. Redémarrez Cheat Engine

### Fonctionnalités
- **CustomSignatures.lua** : Ajoute des signatures pour localiser rapidement les structures importantes dans les jeux Source
- **SourceTableGenerator.lua** : Génère automatiquement des tables Cheat Engine pour les structures de données Source

### Utilisation
1. Lancez le jeu cible
2. Ouvrez Cheat Engine et attachez-le au processus du jeu
3. Les nouvelles fonctionnalités apparaîtront dans le menu "Table" et "Memory View"

## Tutoriels

### Générer un SDK pour un jeu Source
1. Lancez le jeu (par exemple, Counter-Strike: Global Offensive)
2. Exécutez ValveSDKMaker.exe en tant qu'administrateur
3. Sélectionnez "Counter-Strike: Global Offensive" dans la liste déroulante
4. Cliquez sur "Générer SDK"
5. Attendez la fin du processus (cela peut prendre plusieurs minutes)
6. Ouvrez le dossier de sortie pour accéder au SDK généré

### Analyser un jeu avec le plugin Cheat Engine
1. Lancez le jeu cible
2. Ouvrez Cheat Engine
3. Attachez Cheat Engine au processus du jeu
4. Allez dans "Memory View"
5. Utilisez les signatures personnalisées pour localiser les structures importantes
6. Utilisez le générateur de tables pour créer automatiquement des tables pour ces structures

## Référence API

### SDK Generator API
Le SDK Generator expose une API C++ qui peut être utilisée pour créer des outils personnalisés :

```cpp
// Initialiser le générateur
bool SDKGenerator::Initialize(const std::string& targetProcess);

// Analyser la mémoire du processus
bool SDKGenerator::ScanMemory();

// Extraire les classes
std::vector<ClassInfo> SDKGenerator::ExtractClasses();

// Générer les fichiers d'en-tête
bool SDKGenerator::GenerateHeaders(const std::string& outputPath);
```

### Plugin Cheat Engine API
Le plugin Cheat Engine expose des fonctions Lua qui peuvent être utilisées dans vos propres scripts :

```lua
-- Rechercher une signature dans la mémoire
local address = findSignature("48 8B 05 ? ? ? ? 48 8B 88 ? ? ? ? E9")

-- Générer une table pour une structure
local success = generateSourceTable("CBaseEntity", address)
```

## FAQ

### Q: Le SDK Generator ne trouve pas mon jeu
R: Assurez-vous que le jeu est en cours d'exécution avant de lancer le SDK Generator. Si le problème persiste, vous pouvez ajouter manuellement le processus dans le fichier config.ini.

### Q: Les signatures ne fonctionnent pas avec mon jeu
R: Les signatures peuvent changer après les mises à jour du jeu. Consultez notre site web pour obtenir les dernières signatures.

### Q: Comment puis-je contribuer au projet ?
R: Visitez notre dépôt GitHub pour soumettre des pull requests ou signaler des bugs.

### Q: Le plugin Cheat Engine ne s'installe pas correctement
R: Essayez l'installation manuelle en copiant les fichiers .lua dans le dossier autorun de Cheat Engine.

---

Pour plus d'informations, visitez notre site web : https://valvesdkmaker.pages.dev
