# Distortionz City Hall

> Premium government services portal for Qbox/FiveM — IDs, licenses, permits, citizen records, and a polished NUI.

![FiveM](https://img.shields.io/badge/FiveM-cerulean-yellow?style=flat-square&labelColor=181b20)
![Qbox](https://img.shields.io/badge/Qbox-required-red?style=flat-square&labelColor=dfb317)
![License](https://img.shields.io/badge/License-MIT-brightgreen?style=flat-square)
![Version](https://img.shields.io/github/v/release/Distortionzz/Distortionz_Cityhall?style=flat-square&color=d4aa62&label=version)

---

## Overview

Premium civic services interface. Players visit the City Hall ped to purchase identification (State ID, Driver License, Weapon License), apply for permits (business, hunting, fishing, vehicle registration), and review their citizen profile.

## Features

- **Identification services** — State ID, Driver License, Weapon License (item handout + metadata flags)
- **Permits** — business, hunting, fishing, vehicle registration with metadata flags
- **Citizen records** — profile + license status review
- **Polished NUI** — distortionz dark + gold theme with sidebar navigation
- **ox_target** integration on the City Hall clerk ped
- **Cash + bank fallback** — players pay from whichever account has funds
- **Brand footer** — version + GitHub link in the sidebar

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| `qbx_core` | yes | Player metadata, money |
| `ox_lib` | yes | Callbacks, notify fallback |
| `ox_target` | yes | Clerk ped interaction |
| `ox_inventory` | yes | License item handout |
| `distortionz_notify` | optional | Branded notifications |

## Installation

```cfg
ensure distortionz_cityhall
```

## Configuration

See [`config.lua`](config.lua) for ped location, identity/permit catalogs, prices, and money account preference.

## Credits

- **Author:** Distortionz
- **Framework:** [Qbox Project](https://github.com/Qbox-project)

## License

MIT — see [LICENSE](LICENSE).
