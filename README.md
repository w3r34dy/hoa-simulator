# HOASimulator

Rojo project for the Roblox game **HOASimulator**.

## Layout

- `default.project.json` maps local files into Roblox services.
- `src/shared` syncs to `ReplicatedStorage.Shared`.
- `src/server` syncs to `ServerScriptService.Server`.
- `src/client` syncs to `StarterPlayer.StarterPlayerScripts.Client`.
- `HOAsimulator.rbxl` is the existing Roblox place file kept at the repo root.

## Common Commands

Rojo is pinned in `aftman.toml`:

```powershell
aftman install
```

```powershell
rojo serve
```

Connect Roblox Studio with the Rojo plugin to sync this folder into the open place.

```powershell
rojo build -o build/HOASimulator.rbxl
```

Builds a place file from the Rojo source tree.

```powershell
rojo sourcemap default.project.json -o sourcemap.json
```

Generates a sourcemap for editor tooling.

The same commands are available through npm:

```powershell
npm run rojo:serve
npm run rojo:build
npm run rojo:sourcemap
```

## Notes

Rojo maps source files into Studio, but it does not extract scripts out of an existing `.rbxl` place. If the current place already contains scripts, open `HOAsimulator.rbxl` in Studio and either move/copy them into the matching `src` folders manually or use a Roblox place extraction tool before syncing this project back in.
