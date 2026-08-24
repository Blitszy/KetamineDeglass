# Ketamine 1.2

*Everything that changed since 1.1*

---

## ⚠️ Read this first — requirements changed

- **Minimum is now iOS 26.0.** 1.1 ran on iOS 18+; that's gone.
- **Tweaks and Siri AI Setup need iOS 27.** On iOS 26.x the app still opens, but only **PosterBoard** works — the other tabs tell you so instead of silently doing nothing.
- Still capped at **iOS 27.0 developer beta 4 (24A5390f)**. Anything newer is patched and unsupported.

## 🧠 Siri AI Setup — new tab

Replaces the old **Eligibility** tab, and it's a real flow now instead of a checklist.

One picker at the top — **Siri**, **Apple Intelligence**, **Siri AI** — decides what gets applied. No more stacking toggles and hoping.

- **Apple Intelligence** — sets the US regulatory-region keys, and spoofs the product, hardware and CPU model *only* if your device isn't already natively eligible. Spoofing may temporarily break Face ID.
- **Siri AI** — for when Apple Intelligence is already live and its model has finished downloading. Ticks generative-model support up a level.
- **Siri** — puts every key back the way it was, drops the spoof, and turns generative-model support back off.
- **Unspoof** — appears whenever a spoof is active. Drops the fake identity but **keeps** Apple Intelligence enabled.
- Every key is snapshotted before it's touched, so nothing here is a one-way door.
- Applying reminds you to reboot before it resprings.

It's labelled **beta** in-app for a reason, and **Siri AI** carries its own warning: it's the least reliable thing in Ketamine and may do nothing at all on your device. Back up first.

## 🎨 The app was rebuilt

- Rebuilt from scratch as a control console — native SwiftUI, real Liquid Glass, monochrome-first.
- Tabs are now **Tweaks · Library · Siri AI Setup · Settings**.
- **Settings** is a hub: Recovery, Preferences, credits, thanks, Discord — instead of one long scroll.
- **Accent colour picker** — Blue, Indigo, Teal, Orange, Pink, or pick your own.
- **NeoSpring** — resprings now run behind a proper full-screen transition instead of flashing the WebKit crash view at you.

## 🖼️ Library (was PosterBoard)

- New **wallpaper gallery**: browse the Nugget-Wallpapers catalogs in-app and download `.tendies` packs straight into your install queue.
- Proper empty and unavailable states, so it's clear whether your shelf is empty or your iOS build simply can't open PosterBoard's container.

## 🍬 Eight app icons

Data-driven from `AppIcons.json`, picked from Settings → Preferences.

- **Sour K** — Lemonz
- **Special K** — Slitzy
- **Modernized** — baocreata
- **Evil Ketamine** — iamfariss
- **Evil Special K** — lrahpro16
- **crack cat :3** — Sierra :3
- **Cosmic** — baocreata

…and one that isn't on this list.

## 🔧 Tweaks

- Catalog split into **Device · Display · System · Liquid Glass · iPad · Intelligence**, plus an **All** filter for when you don't want to hunt.
- New **iOS Mode** — the counterpart to iPadOS Mode, spoofing iOS capabilities and patching CacheData.
- The old **AI Gestalt** toggle is gone from this list — Apple Intelligence is handled properly in Siri AI Setup now, because it has to branch on your device's actual identity at apply time.
- `ProductType` spoofing is hidden from the catalog for the same reason.

## 🛡️ Backups you can take with you

Settings → Backup can now **Export** your pristine recovery point out to Files/AirDrop, and **Import** one back in — checked with a SHA-256 before it replaces anything. Recovering after a fresh install, or moving your recovery point to another device, actually works now.

## 📜 Disclaimer & licence

- One-time **risk notice on first launch**, with a **View Full Disclaimer** link to the full text. Please actually read it.
- Ketamine is now formally **GPLv3**, with a full `DISCLAIMER.md` in the repo.

## 🐛 Fixes & misc

- Fixed alternate icons rendering as the generic iOS icon.
- Fixed the wallpaper gallery tripping over Apple packs that ship without a description.
- Fixed the tweak config panel appearing after the catalog instead of under its own row.
- Fixed tab bar icons and inactive tile colour.
- New **Big thanks to** section in Settings for the Discord team keeping this place running.
- Joined a Discord? No? [Fix that.](https://discord.gg/Wt8dj8E8ZN)

---

🥚 *The last build's secrets didn't all get found. One of them even changed its name. Keep looking.*
