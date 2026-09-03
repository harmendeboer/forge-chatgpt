# Forge ChatGPT Manager

Forge ChatGPT Manager controleert de officiële ChatGPT Linux-app en beheert
de bestaande Chromium-PWA als fallback op Linux Mint en andere Debian- of
Ubuntu-gebaseerde Linux-distributies.

De manager installeert standaard niets. Zonder argumenten toont `install.sh`
alleen de helptekst.

## Commando's

```bash
./install.sh
./install.sh --help
./install.sh --check
./install.sh --official
./install.sh --pwa
```

- `./install.sh` en `./install.sh --help` tonen de programmaversie en opties,
  zonder het systeem te wijzigen.
- `./install.sh --check` voert de bestaande systeemcontrole uit.
- `./install.sh --official` controleert het Debian-pakket `chatgpt`,
  `/usr/bin/chatgpt`, de desktop-launcher en de gebundelde Codex CLI.
- `./install.sh --pwa` installeert of controleert de Chromium-PWA als fallback.

Maak de scripts zo nodig uitvoerbaar:

```bash
chmod +x install.sh scripts/*.sh
```

## Officiële ChatGPT Linux-app

De officiële modus toont de geïnstalleerde pakketversie en architectuur en
controleert deze bestanden:

```text
/usr/bin/chatgpt
/usr/share/applications/chatgpt.desktop
/usr/lib/chatgpt/resources/codex
```

Als de app ontbreekt, toont de manager uitsluitend de officiële downloadpagina:

`https://chatgpt.com/download/`

De pagina wordt alleen na bevestiging met `xdg-open` geopend. De manager
hardcodet geen tijdelijke pakket-URL, downloadt geen pakket en installeert geen
willekeurig gedownload bestand automatisch.

## Chromium-PWA fallback

De bestaande Chromium-PWA-installer staat in `scripts/install-pwa.sh`. Deze
modus kan Flatpak, Flathub en Chromium installeren en begeleidt daarna de
eenmalige registratie van ChatGPT als Chromium-webapp.

Als Chromium en de ChatGPT-PWA al aanwezig zijn, meldt de installer dit en
wijzigt hij niets. De PWA-modus verwijdert nooit de officiële ChatGPT-app of
Chromium en maakt geen extra handgemaakte `chatgpt.desktop`-launcher.

### ChatGPT eenmalig als webapp registreren

1. Open `https://chatgpt.com` in Chromium.
2. Log eventueel in.
3. Klik rechtsboven op de drie puntjes.
4. Kies `Casten, opslaan en delen`.
5. Kies `Pagina installeren als app`.
6. Gebruik als naam `ChatGPT`.
7. Klik op `Installeren`.

Chromium maakt daarna automatisch een eigen launcher, app-ID en
taakbalkpictogram aan.

## Verwijderen van de PWA

Het bestaande begeleide `uninstall.sh` is uitsluitend bedoeld voor de
Chromium-webapp. Start het alleen wanneer die fallback werkelijk verwijderd
moet worden:

```bash
./uninstall.sh
```

Chromium zelf en de officiële ChatGPT Linux-app blijven behouden.

## Projectstructuur

```text
forge-chatgpt/
├── assets/
├── backups/
├── scripts/
│   ├── check-codex.sh
│   ├── check-system.sh
│   ├── install-official.sh
│   └── install-pwa.sh
├── install.sh
├── uninstall.sh
├── VERSION
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

## Versie

De actuele versie staat uitsluitend in `VERSION`; `install.sh` gebruikt dit
bestand voor de getoonde manager-versie.

## Disclaimer

Dit is een onafhankelijk communityproject.

Dit project is niet gemaakt, ondersteund of goedgekeurd door OpenAI.
ChatGPT, OpenAI en bijbehorende merknamen en logo's zijn eigendom van OpenAI.
