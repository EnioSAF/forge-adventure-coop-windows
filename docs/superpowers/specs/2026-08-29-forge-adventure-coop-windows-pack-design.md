# Forge Adventure Coop Windows Pack — Design Specification

## 1. Objective

Produce a Windows x64 portable ZIP for the `Forge-MTG-Adventure-Multiplayer` fork. A player downloads the ZIP from a GitHub Release, extracts it, runs `PLAY COOP.bat`, and can host or join an Adventure cooperative session without installing Java or modifying another Forge installation.

The release target is the newest Forge `2.0.15-SNAPSHOT` commit proven compatible by the verification gates in this specification. The original `2.0.13-SNAPSHOT` multiplayer branch remains the behavioral reference and fallback build, not the preferred public release.

## 2. Source Repositories and Version Policy

- Multiplayer source: `https://github.com/starstilanx/Forge-MTG-Adventure-Multiplayer.git`
- Multiplayer branch: `ForgeMTG-Adventure-Multiplayer`
- Official upstream: `https://github.com/Card-Forge/forge.git`
- Reference multiplayer version: `2.0.13-SNAPSHOT`
- Port target family: `2.0.15-SNAPSHOT`
- Java build and runtime major version: 17

The port process records immutable commit SHAs for both repositories in `pack/VERSION.txt` and the generated ZIP. A release never follows a moving branch at runtime. Host and clients must use the same ZIP release and matching SHA-256 checksum.

## 3. Repository Strategy

The workspace repository contains automation, documentation, tests, and either a Git submodule or a reproducible checkout script for Forge source. It must not copy files from an existing user installation.

Porting follows two checkpoints:

1. Build the original multiplayer branch unchanged and launch its Adventure artifact. This establishes a known reference and identifies its complete changed-file set relative to the historical Forge base.
2. Start from the selected official `2.0.15-SNAPSHOT` commit and reapply the multiplayer behavior as a focused patch. Resolve API changes deliberately; do not overwrite entire current modules with `2.0.13` binaries or source trees.

The changed-file inventory is generated from Git history and saved under `docs/porting/`. It groups changes by shared networking, Adventure map/session, duel/reward flow, UI entry points, tests, and build configuration.

## 4. Deliverables

The project produces:

- `Forge-Adventure-Coop-Windows-x64-<release>.zip`
- `Forge-Adventure-Coop-Windows-x64-<release>.zip.sha256`
- GitHub Actions build artifact for every manual or tagged build
- GitHub Release assets for version tags
- corresponding complete source in the public Git repository at the recorded commit

The extracted ZIP has this user-facing layout:

```text
Forge Adventure Coop/
├── PLAY COOP.bat
├── INSTALL.bat
├── RESTORE.bat
├── UNINSTALL.bat
├── README.txt
├── VERSION.txt
├── LICENSE-GPL-3.0.txt
├── SOURCE.txt
├── CHECKSUMS.sha256
├── app/
├── runtime/
├── userdata/
├── backups/
└── logs/
```

`app/` contains one coherent Forge Adventure distribution assembled from the same build. `runtime/` contains a pinned Windows x64 Java 17 runtime with its own license notices. `userdata/`, `backups/`, and `logs/` are pack-local.

## 5. Launcher and Safety Model

### `PLAY COOP.bat`

The launcher:

1. Resolves paths from `%~dp0`, so spaces in the extraction path work.
2. Verifies `runtime\bin\java.exe`, the Adventure JAR, required resources, and `VERSION.txt`.
3. Uses only the bundled Java runtime.
4. sets Forge configuration, cache, logs, and save locations to pack-local directories using the exact mechanism supported by the selected Forge build.
5. Writes a timestamped launcher log to `logs/`.
6. Displays a short French error with the relevant log path if validation or launch fails.

The launcher never searches for or writes to another Forge directory.

### `INSTALL.bat`

Because the distribution is portable, installation means initializing pack-local directories and validating files. It creates a dated configuration backup before replacing any configuration previously created inside this pack. It never requires administrator privileges.

### `RESTORE.bat`

Restore lists pack-local backups and restores the newest valid backup after explicit confirmation. It only replaces configuration and save files beneath the extracted pack root.

### `UNINSTALL.bat`

Uninstall removes only generated `userdata/`, `logs/`, and pack-local temporary files after explicit confirmation. It preserves `backups/` by default and explains that deleting the extracted folder completes removal. It rejects any target whose resolved path is outside the pack root.

## 6. Ported Multiplayer Behavior

The `2.0.15` port must preserve the behaviors implemented by the reference fork:

- one host and up to three clients in Adventure;
- shared Adventure map session with visible remote players;
- host-authoritative world and save state;
- session-only client state unless explicitly supported by the fork;
- a battle triggered by one player starts for the cooperative group;
- each connected player supplies the deck used by their network player slot;
- human players share a team against Adventure AI enemies;
- equipment, blessings, Commander handling, and Adventure draft behavior remain available where implemented by the reference branch;
- victory rewards are generated authoritatively and delivered to clients;
- map state resumes after battle without duplicating rewards;
- disconnects and version mismatches fail visibly rather than silently corrupting state.

No claim of compatibility with existing real saves is made. Manual testing uses disposable pack-local saves. Existing saves are never imported automatically.

## 7. Network Model and User Documentation

The host is authoritative. All players use the identical release. Default Forge network port is TCP `36743` unless the selected build proves another value.

`README.txt` documents:

- same-LAN host/join procedure;
- Windows Defender Firewall prompt and manual TCP `36743` rule;
- Internet play using router port forwarding or a private mesh VPN such as Tailscale or ZeroTier;
- which IP address clients enter in each scenario;
- host must remain connected and should keep the authoritative save backed up;
- version mismatch, latency, traffic volume, disconnect, and beta-feature limitations;
- exact steps for reporting a problem with `VERSION.txt` and the relevant file in `logs/`.

The pack does not automate router configuration, install a VPN, or weaken Windows Firewall.

## 8. Build and Packaging Automation

The build uses Maven with Java 17. The original reference command is retained for traceability:

```powershell
mvn.cmd clean install -pl forge-gui-mobile-dev -am -DskipTests -Dcheckstyle.skip=true
```

The final workflow must also run relevant tests rather than relying only on this reference command. Packaging prefers Forge's own `forge-installer` output when it contains the complete matching Adventure resources and launchers. If inspection proves that installer output is incomplete for this fork, the packaging script assembles an equivalent distribution from explicit, versioned build outputs and fails when any required artifact is missing.

The Java runtime download is pinned by vendor release URL and SHA-256. Eclipse Temurin 17 is the default choice if its redistribution terms and GitHub Actions availability are confirmed during implementation. Runtime license and notice files are copied into the pack.

## 9. GitHub Actions

Workflow triggers:

- `workflow_dispatch` builds and uploads an artifact;
- pushes to release tags matching `coop-v*` build, verify, and publish GitHub Release assets;
- pull requests run source tests and packaging validation without publishing a release.

The workflow:

1. Checks out the exact source commit.
2. Sets up Java 17 and caches Maven dependencies.
3. Verifies recorded upstream and multiplayer SHAs.
4. Runs tests and builds the Adventure distribution.
5. Downloads and verifies the pinned Windows x64 Java runtime.
6. Assembles the portable directory.
7. Runs static pack validation and launcher dry-run checks.
8. Creates a deterministic ZIP where practical.
9. Generates SHA-256 files.
10. Uploads artifacts or release assets.

No credentials beyond GitHub's scoped workflow token are stored in the repository.

## 10. GPL-3.0 and Third-Party Compliance

Every binary release includes:

- Forge's GPL-3.0 license text;
- a clear statement that this is an unofficial community build;
- upstream Forge and multiplayer fork links;
- exact corresponding source commit links;
- build instructions sufficient to reproduce the binaries;
- source modifications in the public repository;
- bundled Java runtime license and notices;
- no Wizards of the Coast affiliation claim.

Card images or other remotely downloaded assets are not newly redistributed unless their existing Forge distribution path and licensing permit it. First-run asset downloads remain first-run downloads when required by Forge.

## 11. Error Handling

Build and packaging scripts fail on:

- wrong Java major version;
- unresolved Maven module or dependency failure;
- missing required Adventure artifact or resource directory;
- artifact version differing from `VERSION.txt`;
- runtime checksum mismatch;
- files escaping the staging directory;
- unexpected writes outside the temporary test profile;
- failed smoke launch or missing multiplayer UI entry point.

User scripts return nonzero exit codes and preserve diagnostic logs. They do not silently fall back to a system Java installation or another Forge installation.

## 12. Verification Gates

### Automated

- Original `2.0.13` multiplayer branch compiles.
- Ported `2.0.15` source compiles with Java 17.
- Existing relevant Maven tests pass.
- New unit tests cover version metadata, staging boundaries, required artifacts, checksums, and launcher path handling.
- Multiplayer tests cover protocol dispatch and the ported lobby/reward logic where the codebase permits deterministic testing.
- Packaging validation succeeds from a clean checkout.
- ZIP expands and validates from a Windows path containing spaces.
- A monitored smoke launch starts with a disposable profile and produces no writes in known system Forge data locations.

### Manual release gate

- Two clean local instances start from separate extracted folders.
- Client joins host with matching version.
- Both players appear on the map and movement updates.
- Host and client enter the same Adventure combat.
- Each player can make game decisions with their own deck.
- Victory returns both players to the map.
- Rewards appear once for every intended recipient.
- Host save persists after restart.
- Client disconnect and reconnect behavior matches documented limitations.
- A deliberately mismatched version is rejected or produces a clear documented failure.

A build that passes compilation but fails a manual cooperative gate is labeled experimental and is not published as stable.

## 13. Release and Fallback Policy

Preferred release: ported `2.0.15-SNAPSHOT` build pinned to a tested official Forge commit.

Fallback: original `2.0.13-SNAPSHOT` multiplayer build published only as a separately named beta if it passes its own launch and cooperative tests. Its README must state that it is the historical compatibility build and must not be mixed with newer Forge clients.

Future upstream updates are opt-in. A scheduled or manually triggered compatibility check may report available Forge changes, but no release advances its upstream pin until the full verification gates pass again.

## 14. Out of Scope

- Android, iOS, macOS, and Linux release packaging;
- modifying a user's existing Forge installation;
- importing or migrating real Adventure saves;
- automatic router, firewall, VPN, or UPnP configuration;
- guaranteeing flawless Internet play under high latency;
- upstreaming the multiplayer implementation into Card-Forge during this project;
- silently tracking future Forge snapshots.

## 15. Completion Criteria

Work is complete when a clean GitHub checkout can produce the portable Windows x64 ZIP, the ZIP passes automated validation, the manual cooperative checklist has recorded results, GPL and runtime notices are present, and a release candidate can be downloaded and launched without Java installation or interaction with another Forge installation.
