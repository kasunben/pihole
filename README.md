# Pi-hole Telemetry & AI Blocklists

A curated collection of **telemetry-focused DNS blocklists** for use with **Pi-hole**.

The goal of this repository is **not** to "break the internet", but to **reduce unnecessary telemetry, analytics, ACR (automatic content recognition), and tracking traffic** from major platforms (Big Tech, Smart TVs, AI services) while keeping core functionality intact wherever possible.

## What this repo is (and isn’t)

### ✅ This repo *is*
- A set of **plain-domain blocklists** suitable for Pi-hole *Blocklists*
- Focused on **telemetry, analytics, ads, and tracking**
- Safe to host publicly (GitHub raw URLs)

### ❌ This repo is *not*
- A "block everything from X" mega list
- A guarantee of zero telemetry (DNS blocking has limits)
- A replacement for OS/app privacy settings

## Repository structure


```text
.
├── blocklists/
│   ├── ai-telemetry.txt
│   ├── apple-telemetry.txt
│   ├── google-telemetry.txt
│   ├── meta-facebook-telemetry.txt
│   ├── microsoft-telemetry.txt
│   └── samsung-telemetry.txt
├── tools/
│   ├── validate_lists.sh
│   └── normalize.sh
├── README.md
└── LICENSE
```

Each `.txt` file contains:
- One domain per line
- Optional comments starting with #
- No IP prefixes (0.0.0.0 / 127.0.0.1)
- No wildcards

## Usage with `Pi-hole`

1.	Open Pi-hole Admin UI
2.	Go to Lists
3.	Add the raw GitHub URL of the list you want, e.g.:

    ```text
    https://raw.githubusercontent.com/<your-username>/pihole/main/blocklists/<list-name>.txt
    ```
4.	Save
5.	Go to Tools → Update Gravity

### with CLI

```
pihole -g
```

Docker:
```
docker exec -it pihole pihole -g

docker exec -it pihole pihole -t # Watch live DNS queries
```

## Tools

### `tools/validate_lists.sh`

Validates list hygiene:
- Rejects hosts-file formats (`0.0.0.0` domain)
- Rejects URLs (`https://`)
- Flags suspicious lines
- Ensures Pi-hole compatibility

Usage:
```bash
./tools/validate_lists.sh
```

### tools/normalize.sh

Optional helper to:
- Deduplicate domains
- Sort entries
- Preserve header comments

> This script rewrites files. Use only if you understand what it does.

Usage:
```bash
./tools/normalize.sh
```