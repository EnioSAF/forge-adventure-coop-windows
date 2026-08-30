FORGE ADVENTURE COOP 2.0.13 - GUIDE RAPIDE
==========================================

Ce pack est une copie portable et experimentale de Forge.
Il ne remplace pas ton installation Forge et n'utilise pas ses sauvegardes.

INSTALLATION
------------
1. Telecharge le ZIP depuis la page GitHub Releases.
2. Extrais tout le ZIP dans un dossier normal. Ne lance rien depuis le ZIP.
3. Double-clique sur PLAY COOP.bat.
4. Autorise Java dans le pare-feu Windows si Windows le demande.

PREMIERE PARTIE
---------------
Chaque joueur doit avoir exactement le meme ZIP.
Chaque joueur charge ou cree sa propre sauvegarde Adventure.

HOTE :
1. Dans Adventure, choisis Host MP.
2. Le port par defaut est 36743.
3. Donne ton adresse IP et le port a tes amis.
4. Attends les joueurs dans le lobby, puis lance la partie.

CLIENT :
1. Dans Adventure, choisis Join MP.
2. Entre une adresse comme 192.168.1.50:36743.
3. Attends dans le lobby avec l'hote.

RESEAU
------
Sur le meme reseau, utilise l'adresse locale de l'hote, souvent 192.168.x.x.
Pour jouer par Internet, l'hote doit rediriger le port TCP 36743 sur son routeur,
ou utiliser un VPN maille qui place les joueurs sur le meme reseau virtuel.
Tester sa propre IP publique depuis le meme reseau peut echouer si le routeur ne
gere pas le NAT loopback. Cela ne prouve pas que le serveur est casse.

LIMITATIONS CONNUES
-------------------
- Projet communautaire experimental, non officiel.
- Base Forge 2.0.13-SNAPSHOT ; incompatible avec un Forge standard different.
- Jusqu'a 4 joueurs vises par le fork.
- Les deconnexions, transitions, drafts et recompenses peuvent encore avoir des bugs.
- Fais une copie de toute sauvegarde importante avant de jouer.

DEPANNAGE
---------
- Rien ne se lance : reextrais le ZIP et relance PLAY COOP.bat.
- Mauvaise version Java : utilise le ZIP avec runtime inclus ou installe Java 17 64 bits.
- Connexion refusee : verifie IP, port 36743, pare-feu et redirection TCP.
- Journal du dernier lancement : portable-data\logs\forge-coop-last.log

REMISE A ZERO
-------------
RESTORE-UNINSTALL.bat efface seulement les donnees de ce pack portable.
Pour desinstaller, supprime ensuite le dossier extrait.

Licence et sources : voir LICENSE.txt et SOURCE.txt.
