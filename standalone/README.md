# Aether Standalone

This folder is a standalone rewrite of AetherV2's client runtime and interface for Roblox BedWars place `6872274481`.

The old framework is not loaded, referenced, or required. `runtime.lua` supplies a new module lifecycle, settings system, profile store, keybind handler, notification layer, overlay host, friends/targets state, cleanup manager, and a completely new single-window GUI.

## Module parity

- `games/universal.lua`: 69 universal module registrations
- `games/6872274481.lua`: 210 BedWars module registrations
- Total registration sites retained: 279
- All original option-constructor calls are retained: toggles, sliders, dual sliders, dropdowns, text boxes, text lists, colours, targets, fonts, buttons, and the custom hotbar editor.

Some universal names are deliberately replaced by their BedWars-specific versions during startup, exactly as in the original loading order.

## Files

- `init.lua` — standalone entrypoint and resource loader
- `runtime.lua` — clean-room runtime and new GUI
- `games/universal.lua` — universal module port
- `games/6872274481.lua` — complete BedWars module port

Generic AetherV2 libraries and data files are read from the surrounding repository. They are utilities and game metadata, not the old GUI/framework.

## Running locally

Keep the downloaded repository under the executor's `aetherv2` folder, then execute:

```lua
loadstring(readfile('aetherv2/standalone/init.lua'))()
```

The loader also recognises `AetherV2/standalone/` and `standalone/`. If a local resource is missing, it falls back to the official `plutoxqqqq/AetherV2` repository.

## Controls

- `RightShift`: show or hide the interface
- Left-click a module: enable or disable it
- Right-click a module: open its settings
- Left-click a dropdown: next value
- Right-click a dropdown: previous value

Settings are saved to `aetherv2-standalone/profile.json` when filesystem APIs are available.

## Validation

The four executable files pass both a Luau grammar parse and a Luau compiler pass. Static parity checks confirm the same 69 universal and 210 BedWars `CreateModule` registrations and identical option-constructor counts in the source and standalone game files.

Live behaviour still depends on the current BedWars client internals and executor capabilities. A BedWars update can invalidate controller paths or remote discovery even when the standalone runtime itself is valid.
