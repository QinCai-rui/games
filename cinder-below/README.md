# Cinder Below

Cinder Below is a single-player pixel-art dungeon shooter for Linux. Clear each room, find weapons and relics, and defeat the guardians to relight the keep.

## Controls

| Action | Keyboard and mouse | Controller |
|---|---|---|
| Move | WASD or arrows | Left stick or D-pad |
| Fire with auto-aim | Space | RT or RB |
| Aim and fire | Left mouse button | Right stick |
| Keeper skill | Q | LB |
| Pick up, interact, or confirm | E or Enter in menus | A |
| Swap weapons | Tab or scroll. Press 1 or 2 for a slot. | X |
| Pause | Esc | Start |
| Toggle fullscreen | F11 | |
| Switch between fit and whole-pixel scaling | F10 | |
| Mute | M | |
| Journal from the title | J | |
| Contracts from the title | R | B |
| Save and exit from a cleared room | Esc, then S | Start, then Y |
| Continue a saved run from the title | C | Y |

Drag a window edge or use the desktop maximize button to change the window size. Fit mode keeps the game at 16:9 and fills the available space. Whole-pixel scaling uses the largest integer zoom that fits and falls back to fit in smaller windows. The game remembers your scaling mode.

Armor recovers faster after you clear a room. During combat in Main Delve, Arsenal Run, and Daily Contract, armor recovers one point every five seconds without taking damage. A thin line inside the armor bar shows progress toward the next point.

The keeper uses a backup pistol when the selected weapon runs out of energy. Visit gauntlets, shops, and shrines to equip a stronger build for the late stages.

## Choose a contract

The main delve has eight stages across five biomes. Choose Iron Trial for faster enemies, less armor, and lasting wounds. Arsenal Run deals a fresh weapon pair after combat. Daily Contract uses a new dungeon seed each day. Beat the main delve or another finite contract to unlock Endless Keep, where each cycle adds pressure and elite enemies.

To suspend a run, pause in a cleared room and choose **Save and exit**. Continue from the title to pick up where you left off.

## Edit and compile

Open `CinderBelow.yyp` in GameMaker LTS 2026. To compile the Linux build, run this from the game directory with the GameMaker CLI configured.

```sh
bunx @gamemaker/gm-cli compile CinderBelow.yyp --target linux
```

To play the project locally, select Linux in GameMaker and click **Run**. The project uses original pixel sprites and synthesized music and effects.
