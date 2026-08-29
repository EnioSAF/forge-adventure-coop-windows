# Inventaire de portage Adventure multijoueur — Forge 2.0.13 vers 2.0.15

## Références figées

- Source multijoueur historique: `Forge-MTG-Adventure-Multiplayer`, branche `ForgeMTG-Adventure-Multiplayer`, commit `c1139d5c1f7ceb3e17ce50718a9929e9134867e2`.
- Première implantation: commit `5cde6d2b3c74de04467c9e74e79133f09d845804`.
- Compléments serveur, récompenses et draft: commit `c1139d5c1f7ceb3e17ce50718a9929e9134867e2`.
- Cible officielle: `Card-Forge/forge`, commit `ac8c59a8442de8c594d7336021072b8531e2cb36`, `2.0.15-SNAPSHOT`.
- Environnement vérifié: Temurin Java 17.0.20.1, Maven 3.9.8, Windows.
- Build cible non modifié vérifié le 30 août 2026 avec `mvn -pl forge-gui-mobile-dev -am -DskipTests -Dcheckstyle.skip=true install`: 7 modules réussis, JAR produit sous `forge-gui-mobile-dev/target/forge-gui-mobile-dev-2.0.15-SNAPSHOT-jar-with-dependencies.jar`.

Le test localhost de la version historique a déjà validé le principe host/client avec deux instances et `127.0.0.1:36743`. L'échec avec l'IP publique depuis le même LAN n'est pas une preuve d'incompatibilité applicative: un routeur sans NAT loopback produit exactement ce symptôme.

## Différence structurante en 2.0.15

Le réseau officiel a fortement évolué depuis le fork. La cible possède notamment:

- `CompatibleObjectEncoder` / `CompatibleObjectDecoder` avec trames bornées et compression;
- `WireClassFilter` et `WireStreamLimits` contre les classes ou graphes de sérialisation inattendus;
- heartbeats Netty client/serveur et fermeture des connexions silencieuses;
- limites de connexions, limite par adresse, délai de login et longueur maximale des noms;
- contrôle d'autorisation des slots, gestion de reconnexion et suivi de saturation/bande passante;
- tests réseau existants (`NetworkPlayIntegrationTest`, `LobbySlotAuthorizationTest`, `AbuseLimitsTest`, `DeltaSyncUnitTest`).

Le port doit s'insérer dans ces mécanismes. Les anciens pipelines Netty ne seront jamais copiés en bloc, car cela supprimerait des protections et correctifs récents.

## Périmètre retenu

### 1. Session et protocole Adventure

Nouveaux fichiers historiques à réimplanter:

- `forge-gui/src/main/java/forge/gamemodes/net/adventure/AdventureNetEvent.java`
- `forge-gui/src/main/java/forge/gamemodes/net/adventure/AdventureNetSession.java`
- `forge-gui/src/main/java/forge/gamemodes/net/adventure/AdventureProtocolHandler.java`

Fonctions attendues: rôle host/client, cycle de vie, événements typés, état de monde initial, mouvement, état visuel, verrou d'objet, entrée/sortie de POI, début/fin de bataille, decks, récompenses et draft. La version historique n'a pas de handshake Adventure assez strict; la cible ajoutera un identifiant de protocole/build et un refus explicite.

### 2. Connexion, serveur et lobby

Fichiers nouveaux:

- `forge-gui/src/main/java/forge/gamemodes/net/client/ClientAdventureLobby.java`
- `forge-gui/src/main/java/forge/gamemodes/net/server/ServerAdventureLobby.java`

Fichiers à adapter par petits hunks aux API 2.0.15:

- `forge-gui/src/main/java/forge/gamemodes/net/NetConnectUtil.java`
- `forge-gui/src/main/java/forge/gamemodes/net/client/FGameClient.java`
- `forge-gui/src/main/java/forge/gamemodes/net/client/NetGameController.java`
- `forge-gui/src/main/java/forge/gamemodes/net/server/FServerManager.java`
- `forge-gui/src/main/java/forge/gamemodes/net/server/GameServerHandler.java`

Les modifications historiques de `ClientGameLobby.java` et `RemoteClientGuiGame.java` seront reprises seulement si un test démontre qu'elles sont encore nécessaires. Les listeners Adventure doivent être annulables lors d'un échec ou d'un retour au menu; la boucle historique qui se reposte indéfiniment n'est pas conservée.

### 3. Entrée Host/Join et interface

Nouveau fichier:

- `forge-gui-mobile/src/forge/adventure/scene/LobbyScene.java`

Fichiers à adapter:

- `forge-gui-mobile/src/forge/adventure/scene/StartScene.java`
- `forge-gui-mobile/src/forge/adventure/scene/SettingsScene.java`
- `forge-gui-mobile/src/forge/adventure/data/SettingData.java`

Seuls les réglages réellement utiles au réseau seront retenus. Les options Gemini et génération de continent présentes dans les mêmes fichiers sont hors périmètre.

### 4. Monde et joueurs distants

Nouveau fichier:

- `forge-gui-mobile/src/forge/adventure/character/RemotePlayerSprite.java`

Fichiers à adapter:

- `forge-gui-mobile/src/forge/adventure/stage/GameStage.java`
- `forge-gui-mobile/src/forge/adventure/stage/MapStage.java`
- `forge-gui-mobile/src/forge/adventure/stage/WorldStage.java`

`World.java` contient dans le fork un getter de seed utile au partage du monde, mêlé à une génération de continent hors sujet. La cible utilisera l'API 2.0.15 existante si possible; sinon elle ajoutera uniquement l'accès minimal au seed. `ForgeScene.java` et `GameScene.java` ne seront modifiés que pour les gardes de cycle de vie requises par des tests.

### 5. Combat coopératif

Fichiers à adapter:

- `forge-gui-mobile/src/forge/adventure/scene/DuelScene.java`
- `forge-gui-mobile/src/forge/screens/match/MatchController.java`
- `forge-gui-mobile/src/forge/screens/match/MatchScreen.java`
- `forge-gui/src/main/java/forge/gamemodes/match/AbstractGuiGame.java`

Comportement à préserver: un ennemi déclenché par un joueur lance une seule bataille pour le groupe; chaque humain apporte son propre deck, commander, équipement et blessing; tous les humains jouent en équipe contre le ou les adversaires Adventure.

### 6. Récompenses, boutiques et draft

Fichiers à adapter:

- `forge-gui-mobile/src/forge/adventure/scene/EventScene.java`
- `forge-gui-mobile/src/forge/adventure/scene/ShopScene.java`
- `forge-gui-mobile/src/forge/screens/match/winlose/ViewWinLose.java`

Le serveur/hôte reste autoritaire: il calcule les récompenses, puis transmet l'état aux clients. La synchronisation couvre or, cartes, objets, mana shards et vie. Le draft coop est porté après stabilisation d'un duel Adventure ordinaire.

### 7. Données sérialisées

Le fork rend `BiomeStructureData` et `BiomeTerrainData` sérialisables parce que certains payloads transportent des données Adventure. Cette modification ne sera reprise que si les événements retenus transportent encore ces classes dans la cible. Chaque classe reçue sera compatible avec `WireClassFilter`; aucune désactivation globale du filtre n'est prévue.

## Changements explicitement exclus

- Toute intégration Gemini: `AdventureGeminiIntegration.md`, `GeminiClient`, `GeminiChatBus`, `GeminiCommentator`, `LobbyPlayerGemini`, `PlayerControllerGemini`, leurs backups et leurs préférences/API.
- La génération de continents, les nouveaux paramètres de biomes, les changements de placement de POI et de terrain.
- Les dizaines de milliers de suppressions de ressources, outils, binaires Maven et fichiers sans rapport visibles dans l'historique du fork.
- Les modifications massives d'assets, cartes, éditions, traductions ou caches.
- Les anciens encodeurs/décodeurs et pipelines réseau 2.0.13 lorsqu'ils remplaceraient ceux de 2.0.15.
- Les fichiers compilés, sauvegardes, adresses IP personnelles, secrets et journaux utilisateur.

## Ordre de portage et portes de validation

1. Session/protocole purs avec tests de cycle de vie et compatibilité.
2. Handshake et lobby localhost sur le réseau 2.0.15, puis erreurs propres.
3. Interface Host/Join et reconnexion après échec.
4. Monde et sprites distants.
5. Duel coop et decks individuels.
6. Récompenses, retour au monde, puis draft.
7. Deux instances isolées avec `TestHOST` / `TestCLIENT`.
8. Pack portable et automatisation GitHub.

Chaque porte exige les tests ciblés verts, la compilation des modules concernés et l'absence de régression du réseau standard. Aucun résultat non testé ne sera présenté comme fonctionnel.
