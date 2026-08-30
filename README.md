# Forge Adventure Coop 2.0.13 — pack Windows

Pack portable Windows du fork communautaire
[Forge-MTG-Adventure-Multiplayer](https://github.com/starstilanx/Forge-MTG-Adventure-Multiplayer/tree/c1139d5c1f7ceb3e17ce50718a9929e9134867e2).

## Pour jouer

1. Télécharge `Forge-Adventure-Coop-2.0.13-Windows.zip` dans les
   [Releases GitHub](https://github.com/EnioSAF/forge-adventure-coop-windows/releases).
2. Extrais entièrement le ZIP.
3. Double-clique sur `PLAY COOP.bat`.
4. Dans Adventure : l’hôte choisit `Host MP`, les autres `Join MP`.

Java 17 est inclus. Le pack utilise son propre dossier `portable-data` : il ne
remplace pas Forge et ne charge pas les sauvegardes de l’installation principale.

Réseau : port TCP `36743`. Sur Internet, utilise une redirection de port ou un
VPN maillé. Une IP publique testée depuis le même réseau peut échouer à cause du
NAT loopback.

## État vérifié

- compilation Maven du fork : réussie sous Java 17 ;
- démarrage du ZIP portable : écran `Classic Mode / Adventure Mode` atteint ;
- connexion locale host/client : testée sur `127.0.0.1:36743` ;
- projet expérimental : déconnexions, transitions, drafts et récompenses peuvent
  encore comporter des bugs.

Le guide complet est inclus dans `README-FR.txt` à l’intérieur du ZIP.

## Construire

Le workflow `Build Windows coop pack` compile le commit testé, télécharge la base
officielle Forge 2.0.13, fabrique un Java portable et publie le ZIP comme artifact.
Un tag `v*` publie aussi une GitHub Release.

## Licence et sources

Forge et le fork sont sous GPL-3.0. Le ZIP inclut `LICENSE.txt`, `SOURCE.txt`, le
commit source exact et les scripts de construction correspondants.
