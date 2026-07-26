# Forge ChatGPT Launcher

Forge ChatGPT Launcher helpt om ChatGPT als zelfstandige Chromium-webapp
te installeren op Linux Mint en andere Debian- of Ubuntu-gebaseerde
Linux-distributies.

## Functies

- Controleert of Flatpak aanwezig is
- Voegt Flathub toe wanneer dit nodig is
- Installeert Chromium via Flatpak
- Detecteert een bestaande ChatGPT-webapp
- Voorkomt dubbele ChatGPT-launchers
- Maakt lokale reservekopieën
- Bevat een begeleid verwijderprogramma

## Installeren

Maak het installatieprogramma uitvoerbaar:

```bash
chmod +x install.sh

```

Start daarna de installer:

```bash
./install.sh
```

## ChatGPT eenmalig als webapp registreren

Chromium moet ChatGPT één keer zelf als webapp registreren:

1. Open `https://chatgpt.com` in Chromium.
2. Log eventueel in.
3. Klik rechtsboven op de drie puntjes.
4. Kies `Casten, opslaan en delen`.
5. Kies `Pagina installeren als app`.
6. Gebruik als naam `ChatGPT`.
7. Klik op `Installeren`.

Chromium maakt daarna automatisch een eigen launcher, app-ID en
taakbalkpictogram aan.

## Verwijderen

Maak het verwijderprogramma uitvoerbaar:

```bash
chmod +x uninstall.sh
```

Start het alleen wanneer ChatGPT werkelijk verwijderd moet worden:

```bash
./uninstall.sh
```

De webapp wordt via Chromium verwijderd. Chromium zelf blijft geïnstalleerd.

## Projectstructuur

```text
forge-chatgpt/
├── assets/
├── backups/
├── install.sh
├── uninstall.sh
├── VERSION
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

## Versie

De huidige versie staat in het bestand `VERSION`.

## Disclaimer

Dit is een onafhankelijk communityproject.

Dit project is niet gemaakt, ondersteund of goedgekeurd door OpenAI.
ChatGPT, OpenAI en bijbehorende merknamen en logo's zijn eigendom van OpenAI.

De scripts openen uitsluitend de officiële website:

`https://chatgpt.com`
