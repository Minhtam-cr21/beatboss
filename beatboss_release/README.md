# BeatBoss

Minimal release files:

- `loader.lua` — downloads and runs the latest `main.lua`
- `main.lua` — BeatBoss UI + Auto Infinity Castle + unload/self-cleanup

## Run

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Minhtam-cr21/beatboss/main/loader.lua?nocache=" .. os.time()
))()
```

## Controls

- **Auto Infinity Castle** toggle: enables/disables automation
- **RightShift**: show/hide UI
- **Unload Script**: stops the worker, disconnects script-created UI events, removes UI, and clears `getgenv().BeatBossHub`
- Executing `main.lua` again automatically unloads the previous BeatBoss instance first

## Current behavior

The script uses the game's own Infinity Castle GUI flow rather than replaying the server remote directly:

1. Attempts to open the Infinity Castle prompt when possible
2. Clicks **Equip Best**
3. Clicks **Start**
4. Waits while the battle UI is active
5. On the reward screen, looks for visible buttons named/text like Claim / Collect / Next / Continue / Retry / OK / Close

The exact reward/next action has not yet been mapped from Cobalt, so that final step is best-effort until the exact button/event is captured.
