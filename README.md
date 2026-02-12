# obsidian-link

Tiny redirect service that turns HTTPS links into Obsidian URI opens.

**How it works:** GitHub Pages serves static HTML pages that redirect to `obsidian://` URIs. This lets you share clickable links in Telegram (or anywhere) that open notes directly in Obsidian.

## Usage

Link format:
```
https://supernova-engineering.github.io/obsidian-link/<path>
```

Example:
```
https://supernova-engineering.github.io/obsidian-link/projects/meshtastic/Meshtastic%20Research
```

Opens `projects/meshtastic/Meshtastic Research` in the Obsidian vault.

## How it's built

A `generate.sh` script scans the Obsidian vault and creates a redirect HTML page for each `.md` file. The HTML pages use a meta-refresh + JavaScript redirect to the `obsidian://` URI.

## Setup

1. Set your vault name in `generate.sh`
2. Run `./generate.sh /path/to/your/vault`
3. Commit and push — GitHub Pages serves the redirects

## Configuration

- **Vault name**: Set in `generate.sh` (default: `seb-obsidian`)
- **GitHub Pages**: Enable on the `main` branch, root (`/docs`) or root
