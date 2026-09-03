# Changelog

Alle belangrijke wijzigingen aan Forge ChatGPT Manager worden in dit
bestand bijgehouden.

De versienummers volgen Semantic Versioning:

- MAJOR: grote wijzigingen die bestaande werking kunnen breken
- MINOR: nieuwe functies die achterwaarts compatibel zijn
- PATCH: foutoplossingen en kleine verbeteringen

## [Unreleased]

### Gepland

- Uitgebreidere ondersteuning voor andere Linux-distributies
- Betere automatische herkenning van Chromium-webapps
- Mogelijkheid om een installatieverslag op te slaan

## [0.3.0-dev] - 2026-09-03

### Toegevoegd

- Veilige managercommando's `--help`, `--check`, `--official` en `--pwa`
- Controle van pakketversie, pakketarchitectuur, executable en desktop-launcher
  van de officiële ChatGPT Linux-app
- Controle van de door de officiële app gebundelde Codex CLI
- Verwijzing naar de officiële downloadpagina wanneer pakket `chatgpt` ontbreekt
- Bevestigingsvraag voordat de downloadpagina met `xdg-open` wordt geopend
- Afzonderlijke scripts `scripts/install-official.sh` en
  `scripts/install-pwa.sh`
- Veilige verwijderdispatcher met `--help`, `--check`, `--official` en `--pwa`
- Afzonderlijke scripts `scripts/uninstall-official.sh` en
  `scripts/uninstall-pwa.sh`
- Exacte bevestigingszinnen voor officiële-app- en PWA-verwijdering

### Gewijzigd

- `install.sh` is een kleine dispatcher die standaard alleen help toont
- `VERSION` is de enige bron voor de getoonde manager-versie
- De bestaande Chromium-PWA-installatie blijft beschikbaar als expliciete
  fallback via `--pwa`
- De PWA-installatie is idempotent wanneer Chromium en de PWA al bestaan
- `uninstall.sh` toont zonder argumenten alleen help en voert geen actie uit
- Officiële verwijdering gebruikt `apt-get remove` voor uitsluitend pakket
  `chatgpt`
- PWA-verwijdering loopt handmatig via Chromium-appbeheer

### Veiligheid

- Geen automatische installatie zonder expliciete modus
- Geen tijdelijke download-URL of automatische installatie van downloads
- De installatiemodi verwijderen de officiële ChatGPT-app en Chromium niet
- Er wordt geen dubbele handgemaakte `chatgpt.desktop`-launcher gemaakt
- Chromium-profielen, persoonlijke configuratie en overige gebruikersdata
  worden niet rechtstreeks verwijderd
- Afwijkende of ontbrekende verwijderbevestigingen breken veilig af

## [0.2.0] - 2026-07-27

### Toegevoegd

- Controle op de aanwezigheid van Flatpak
- Automatische toevoeging van Flathub wanneer dat nodig is
- Automatische installatie van Chromium via Flatpak
- Detectie van een bestaande ChatGPT Chromium-webapp
- Functie `find_chatgpt_launcher`
- Lokale reservekopieën van oude en actieve launchers
- Bestand `VERSION`
- Controle met `bash -n`
- Controle met ShellCheck
- Begeleid verwijderprogramma voor de Chromium-webapp

### Gewijzigd

- Chromium beheert voortaan zelf de ChatGPT-appidentiteit
- De installer maakt niet langer zelf `chatgpt.desktop` aan
- De officiële Chromium-webapplauncher wordt gebruikt
- De eenmalige registratie van ChatGPT blijft een handmatige stap
- Het taakbalkpictogram wordt door Chromium correct gekoppeld
- De verwijderprocedure loopt voortaan via Chromium

### Opgelost

- Dubbele ChatGPT-vermeldingen in het Linux-menu
- Het blauwe Chromium-pictogram in de taakbalk
- Verkeerde hoofdletters in projectpaden
- Verkeerde toepassing van `$HOME`
- Foutief aangemaakte lokale map `HOME`
- Problemen met onafgesloten `EOF`-blokken
- Oude handgemaakte launchers die opnieuw werden aangemaakt

## [0.1.0] - 2026-07-26

### Toegevoegd

- Eerste Bash-installatiescript
- Eerste Bash-verwijderprogramma
- Installatie van een lokaal ChatGPT-pictogram
- Handmatig opgebouwd `.desktop`-bestand
- Ondersteuning voor Chromium in appmodus
- Projectmappen `assets` en `backups`

### Bekende beperkingen

- Het actieve venster gebruikte aanvankelijk het Chromium-pictogram
- De handgemaakte launcher kon dubbele menu-items veroorzaken
- De Chromium-webapp moest nog niet afzonderlijk worden gedetecteerd
