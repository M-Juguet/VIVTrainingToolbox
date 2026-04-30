# Plan : VIV Formation Toolbox

## 1. Overview
Application de bureau (Windows) développée en Flutter. Elle servira de boîte à outils pour la création, l'édition et la génération de documents (principalement PDF) pour les programmes de VIV Formation. L'interface s'appuiera fortement sur le Design System VIV et s'inspirera de l'application interne "Opsis".

## 2. Project Type
**MOBILE** (Flutter Desktop - Toutes les tâches Flutter seront gérées par l'agent `mobile-developer`).

## 3. Success Criteria
- [ ] L'interface utilisateur respecte la charte VIV (typographies Playfair/Noto, couleurs) et la structure visuelle d'Opsis.
- [ ] L'application gère de manière autonome une arborescence locale de fichiers pour organiser les PDF et les données associées.
- [ ] Le stockage local "léger" (préférences utilisateurs, clé API) est fonctionnel.
- [ ] Un moteur de génération PDF est implémenté et formaté professionnellement.
- [ ] L'intégration Gemini est opérationnelle via des prompts contextuels sur des actions précises ("Générer avec l'IA").

## 4. Tech Stack & Recommendations
- **Framework** : Flutter (cible native Windows).
- **Architecture d'état** : Riverpod (recommandé pour une application modulaire, maintenable et testable).
- **Design System** : Implémentation des tokens du `viv-design-system` et extraction des widgets depuis le code de référence Opsis (`_resources`).
- **Génération PDF** : Packages `pdf` et `printing`.
- **Intelligence Artificielle** : Package `google_generative_ai`.
- **Persistance des données (Recommandations stratégiques)** : 
  - *Données légères* : `shared_preferences` pour les paramètres d'application et la configuration système.
  - *Gestion Documentaire* : Création d'un répertoire de travail système (ex: `Documents/VIV_Formation_Data/`). Au lieu de stocker de gros volumes dans une base SQLite, nous sauvegarderons les programmes sous forme de fichiers de données `.json` (agissant comme la source de vérité d'un document). Le PDF final sera généré à la volée ou sauvegardé à côté de ce `.json`. Un fichier de registre indexé (`registry.json`) maintiendra la liste des documents pour la recherche rapide. Cette approche par "fichiers" rendra également la donnée très facilement manipulable, versionnable et portable.

## 5. File Structure
```text
lib/
  core/
    theme/             # Charte graphique (Couleurs, Typographie Playfair/Noto)
    services/          # Services externes (Gemini API, Générateur PDF)
    storage/           # Gestionnaire de fichiers système et registres JSON
    router/            # GoRouter (Configuration des routes et coquille)
  features/
    shell/             # Main layout, Barre latérale (Opsis style)
    dashboard/         # Vue d'accueil et alertes/status
    program_creator/   # Outil de création d'un nouveau programme
    program_editor/    # Outil de recherche et modification des programmes existants
  main.dart
```

## 6. Task Breakdown

### Phase 1: Fondation & UI Core
**Task 1.1: Intégration Code Opsis & Navigation**
- **Agent**: `mobile-developer` | **Skill**: `mobile-design`
- **Priority**: P0
- **INPUT**: Code Opsis importé dans `_resources` + README du Design System.
- **OUTPUT**: Un projet Flutter structuré avec un "Main Shell" fonctionnel (Barre latérale, GoRouter), et le thème global appliqué (couleurs, polices intégrées).
- **VERIFY**: ✅ L'application se lance sur Windows avec une navigation fluide entre des pages vides.

**Task 1.2: Gestion des Espaces de Travail (Workspaces) & File System**
- **Agent**: `mobile-developer`
- **Priority**: P1
- **INPUT**: Package `file_picker`, UI Components Shadcn.
- **OUTPUT**: 
  - Système permettant à l'utilisateur de sélectionner un dossier cible.
  - Gestion de multiples "Workspaces" (Nom + Chemin local) sauvegardés dans les SharedPreferences.
  - Écran de configuration initial (Setup Screen) au lancement si aucun workspace n'est défini (peut être ignoré).
  - Gestion des workspaces dans la page "Paramètres".
  - Menu contextuel type "Notion" sur la carte de profil (Sidebar) pour basculer d'un espace à l'autre.
- **VERIFY**: Création de plusieurs workspaces, bascule entre eux depuis la sidebar, et persistance des chemins sélectionnés.

### Phase 2: Moteurs (PDF & IA)
**Task 2.1: Intégration du Service Gemini**
- **Agent**: `mobile-developer`
- **Priority**: P1
- **INPUT**: Clé API configurée localement.
- **OUTPUT**: Un service robuste capable de recevoir un prompt système dédié (ex: "Tu es un expert pédagogique...") + un prompt utilisateur, et de renvoyer le résultat.
- **VERIFY**: Test avec un composant temporaire validant la bonne connexion à Gemini.

**Task 2.2: Moteur de Génération PDF**
- **Agent**: `mobile-developer`
- **Priority**: P1
- **INPUT**: Règles de mise en page VIV (marges, typographie d'export).
- **OUTPUT**: Un utilitaire convertissant un modèle de données "Programme" en un PDF professionnel (Header, Footer, corps structuré).
- **VERIFY**: Export d'un document test s'ouvrant correctement sur l'OS.

### Phase 3: Outils Métier de Formation
**Task 3.1: Outil "Création de Programme"**
- **Agent**: `mobile-developer` | **Skill**: `mobile-design`
- **Priority**: P2
- **INPUT**: UI Components + Services IA & PDF.
- **OUTPUT**: Un formulaire riche permettant de saisir les méta-données et les modules de formation. Inclut des boutons interactifs "Générer la description avec l'IA". Bouton final de sauvegarde générant le `.json` et exportant le PDF.
- **VERIFY**: Bout en bout réussi (Saisie -> Aide IA -> Sauvegarde -> PDF créé).

**Task 3.2: Outil "Exploration et Édition"**
- **Agent**: `mobile-developer` | **Skill**: `mobile-design`
- **Priority**: P2
- **INPUT**: Registre JSON.
- **OUTPUT**: Interface listant les programmes sauvegardés, avec fonction de recherche. Permet d'ouvrir un programme dans le formulaire pour le mettre à jour et régénérer le PDF.
- **VERIFY**: Modification du titre d'un programme existant et écrasement propre de l'ancien fichier.

## ✅ PHASE X COMPLETE
- Lint: [ ] Pass
- Security: [ ] No critical issues
- Build: [ ] Success
- Date: [Pending]
