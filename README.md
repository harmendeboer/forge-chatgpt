# Forge ChatGPT Manager

Forge ChatGPT Manager controleert de officiële ChatGPT Linux-app en beheert
de bestaande Chromium-PWA als fallback op Linux Mint en andere Debian- of
Ubuntu-gebaseerde Linux-distributies.

De manager installeert of verwijdert standaard niets. Zonder argumenten tonen
`install.sh` en `uninstall.sh` alleen hun helptekst.

## Installatiecommando's

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

## Veilige verwijdercommando's

De verwijdermanager heeft dezelfde veilige dispatcheropzet als de installer:

```bash
./uninstall.sh
./uninstall.sh --help
./uninstall.sh --check
./uninstall.sh --official
./uninstall.sh --pwa
```

- `./uninstall.sh` en `./uninstall.sh --help` tonen alleen uitleg.
- `./uninstall.sh --check` voert de systeemcontrole uit zonder wijzigingen.
- `./uninstall.sh --official` toont eerst de pakketgegevens en het exacte
  `apt-get remove`-commando. Verwijdering kan alleen na de exacte bevestiging
  `VERWIJDER CHATGPT`.
- `./uninstall.sh --pwa` detecteert de echte Chromium-launcher. Alleen na de
  exacte bevestiging `VERWIJDER PWA` wordt Chromium-appbeheer geopend, waarna
  de gebruiker de PWA zelf verwijdert.

De officiële modus verwijdert alleen pakket `chatgpt`, zonder persoonlijke
configuratiemappen te verwijderen. Er wordt geen pakketpurge uitgevoerd. De
PWA-modus verwijdert nooit rechtstreeks Chromium-profielen of launchers.

De verwijdermanager verwijdert nooit automatisch:

- Chromium;
- ChatGPT-profielen, cookies, gesprekken of instellingen;
- browserdata;
- Codex-data, tokens of keyring-items;
- andere gebruikersdata.

Gebruik een verwijdermodus alleen wanneer de bijbehorende installatie werkelijk
verwijderd moet worden. Zonder de exacte bevestiging wordt veilig afgebroken.

Bij PWA-verwijdering blijven Chromium en de officiële ChatGPT Linux-app
behouden. Bij verwijdering van het officiële pakket blijft de Chromium-PWA als
fallback behouden.

## Projectstructuur

```text
forge-chatgpt/
├── assets/
├── backups/
├── scripts/
│   ├── check-codex.sh
│   ├── check-system.sh
│   ├── install-official.sh
│   ├── install-pwa.sh
│   ├── uninstall-official.sh
│   └── uninstall-pwa.sh
├── install.sh
├── uninstall.sh
├── VERSION
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

## Versie

De actuele versie staat uitsluitend in `VERSION`; `install.sh` en
`uninstall.sh` gebruiken dit bestand voor de getoonde manager-versie.

## Disclaimer

Dit is een onafhankelijk communityproject.

Dit project is niet gemaakt, ondersteund of goedgekeurd door OpenAI.
ChatGPT, OpenAI en bijbehorende merknamen en logo's zijn eigendom van OpenAI.
