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
| Continue a saved run from the title | Enter or C | A or Y |
| Start a new run instead | N | X |

Drag a window edge or use the desktop maximize button to change the window size. Fit mode keeps the game at 16:9 and fills the available space. Whole-pixel scaling uses the largest integer zoom that fits and falls back to fit in smaller windows. The game remembers your scaling mode.

Armor recovers faster after you clear a room. In Main Delve, Arsenal Run, and Daily Contract, the first point of armor repairs after three seconds without taking damage. Each additional point takes another five seconds during combat. A thin line inside the armor bar shows progress toward the next point.

In those contracts, shrines on the first two stages offer Bloodroot or Iron Bark unless you have both at max rank. Each rank of Bloodroot adds two max HP. Each rank of Iron Bark adds two max armor.

The keeper uses a backup pistol when the selected weapon runs out of energy. Visit gauntlets, shops, and shrines to equip a stronger build for the late stages.

Every stage has a Shrine of Ash and a forge. Forges temper weapons for gold, up to three times per weapon. Starting on stage two, look for a Shrine of Sparks for faster skill recharge, weapon perks, and cheaper forging. Shrines and reliquaries can offer a new reward or upgrade one you already own. Pause and hover over a weapon, relic, or boon to see its effect and current rank.

Guardian intros end on their own. Press E or A to skip once the guardian appears. During the fight, the name of an incoming ability appears beneath the guardian's health bar.

Bomb circles fill before they detonate. In Rupture rooms, two vents take turns erupting. In Flood Pulse, dashed lines warn you which lanes will flood.

Flank the Bulwark in Shield Line, destroy the nest before it summons more enemies in Brood Nest, and close both seals before leaving Twin Seals. Later rooms introduce Bellkeepers that rally nearby enemies, Cauterisers that set the floor on fire, and Threadbinders that link allies with a damaging beam. A stage never repeats a regular encounter type.

Destroy the Crown of Cinders' Furnace Anchors to remove its damage resistance. Anchors left alive at the last phase overload before disappearing.

Main Delve, Arsenal Run, and Daily Contract have 34 required fights and eight guardians. From stage three on, each stage also has a safe stop. Pick a weapon at the Salvage Rack, take energy or gold at the Keeper's Stores, or move one temper rank between weapons at the Temper Relay. Some optional gauntlets give way to an Elite Duel, a single fight with a weapon reward.

## Choose a contract

The main delve has eight stages across five biomes. Choose Iron Trial for faster enemies, less armor, and lasting wounds. Arsenal Run deals a fresh weapon pair after combat. Daily Contract uses a new dungeon seed each day. Beat the main delve or another finite contract to unlock Endless Keep, where each cycle adds pressure and elite enemies.

The game saves the run when you start a stage, clear a room, or collect rewards in a cleared room. After reloading, choose **Continue run**. If you reload during a fight, you return to the last safe room. Web saves stay in the browser and on the site where you started the run.

To leave from a cleared room, pause and choose **Save and exit**. Starting a new run replaces the previous save. Death and victory end the saved run.

## Edit and compile

Open `CinderBelow.yyp` in GameMaker LTS 2026. To compile the Linux build, run this from the game directory with the GameMaker CLI configured.

```sh
bunx @gamemaker/gm-cli compile CinderBelow.yyp --target linux
```

To play the project locally, select Linux in GameMaker and click **Run**.

## Build a web release

Push to `main` to build and deploy the web game to the `games` Worker. To retry a release, rerun **Deploy Cinder Below** from the Actions tab or run the workflow on `main`.

To configure the workflow, add these values under **Settings > Secrets and variables > Actions**:

- `GAMEMAKER_ACCESS_KEY` secret: a [GameMaker access key](https://gamemaker.io/en/account/access-keys) for an account that can export HTML5 builds.
- `CLOUDFLARE_API_TOKEN` secret: a [Cloudflare API token](https://dash.cloudflare.com/profile/api-tokens) with **Workers Scripts: Edit** for the account hosting `games`.
- `CLOUDFLARE_ACCOUNT_ID` variable: the ID of that Cloudflare account.

Set the base release number in `LK_VERSION`. Keep the `+dev` suffix in source. The workflow builds the pushed commit and stamps the game and pages with the same `major.minor.patch+commit` label. To build locally from a commit, run `python3 tools/build_web.py --help` for the required GameMaker paths. The script puts the finished website in the generated `site` directory.

## Render the soundtrack

Install `uv` and FFmpeg, then run this from the game directory to render a separate copy of the music:

```sh
uv run tools/render_score.py --cache .gmcache/piano --output .gmcache/score
```

The first run downloads [Steinway B piano samples](https://theremin.music.uiowa.edu/MISpiano.html) from the University of Iowa Electronic Music Studios. Evan Mazunik played the piano, and Michael Cash recorded it.
