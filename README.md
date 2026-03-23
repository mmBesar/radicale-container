<div align="center">

# 📅 Radicale — Personal Container Image

**A self-maintained, multi-arch container image for [Radicale](https://radicale.org)**
built automatically from source, tracked to upstream releases.

[![Latest Release](https://img.shields.io/github/v/tag/mmBesar/Radicale?label=upstream&color=4a9eff&style=flat-square)](https://github.com/Kozea/Radicale/releases)
[![Image Build](https://img.shields.io/github/actions/workflow/status/mmBesar/Radicale/image-build.yaml?label=build&style=flat-square)](https://github.com/mmBesar/Radicale/actions/workflows/image-build.yaml)
[![Sync Upstream](https://img.shields.io/github/actions/workflow/status/mmBesar/Radicale/sync-upstream.yml?label=sync&style=flat-square)](https://github.com/mmBesar/Radicale/actions/workflows/sync-upstream.yml)
[![License](https://img.shields.io/badge/license-GPL--3.0-orange?style=flat-square)](https://github.com/Kozea/Radicale/blob/master/COPYING.md)
[![Personal Use](https://img.shields.io/badge/use-personal-blueviolet?style=flat-square)](#-disclaimer)

---

> ⚠️ **This is a personal project.** This repository exists for my own use.
> It is public for transparency and in case it helps someone, but it comes
> with **no support, no guarantees, and no SLA of any kind.**
> For production use, please refer to the [official Radicale project](https://github.com/Kozea/Radicale).

</div>

---

## 🧭 What Is This?

[Radicale](https://radicale.org) is a free and open-source CalDAV and CardDAV server — simple, lightweight, and self-hosted. It syncs your calendars and contacts across all your devices without relying on any cloud provider.

This repository does **not** modify Radicale in any way. It simply:

- Mirrors the [upstream Kozea/Radicale](https://github.com/Kozea/Radicale) source daily into a local `upstream` branch
- Tracks upstream release tags (`vX.Y.Z`)
- Builds multi-arch container images (`amd64` + `arm64`) from that source automatically
- Publishes them to the GitHub Container Registry (`ghcr.io`)

The result is a self-sufficient image pipeline that keeps going even if the upstream repository ever disappears.

---

## 📦 Available Images

| Tag | Description |
|---|---|
| `latest` | Latest stable release |
| `v3.6.1` | Specific version (pinned) |
| `v3.6` | Latest patch of minor version |
| `v3` | Latest of major version |
| `dev` / `master` | Upstream master branch (bleeding edge) |

```bash
# Stable (recommended)
docker pull ghcr.io/mmbesar/radicale:latest

# Specific version
docker pull ghcr.io/mmbesar/radicale:v3.6.1

# Bleeding edge
docker pull ghcr.io/mmbesar/radicale:dev
```

**Supported architectures:** `linux/amd64` · `linux/arm64`

---

## 🚀 Quick Start

### Using Docker Compose (recommended)

1. Copy `compose.yaml` to your deployment directory
2. Create a `.env` file:

```env
PUID=1000
PGID=1000
TZ=America/New_York
HS_NETWORK=your_network
CONTAINER_DIR=/path/to/your/data
```

3. Create your config and data directories:

```bash
mkdir -p /path/to/your/data/radicale/{data,config}
```

4. Create a minimal `/path/to/your/data/radicale/config/config`:

```ini
[auth]
type = htpasswd
htpasswd_filename = /etc/radicale/users
htpasswd_encryption = bcrypt

[storage]
filesystem_folder = /var/lib/radicale/collections

[logging]
level = warning
```

5. Create your users file:

```bash
# Install htpasswd (apache2-utils on Debian/Ubuntu)
htpasswd -B -c /path/to/your/data/radicale/config/users yourusername
```

6. Start the container:

```bash
docker compose up -d
```

### Using Docker Run

```bash
docker run -d \
  --name radicale \
  --restart unless-stopped \
  -v /your/data:/var/lib/radicale \
  -v /your/config:/etc/radicale \
  -p 5232:5232 \
  ghcr.io/mmbesar/radicale:latest
```

---

## ⚙️ How It Works

```
Daily (00:00 UTC)
       │
       ▼
sync-upstream.yml
       ├── Mirrors Kozea/Radicale:master → upstream branch
       ├── Syncs vX.Y.Z release tags
       ├── Updates UPSTREAM_VERSION (new stable tag)
       └── Updates UPSTREAM_MASTER_SHA (master changed)
                          │
              ┌───────────┴───────────┐
              │                       │
     UPSTREAM_VERSION          UPSTREAM_MASTER_SHA
         changed                    changed
              │                       │
              ▼                       ▼
     image-build.yaml        image-build.yaml
     stable + dev build      dev build only
              │                       │
              ▼                       ▼
     ghcr.io/mmbesar/radicale:latest  :dev
     ghcr.io/mmbesar/radicale:vX.Y.Z  :master
     ghcr.io/mmbesar/radicale:vX.Y
     ghcr.io/mmbesar/radicale:vX
```

Builds use **native runners** — no QEMU emulation:
- `amd64` → `ubuntu-24.04`
- `arm64` → `ubuntu-24.04-arm`

---

## 🏗️ Repository Structure

```
.
├── Dockerfile                  # Multi-stage build from upstream source
├── compose.yaml                # Docker Compose deployment file
├── UPSTREAM_VERSION            # Latest tracked stable tag (e.g. v3.6.1)
├── UPSTREAM_MASTER_SHA         # Latest tracked master SHA
└── .github/
    └── workflows/
        ├── sync-upstream.yml   # Daily upstream sync
        └── image-build.yaml    # Multi-arch image build & publish
```

---

## 🙏 Credits

| Project | Role |
|---|---|
| [Radicale](https://github.com/Kozea/Radicale) by [Kozea](https://kozea.fr) | The actual CalDAV/CardDAV server — all credit goes to them |
| [GitHub Actions](https://github.com/features/actions) | CI/CD pipeline |
| [GitHub Container Registry](https://ghcr.io) | Image hosting |
| [Docker Buildx](https://github.com/docker/buildx) | Multi-arch image building |
| [actions/checkout](https://github.com/actions/checkout) | Workflow checkout action |
| [docker/build-push-action](https://github.com/docker/build-push-action) | Docker build & push action |

---

## ⚖️ License

The **Radicale source code** is licensed under the
[GNU General Public License v3.0](https://github.com/Kozea/Radicale/blob/master/COPYING.md)
by the Kozea team. All rights belong to the original authors.

The **workflow and configuration files** in this repository are provided as-is,
with no warranty, for personal use only.

---

## ⚠️ Disclaimer

This repository is a **personal infrastructure project**. It is:

- **Not** affiliated with or endorsed by the Radicale / Kozea project
- **Not** intended for production use by others
- **Not** maintained as a public service
- Provided publicly for transparency and personal reference only

If you need a reliable Radicale image, please use the
[official Radicale Docker image](https://github.com/Kozea/Radicale/pkgs/container/radicale)
or build your own from the [upstream source](https://github.com/Kozea/Radicale).

---

<div align="center">

Made with ☕ for personal use · Built on the shoulders of giants

</div>
