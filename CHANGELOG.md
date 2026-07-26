# Changelog

Alle belangrijke wijzigingen aan Forge ChatGPT Launcher worden in dit
bestand bijgehouden.

De versienummers volgen Semantic Versioning:

- MAJOR: grote wijzigingen die bestaande werking kunnen breken
- MINOR: nieuwe functies die achterwaarts compatibel zijn
- PATCH: foutoplossingen en kleine verbeteringen

## [Unreleased]

### Gepland

- Controlemodus met `./install.sh --check`
- Uitgebreidere ondersteuning voor andere Linux-distributies
- Betere automatische herkenning van Chromium-webapps
- Mogelijkheid om een installatieverslag op te slaan

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
