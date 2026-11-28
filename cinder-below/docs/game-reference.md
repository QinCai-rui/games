# Cinder Below game reference

This reference lists 42 weapons, 8 keepers, 22 boons, 11 relics, 16 regular enemies, 12 guardians, and 5 contracts.

Times assume 60 game steps per second. Combat pauses and hit stop can make elapsed time longer. Thumbnails come from the game atlases or reproduce its drawn icons. Relics and boons share the game's colored-diamond design.

## Weapons

Damage is the base amount per projectile, swing, or first hit. The weapon's effect can add hits or change damage. Energy is per trigger pull. Delay is in game steps before bonuses.

| Art | Weapon | Damage | Energy | Delay | Effect |
| --- | --- | --- | --- | --- | --- |
| ![ember pistol](reference-art/ember-pistol.png) | Ember Pistol | 3 | 0 | 15 | Free single shot. Also fires as your fallback when you lack the energy for your selected weapon. |
| ![keeper blade](reference-art/keeper-blade.png) | Keeper Blade | 5 | 0 | 21 | Short forward slash. Cuts hostile bullets in its arc. |
| ![thorn carbine](reference-art/thorn-carbine.png) | Thorn Carbine | 3 | 1 | 8 | Fast single-shot carbine. |
| ![hex lantern](reference-art/hex-lantern.png) | Hex Lantern | 6 | 2 | 17 | Piercing, slowing bolt. Can hit two enemies. |
| ![cinder buckshot](reference-art/cinder-buckshot.png) | Cinder Buckshot | 3 × 5 | 3 | 24 | Wide five-pellet spread with ordinary projectile lifetime. |
| ![frost rail](reference-art/frost-rail.png) | Frost Rail | 12 | 4 | 27 | Fast, heavy piercing shot. Can hit and slow two enemies. |
| ![fire moth](reference-art/fire-moth.png) | Fire Moth | 8 | 4 | 24 | Slow shot that explodes on impact, damaging nearby enemies. |
| ![bramble scythe](reference-art/bramble-scythe.png) | Bramble Scythe | 9 | 0 | 21 | Longer, stronger forward slash. Cuts hostile bullets in its arc. |
| ![thunder fork](reference-art/thunder-fork.png) | Thunder Fork | 4 × 3 | 3 | 15 | Three piercing, slowing bolts in a spread. Each can hit two enemies. |
| ![prism repeater](reference-art/prism-repeater.png) | Prism Repeater | 4 | 1 | 11 | Single shot that can bounce twice off walls or pillars. |
| ![salt cannon](reference-art/salt-cannon.png) | Salt Cannon | 4 × 7 | 4 | 29 | Seven-pellet close-range spread. Pellets expire after 16 steps. |
| ![storm arc](reference-art/storm-arc.png) | Storm Arc | 9 | 3 | 22 | Lightning jumps to up to four targets within line of sight. Each jump reduces damage by 2, to a minimum of 2. |
| ![moon disc](reference-art/moon-disc.png) | Moon Disc | 5 | 2 | 35 | Returns after 21 steps or on impact with cover. It can hit the same enemy once on each leg. |
| ![sawtooth](reference-art/sawtooth.png) | Sawtooth | 7 | 0 | 31 | Full-circle melee sweep. Cuts hostile bullets around you. |
| ![venom flask](reference-art/venom-flask.png) | Venom Flask | 3 | 2 | 25 | Lobs a flask that leaves a poison pool. The pool repeatedly damages and slows enemies. |
| ![starshard](reference-art/starshard.png) | Starshard | 7 | 3 | 19 | Fast shard that can pierce and hit up to five enemies. |
| ![ashen mortar](reference-art/ashen-mortar.png) | Ashen Mortar | 12 | 4 | 34 | Short-range mortar that creates a delayed blast at impact or at the end of its flight. |
| ![glass needle](reference-art/glass-needle.png) | Glass Needle | 3 × 2 | 2 | 16 | Fires two closely spaced piercing, slowing needles. |
| ![echo rifle](reference-art/echo-rifle.png) | Echo Rifle | 6 | 3 | 23 | Fires the main shot immediately, then two angled follow-up shots from the same spot. |
| ![floodgate](reference-art/floodgate.png) | Floodgate | 4 × 3 | 3 | 23 | Fires three widely spaced shots. Each can bounce twice off walls or pillars. |
| ![crown chisel](reference-art/crown-chisel.png) | Crown Chisel | 12 | 1 | 39 | Long melee swing that cuts bullets and sends a short-range projectile for 40% of the swing's damage, rounded up. |
| ![wick spire](reference-art/wick-spire.png) | Wick Spire | 5 | 2 | 34 | Spawns a rotating spark around you for up to 109 steps. It can damage the same enemy again after its hit list resets. |
| ![ash beacon](reference-art/ash-beacon.png) | Ash Beacon | 5 | 5 | 67 | Places an auto-firing turret for about 3.1 seconds. It targets the nearest enemy in sight within 120 pixels. |
| ![wraith lance](reference-art/wraith-lance.png) | Wraith Lance | 8 | 3 | 23 | Piercing lance that passes through cover and can hit up to five enemies. |
| | Nail Driver | 6 | 3 | 12 | Hold and release for a piercing bolt. Charging adds damage, speed, and pierce. |
| | Hollow Bell | 10 | 3 | 37 | Expanding ring damages enemies close to the keeper. |
| | Cinder Thread | 3 | 1 | 8 | Sustained line hits enemies in its path while consuming energy. |
| | Gravehook | 4 | 2 | 36 | Returning disc pulls light enemies toward the keeper. |
| | Shale Breaker | 13 | 0 | 47 | Slow melee swing destroys breakable cover in one strike. |
| | Seep Flask | 3 | 3 | 29 | Lingering poison gets stronger when another flask lands in the same pool. |
| | Flint Choir | 4 | 4 | 39 | An opening shot leads into two bursts from the firing position. The final burst is stronger. |
| | Copper Kite | 4 | 4 | 61 | Places a rotating turret ahead of the keeper. |
| | Split Lantern | 7 | 3 | 28 | The shot splits into a fan on impact with terrain. |
| | White Ember | 10 | 4 | 17 | Hold and release a short beam. Charging increases its damage, reach, and width. |
| | Gutter Fang | 7 | 0 | 25 | Lunges forward before swinging. |
| | Siltcaster | 4 | 3 | 32 | Its projectile leaves a slowing trail. |
| | Cathedral Lens | 7 | 3 | 23 | Pierces enemies and refracts a shot off terrain. Fuse Hex Lantern and Prism Repeater. |
| | Briar Crucible | 7 | 1 | 29 | Melee hits leave small poison pools. Fuse Bramble Scythe and Venom Flask. |
| | Winter Wheel | 6 | 3 | 43 | The disc releases a piercing bolt when it turns back. Fuse Moon Disc and Frost Rail. |
| | Spark Crucible | 5 | 6 | 76 | Places a turret that chains lightning between enemies. Fuse Ash Beacon and Storm Arc. |
| | Ash Chorus | 3 × 3 | 4 | 33 | A delayed fan follows the opening pellets. Fuse Cinder Buckshot and Echo Rifle. |
| | Crown of Embers | 9 | 2 | 40 | Melee hits start or refresh an orbiting flame. Fuse Crown Chisel and Wick Spire. |

## Keepers and skills

All keepers are selectable at the start. Each starts with 100 energy and two weapons. Pace is in pixels per game step. Cooldowns are base values.

| Art | Keeper | HP | Armor | Pace | Starting weapons | Skill and cooldown | Effect |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ![warden](reference-art/warden.png) | Warden | 6 | 5 | 1.86 | Ember Pistol, Keeper Blade | Twin Flame · 7.00 s | For 4 seconds, adds a shot to ordinary ranged attacks, doubles melee damage, adds 4 damage to the first Storm Arc hit, or places a second Ash Beacon. |
| ![outrider](reference-art/outrider.png) | Outrider | 5 | 4 | 2.20 | Thorn Carbine, Ember Pistol | Phase Step · 2.37 s | Dashes for 12 steps, avoids damage, and deals 8 base damage once per enemy passed. |
| ![hexsmith](reference-art/hexsmith.png) | Hexsmith | 5 | 4 | 1.78 | Hex Lantern, Ember Pistol | Null Field · 5.33 s | Clears shots within 86 pixels and deals 10 base damage to nearby enemies. Slows those enemies for 2.5 seconds. |
| ![alchemist](reference-art/alchemist.png) | Alchemist | 5 | 4 | 1.94 | Venom Flask, Ember Pistol | Green Fire · 6.17 s | Throws two poison pools. Each repeatedly deals 4 base damage and slows enemies. |
| ![sentinel](reference-art/sentinel.png) | Sentinel | 7 | 5 | 1.62 | Sawtooth, Ember Pistol | Aegis · 6.50 s | Restores 1 armor and reflects shots in the direction you aim for 2.9 seconds. Reflected shots deal 3 damage. Movement slows by 12% while the shield is up. |
| ![stargazer](reference-art/stargazer.png) | Stargazer | 4 | 4 | 2.04 | Starshard, Keeper Blade | Starfall · 6.83 s | Marks up to five nearby enemies for 15-damage falling stars. If there are no targets, drops one star where you aim. |
| ![tidecaller](reference-art/tidecaller.png) | Tidecaller | 6 | 4 | 1.89 | Floodgate, Keeper Blade | Riptide · 6.50 s | An expanding wave clears shots, deals 7 base damage once per foe, slows it, and pushes regular enemies back. |
| ![oathbreaker](reference-art/oathbreaker.png) | Oathbreaker | 6 | 3 | 2.03 | Crown Chisel, Glass Needle | Blood Oath · 7.00 s | Spends 1 HP, down to a minimum of 1. For about 3.1 seconds, grants +23% movement speed and +35% weapon damage. A kill heals 1 HP when the run's kill count reaches a multiple of three. |

## Boons

Shrines offer up to two choices. Picking a boon you own adds one rank, up to its cap. A shrine pays 8 gold when its entire pool is maxed.

| Art | Boon | Max rank | Shrine | Effect |
| --- | --- | --- | --- | --- |
| ![iron bark](reference-art/iron-bark.png) | Iron Bark | 3 | Ash | +2 maximum armor and refill it, each rank. |
| ![bloodroot](reference-art/bloodroot.png) | Bloodroot | 3 | Ash | +2 maximum HP and heal 3 HP, each rank. |
| ![coal heart](reference-art/coal-heart.png) | Coal Heart | 3 | Ash | Multiply damage scaling by 1.20 per rank. This affects weapons and skills that use the damage stat. |
| ![quicken](reference-art/quicken.png) | Quicken | 3 | Ash and Sparks | Multiply attack rate and skill recharge rate by 1.20 per rank. This divides the delay and cooldown by 1.20, with rounding. |
| ![deep cell](reference-art/deep-cell.png) | Deep Cell | 3 | Ash | +30 maximum energy and refill it, each rank. |
| ![fleetfoot](reference-art/fleetfoot.png) | Fleetfoot | 3 | Ash | Multiply movement speed by 1.15 per rank. |
| ![warm chamber](reference-art/warm-chamber.png) | Warm Chamber | 1 | Ash and Sparks | Casting a skill makes the next attack free. |
| ![edgeguard](reference-art/edgeguard.png) | Edgeguard | 1 | Ash and Sparks | Recover 3 energy when a melee swing destroys at least one enemy shot. |
| ![volley rhythm](reference-art/volley-rhythm.png) | Volley Rhythm | 1 | Ash and Sparks | Every sixth qualifying ranged attack fires two extra side shots at 61% damage, rounded up with a minimum of 2. |
| ![cinder focus](reference-art/cinder-focus.png) | Cinder Focus | 2 | Ash and Sparks | Rank 1 lowers paid weapon attacks by 1 energy. Rank 2 lowers them by 2. Paid attacks cost at least 1. |
| ![medics vow](reference-art/medics-vow.png) | Medic's Vow | 2 | Ash | Heal 1 HP every fourth combat clear at rank 1, or every third at rank 2. The counter includes earlier clears. |
| ![smiths favor](reference-art/smiths-favor.png) | Smith's Favor | 2 | Ash and Sparks | Tempering costs 3 less gold at rank 1 and 6 less at rank 2. |
| ![still wick](reference-art/still-wick.png) | Still Wick | 2 | Sparks | Reduce skill cooldown by 12% at rank 1 and 24% at rank 2. This stacks with Quicken. |
| ![salvager](reference-art/salvager.png) | Salvager | 2 | Sparks | Gain 2 gold per combat clear at rank 1 and 4 gold at rank 2. |
| | Afterstroke | 1 | Ash and Sparks | A melee hit within the last 100 steps boosts the next ranged attack by 24%. |
| | Kindled Step | 1 | Ash and Sparks | Moving 110 pixels during combat boosts the next attack by 24%. |
| | Crossdraft | 1 | Ash | Side and rear hits push mobile enemies farther. |
| | Last Ember | 1 | Ash and Sparks | A paid attack deals 38% more damage when you have less than enough energy to buy two. |
| | Cold Conductor | 1 | Ash and Sparks | Lightning hitting a slowed target can arc 45% of that damage to a nearby enemy. |
| | Stillhand | 1 | Ash and Sparks | Stand still for 25 steps to boost Nail Driver or White Ember by 24%. |
| | Guardfall | 1 | Ash and Sparks | Cutting a hostile projectile boosts the next attack by 28% within 110 steps. |
| | Pilgrim's Wick | 1 | Ash | The first unvisited regular fight entered each stage restores 12 energy. |

## Relics

A reliquary offers up to two choices from stage 2 onward. Each choice grants a new relic or increases its rank. A reliquary pays 8 gold if all relics are maxed.

| Art | Relic | Max rank | Effect |
| --- | --- | --- | --- |
| ![breaker shell](reference-art/breaker-shell.png) | Breaker Shell | 2 | When armor drops to zero from a hit, clear hostile shots within 72 pixels at rank 1 or 104 at rank 2. |
| ![mirror iron](reference-art/mirror-iron.png) | Mirror Iron | 2 | Ordinary pellets, piercing bolts, Starshard, and Echo Rifle shots gain one bounce at rank 1 or two at rank 2. They bounce off walls and pillars. |
| ![ember moth](reference-art/ember-moth.png) | Ember Moth | 2 | Every fifth kill at rank 1, or fourth at rank 2, makes a delayed blast at the enemy's position. The blast starts at 9 damage and scales with your damage stat. |
| ![soul knot](reference-art/soul-knot.png) | Soul Knot | 1 | Revive once per run at 3 HP with 4 seconds of invulnerability. Clears nearby hostile shots and shows REVIVED. |
| ![harvest lamp](reference-art/harvest-lamp.png) | Harvest Lamp | 2 | Every third kill restores 10 energy at rank 1 or 16 at rank 2. |
| ![low light](reference-art/low-light.png) | Low Light | 2 | +40% weapon damage at 2 HP or below at rank 1, or 3 HP or below at rank 2. |
| ![kings ring](reference-art/kings-ring.png) | King's Ring | 2 | Deal +25% damage to guardians at rank 1 or +40% at rank 2. |
| ![quick heart](reference-art/quick-heart.png) | Quick Heart | 2 | Each kill cuts the remaining skill cooldown by 0.20 seconds at rank 1 or 0.40 at rank 2. |
| ![ember canteen](reference-art/ember-canteen.png) | Ember Canteen | 2 | Gain 6 extra energy per combat clear at rank 1 or 12 at rank 2. |
| ![gateward seal](reference-art/gateward-seal.png) | Gateward Seal | 2 | Restore 1 armor on each combat clear at rank 1 or 2 at rank 2, including in Iron Trial and Endless Keep. |
| ![guardians due](reference-art/guardians-due.png) | Guardian's Due | 2 | Each guardian drops 6 extra gold at rank 1 or 12 at rank 2. |

## Pickups, shop stock, and weapon tempering

Gold, energy, and hearts are proximity pickups. Weapons require interaction and replace the active slot. A swap leaves the old weapon and its temper on the floor.

| Art | Item or upgrade | Effect | Source |
| --- | --- | --- | --- |
| ![gold](reference-art/gold.png) | Gold | Pays for shop items and tempering. | Regular enemy 1–2 gold, elite 5, guardian 14 before Guardian's Due. Cache chest 3. Breakable props have a 1-in-3 chance to drop 1. |
| ![energy](reference-art/energy.png) | Energy pickup | Replenishes weapon energy by the amount on the pickup. | Enemy kill has a 1-in-4 chance to drop 9. Chest 20, gauntlet 25, guardian clear 35. |
| ![heart](reference-art/heart.png) | Heart | Heals 2 HP, up to max HP. | Guaranteed from gauntlets and guardian clears. Ordinary room clears have a 1-in-6 chance, rising to 7-in-12 at 2 HP or less. |
| ![heart](reference-art/heart.png) | Tonic | Heals 3 HP for 5 gold. | Tinker's Shop. Once per shop, only while below max HP. |
| ![energy](reference-art/energy.png) | Energy Cell | Restores 40 energy for 4 gold. | Tinker's Shop. Once per shop, only while below max energy. |
| ![Tinker](reference-art/tinker.png) | Shop weapon | Buys one stocked weapon and equips it in the active slot. Price = 10 + 3 × zero-based biome index + 2 × temper rank. | Tinker's Shop. Blueprints make specific weapons appear more often. The pool excludes Ember Pistol, Keeper Blade, and fusion results. |
|  | Temper +1 | +20% base weapon damage, rounded up after other attack multipliers. | Forge, or pre-tempered weapon loot starting at stage 4. |
|  | Temper +2 | +40% base weapon damage. | Forge, later loot and shops, or Arsenal Run at stages 7–8. |
|  | Temper +3 | +60% base weapon damage. This is the cap. | Forge or eligible late gear. |

Each forge lets you temper, fit, or fuse once. Tempering costs 9 gold + 7 × current temper + (stage − 1) − 3 × Smith's Favor rank. A fitting costs 7 gold + half the number of completed stages, rounded down. Fusing costs 9 gold. It consumes both ingredients and gives the result their average temper rounded down, plus an Ember Pistol in the spare slot.

Supply caches offer two weapons with different roles. Picking one removes the other. Trial rewards favor rarer weapons and arrive pre-tempered.

| Attachment | Effect |
| --- | --- |
| Split Collar | Adds two pellets, widens the spread, and lowers each pellet's damage. |
| Dense Core | Boosts direct damage by 22% and adds 25% attack delay. |
| Cold Wick | Slows targets and reduces direct damage by 18%. |
| Return Coil | Increases a disc's return speed by 24% and return damage by 30%. |
| Rebound Lens | Adds a bounce and reduces launch speed by 15%. |
| Wide Edge | Adds 11 pixels of melee reach and 20% attack delay. |
| Quick Fuse | Arms mortar and flask effects up to six steps sooner and reduces their radius by 25%. |
| Siphon Pin | Restores 3 energy for an eligible kill, up to 12 per room. |
| Sentry Clock | Cuts a turret's interval between attacks by about a third and its lifetime by 39 steps. |
| Hot Chamber | After three attacks hit in quick succession, subsequent attacks deal 35% more damage and cost one more energy. |

## Rooms, encounters, and props

| Room or object | What it does |
| --- | --- |
| Landing | Safe entry room at the start of each stage. |
| Ambush | Mixes a pursuer and a ranged enemy with foes drawn from the biome's pool. The Root Gates opener fields a Sentry, Spitter, Charger, and Skulk. |
| Crossfire | Sets up enemies along the left and right sides of the arena and adds one roaming enemy. If a spawn is blocked or too close to you, it falls back to a random position. |
| Elite Hunt | Opens with two elites plus regular enemies. On the sword route, one elite is a Bulwark beside a pillar. Glass Needle and Frost Rail shoot through its gold shield. Its aim line locks before it fires a blade-cuttable bolt for 2 damage. Other guns can flank the shield or fire during recoil. Clearing the room guarantees a weapon. |
| Rupture | Alternates eruptions between two fixed vents. Has two clusters of pillars. |
| Swarm | Opens with the biome's designated rusher type, with two extra enemies. |
| Shield Line | A Bulwark screens two ranged enemies while two pursuers circle. Flank its shield, attack during its recovery, or use piercing shots, blasts, or melee. |
| Brood Nest | A stationary Brood Husk can summon up to three reinforcements while its defenders keep you occupied. Destroy it to stop the next spawn. |
| Twin Seals | Close both seals with Interact and defeat all enemies to open the doors. Open seals can summon up to four reinforcements total. |
| Relay Guard | A Bellkeeper rallies two Sentries and nearby pursuers. Central pillars break sightlines as the guards prepare their next attacks. |
| Heat Works | A Cauteriser predicts your movement and leaves a patch of fire. A Bulwark screens the Cauteriser while two other enemies cover the flanks. |
| Threaded Crossing | A Threadbinder links two enemies. The beam follows them and starts dealing damage after a warning. Killing either linked enemy or the Threadbinder breaks it. |
| Shattered Colonnade | Two rows of pillars frame a central firing lane. Harpoons control the flanks, a Prism fires bouncing shots, and two Fracturelings split if killed. |
| Flood Pulse | The inner lane and the two outer lanes flood in turn. Move out of the marked lanes as you fight the defenders. |
| Supply Cache | The chest offers a weapon you are not carrying, 20 energy, and 3 gold. Its weapon pool excludes the Ember Pistol and Keeper Blade. |
| Tinker's Shop | Sells a Tonic, an Energy Cell, and one weapon. Each purchase is available once per shop. |
| Shrine of Ash | Choose one boon or rank upgrade. On stages 1 and 2 with combat armor repair enabled, the shrine offers Guardfall if you carry a blade and Afterstroke if you carry both a blade and a ranged weapon. Other options include Kindled Step, Warm Chamber for weapons that use energy, and Coal Heart. When wounded, you get a recovery option: Bloodroot, then Iron Bark or Medic's Vow if earlier options are capped. |
| Shrine of Sparks | Available from stage 2. Offers one spark boon or a rank upgrade. It prioritizes Still Wick or Quicken. |
| Reliquary | Available from stage 2. Offers one relic or a rank upgrade. |
| Temper Forge | Upgrades the weapon in the active slot once for gold. Every stage has one. |
| Salvage Rack | Pick one of two weapons. The selected weapon replaces your active weapon, which drops on the floor. |
| Keeper's Stores | Pick either 35 energy or 10 gold. |
| Temper Relay | Move one temper rank from the inactive weapon to the active weapon, or take 10 gold. |
| Gauntlet | Optional three-wave fight with floor hazards. Rewards one weapon from Bramble Scythe onward in the weapon table, a 2-HP heart, and 25 energy. |
| Elite Duel | A single elite rival attacks with less downtime. Winning earns a weapon from the gauntlet pool. Appears in place of the gauntlet on stages with Keeper's Stores. |
| Guardian room and portal | One guardian, two pillars, and a portal after all enemies are defeated. The portal advances the stage. The last portal ends a finite run or loops Endless Keep. |
| Pillar | Permanent cover. Blocks ordinary shots and movement. Compatible ricochet shots bounce off it. |
| Crate and small breakable prop | Blocks movement and shots until broken. Two points of durability. Each damaging hit removes at least one point, or one per four damage rounded down if greater. |

Fight doors stay locked until you finish the objectives and defeat every enemy. The main route has 34 regular fights in Main Delve, Arsenal, and Daily, or 49 in Iron and Endless, before shortcuts. All routes lead to eight guardians. Stage 4, 6, and 8 shortcuts cost 7 gold each and bypass one fight. Starting at stage 2, optional trials loop back through a reliquary.

The first Main Delve opens with Ambush. On consecutive return runs, the opening alternates between two pairs: Crossfire or Brood Nest, then Ambush or Shield Line. The side route can hold a one-wave Ambush instead of Swarm. The last regular fight draws a different encounter from the ones on your path.

Three inscriptions in Root Gates and 9 gold open the Buried Archive after stage 2. Either fork has the middle inscription. Clearing Sluice Machinery in Veil Tunnels lets you take a spindle to the Hollow sanctum and open the Drowned Furnace. These stages have six encounter templates each and replace stages 3 and 7.

A hitless Mossjaw win with any keeper unlocks the Warden's Nail Driver and Keeper Blade starting kit. On the first unlock, the Nail Driver also drops beside the portal. Switch to the slot you want to replace and interact to trade; the old weapon keeps its temper and fitting on the floor. Daily records the unlock but skips the drop and uses the original starting kit.

## Stages and floor hazards

| Arena art | Stage | Biome | Required fights (standard / Iron or Endless) | Gauntlet hazard |
| --- | --- | --- | --- | --- |
| ![Root Gates arena](reference-art/root-gates.png) | 1. Root Gates | Moss | 3 / 3 | Three offset bursts for 1 damage each. |
| ![Mossvault arena](reference-art/mossvault.png) | 2. Mossvault | Moss | 4 / 4 | Same moss bursts. |
| ![Emberworks arena](reference-art/emberworks.png) | 3. Emberworks | Cinder | 4 / 5 | Three blasts along a horizontal line in staggered order, 2 damage each. |
| ![Cinder Halls arena](reference-art/cinder-halls.png) | 4. Cinder Halls | Cinder | 4 / 6 | Same staggered cinder blasts. |
| ![Veil Tunnels arena](reference-art/veil-tunnels.png) | 5. Veil Tunnels | Veil | 4 / 7 | Three simultaneous blasts in a triangle, 2 damage each. |
| ![The Hollow arena](reference-art/the-hollow.png) | 6. The Hollow | Veil | 5 / 8 | Same triangular blasts. |
| ![Glassfen arena](reference-art/glassfen.png) | 7. Glassfen | Glassfen | 5 / 8 | Three staggered blasts in a line across the direction from the arena center, 2 damage each. |
| ![Black Reliquary arena](reference-art/black-reliquary.png) | 8. Black Reliquary | Black Reliquary | 5 / 8 | Four staggered blasts in a rotating cross, 2 damage each. |

Gauntlet hazards are centered near your projected position. Rupture vents stay in place and deal 1 damage. Guardians use their own hazard patterns.

## Regular enemies

Base HP is the starting value for the calculation. After stage, contract, cycle, elite, and summon adjustments, halve the result and round up. In the opening fight, an ordinary Skulk has 5 HP and a Spitter has 9.

| Art | Enemy | Base HP | Behavior |
| --- | --- | --- | --- |
| ![Skulk](reference-art/skulk.png) | Skulk | 9 | Some chase directly; others cut across your path. Lunges after a short tell. |
| ![Spitter](reference-art/spitter.png) | Spitter | 18 | Fires a fan of five shots, or seven if elite. Backs away up close. |
| ![Charger](reference-art/charger.png) | Charger | 30 | Marks a straight charge ahead of you. Stops at cover or a wall. |
| ![Wisp](reference-art/wisp.png) | Wisp | 18 | Alternates splitting stars with an eight-shot ring. Cut a star or put cover in its path before it splits into three. |
| ![Sentry](reference-art/sentry.png) | Sentry | 22 | Marks an intercept line and fires three shots along it for 2 damage each. Elites fire five. The burst breaks crates. |
| ![Leech](reference-art/leech.png) | Leech | 12 | Zigzags as it approaches, then lunges faster and farther than a Skulk. |
| ![Bruiser](reference-art/bruiser.png) | Bruiser | 38 | Fires three large shots, sets a nearby floor blast, and deals 2 contact damage. |
| ![Harpoon](reference-art/harpoon.png) | Harpoon | 22 | Creates distance, telegraphs a long aim line, and fires one fast shot. |
| ![Prism](reference-art/prism.png) | Prism | 24 | Flanks you and fires five shots that can bounce off pillars and walls. |
| ![Monk](reference-art/monk.png) | Monk | 34 | Marks the floor under you and to one side, then detonates both spots in sequence. |
|  | Bulwark | 32 | Blocks frontal projectiles while its shield is raised. It commits to a direction before charging and leaves its shield down during recovery. |
|  | Brood Husk | 36 | Stationary nest that warns before releasing a Skulk, or a Leech in Veil and deeper biomes. It can release up to three and cannot be pushed by ordinary hits. |
|  | Bellkeeper | 19 | Rings a warning bell and shortens the cooldowns of nearby ordinary allies. |
|  | Cauteriser | 26 | Predicts your movement and marks a spot that burns for more than two seconds. |
|  | Threadbinder | 28 | Connects allies with a damaging beam that tracks their positions. When alone, it fires a three-shot fan. |
|  | Fractureling | 22 | Pursues you and splits into up to two fragile, fast shards on death. Shards yield no loot. |
|  | Elite variant | ×2.25 HP | Gold-marked regular enemy with 9% faster movement and a larger collision radius. Drops 5 gold. |

| Biome | Standard spawn pool | Elite Hunt type | Swarm type |
| --- | --- | --- | --- |
| Moss | Skulk (double weight), Spitter, Charger, Sentry | Charger | Skulk |
| Cinder | Charger, Spitter, Bruiser, Sentry, Wisp | Bruiser | Charger |
| Veil | Wisp, Leech (double weight), Bruiser, Sentry | Leech | Leech |
| Glassfen | Harpoon (double weight), Prism, Wisp, Sentry | Harpoon | Prism |
| Black Reliquary | Monk (double weight), Prism, Bruiser, Harpoon | Monk | Bruiser |

## Guardians and abilities

In Main Delve, Arsenal Run, and Daily Contract, guardians have 132, 192, 203, 237, 259, 304, 315, and 360 HP on stages 1 through 8. Alternate guardians use the HP for their stage. In Iron Trial and Endless Keep, apply contract and cycle scaling to the base HP below, then halve the result and round up.

All twelve guardians brace under sustained fire. Gold marks beside the guardian show the guard closing. A burst deals more damage after you spend a few seconds dodging or attacking an escort. Guardians need at least 30 seconds of active combat to defeat. The intro, pauses, and hit-stop do not count. Quick Hand allows 60 seconds to clear a guardian room on stage 4 or later.

| Art | Guardian | Stage | Base HP | Named moves and changes during the fight |
| --- | --- | --- | --- | --- |
| ![Mossjaw](reference-art/mossjaw.png) | Mossjaw | 1 | 350 | **Moss Charge** ends in a bullet ring on open ground. A collision with cover or a wall cancels the ring and staggers Mossjaw for 0.9 seconds. **Thorn Fan** fires a spread while roots mark your path. **Root Trap** marks three floor blasts. At 51% HP, **Root Ring** adds six eruptions around Mossjaw. |
| ![The Rootbound](reference-art/the-rootbound.png) | The Rootbound | 2 | 510 | **Seed Halo** leaves a gap off to one side. **Thorn Salvo** sends a seed across the room that sheds thorns on both sides. Pillars and blades stop the seed. **Root Eruption** marks three blasts. Below 53% HP, a Sentry and a Charger join the fight. |
| ![The Tin Ram](reference-art/the-tin-ram.png) | The Tin Ram | 3 | 540 | **Rivet Mines** marks four blasts. During **Shrapnel Ring**, a gold shell absorbs hits. Each of the first three hits adds two pellets to the ring. The gap stays open. **Tin Volley** fires two three-shot bursts. |
| ![The Bell Forge](reference-art/the-bell-forge.png) | The Bell Forge | 4 | 630 | **Furnace Halo** fires a ring with a gap. **Coal Seams** marks four floor blasts. **Bellfire** fires two opposing spreads. Below 53% HP it summons two Sentries and adds delayed rings. |
| ![Veil Harrow](reference-art/veil-harrow.png) | Veil Harrow | 5 | 690 | **Veil Step** tries to teleport past you and fires. **Prism Bounce** fires nine bouncing shots. **Veil Sigils** marks four blasts around you. At 51% HP, the blasts grow and attacks come faster. |
| ![The Pale Regent](reference-art/the-pale-regent.png) | The Pale Regent | 6 | 810 | **Pale Halo** fires a ring with a gap. **Regent's Step** tries to teleport to your flank and fires. **Hollow Sigil** combines bouncing shots with a targeted blast. Below 53% HP it summons two Leeches and adds aimed shots and delayed rings. |
| ![The Gilded Eel](reference-art/the-gilded-eel.png) | The Gilded Eel | 7 | 840 | **Glass Surge** dashes, leaves shots behind, and ends in a delayed blast. **Fen Quakes** marks four blasts. **Gilded Crossfire** fires opposing spreads. **Shatter Ring** fires a ring and a delayed second ring. At 48% HP it summons two Prisms. |
| ![Crown of Cinders](reference-art/crown-of-cinders.png) | Crown of Cinders | 8 | 960 | **Golden Rupture** marks three blasts initially and four in later phases. **Cinder Halo** fires two rings with gaps in sequence. **Royal Volley** fires opposing spreads. At 69% HP, two Furnace Anchors activate, cut damage to the Crown by 45% before rounding, and fire warning beams. The Crown adds **Crown Prism**, a sweep of bouncing shots. At 34%, surviving anchors overload, a Prism joins the fight, and the Crown adds **Sovereign Charge**, a dash that fires sideways and ends in a ring. |
| | Briar Matron | 2 alternative | 510 | The left pod hatches a Sentry and the right hatches a Charger. Cutting a pod also kills its sprout. The Matron regrows one missing pod every four seconds. Its roots mark your path. Below 53% HP, a ring follows the eruptions. |
| | The Indexer | Buried Archive | Scales with contract | Breakable panels each reduce damage dealt to the guardian by 32%. |
| | The Split Regent | 6 alternative | Scales with contract | A reflected double telegraphs attacks. The Regent then shows the real attack direction. |
| | Sluice Sovereign | Drowned Furnace | Scales with contract | Alternating water lanes leave different safe corridors during attacks. |

## Contracts

| Contract | Rules |
| --- | --- |
| The Main Delve | Eight stages with standard armor repair and control over your weapon pair. Guardians drop a 2 HP heart. Portal transit restores armor, energy, and 1 HP. |
| Iron Trial | Starts at half the keeper's armor rounded up. Enemies have 13% more HP before rounding, move 13% faster, and tick down their attack cooldowns 17% faster. Armor repairs in cleared rooms only. No portal HP heal. |
| Arsenal Run | Uses standard recovery. Every combat clear, including guardians and gauntlets, gives two distinct random weapons and 17 extra energy. Both weapons are untempered on stages 1–3, +1 on 4–6, and +2 on 7–8. |
| Daily Contract | Uses standard recovery and a date-derived seed. Each stage reseeds with the date seed plus 8,731 per completed stage. Stores your best reached depth for the date. |
| Endless Keep | Unlocks after any finite win. The last portal restarts at stage 1 and advances the cycle. You keep your build. Later cycles raise enemy HP, add enemies and elites, and shorten hazard intervals. Armor repairs in cleared rooms only. |

The Keeper's Journal lists six recipes and tracks 16 discoveries across routes, fusions, and guardian feats. Those records can unlock eight shop blueprints, four alternate keeper kits, and additional contract modifiers. Weapons, fittings, relics, and boons belong to the run. Reloading mid-fight returns you to the last safe-room checkpoint.

## Difficulty values

| What changes difficulty | Current value |
| --- | --- |
| Enemy HP by stage | Regular enemies gain 2 HP per completed stage in standard contracts or 3 in Iron and Endless, before other multipliers. After the opening fight, ordinary Chargers, Bruisers, and Bulwarks gain another 2 HP plus 2 per stage after stage 2. |
| Iron and Endless HP scaling | Multiply by `1 + 0.12 × min(cycle, 7)`. Add 0.13 to the multiplier in Iron Trial. The first circuit is cycle 0. Endless HP scaling caps at +84%. |
| Count per ordinary wave | Base count = 4 + biome index (0–4, capped at 3) + 1 from wave 2 onward + a random 0 or 1 + up to 2 from the Endless cycle. Swarm adds 2. Elite Hunt instead starts with 2 elites and adds 2–4 more enemies depending on biome. |
| Endless elites | From cycle 1, the first eligible regular spawn in each wave is elite. From cycle 2, the first two are elite. Elite Hunt still spawns its two guaranteed elites. |
| Waves and time between fights | Main-path fights in Root Gates and Mossvault have 2 waves. In standard contracts, reinforcements appear 50 steps after the first wave dies and any seals close. In Iron and Endless they appear after 18 steps and can overlap the last foe. The low route has 1 wave. Later Ambush, Crossfire, and Rupture rooms can have 2 waves, with 50 steps between groups. Gauntlets have 3 waves. Enemies emerge over 24 steps. |
| Reinforcements | Summoned enemies have 65% of their usual base-plus-stage HP, rounded down before contract and cycle scaling. They do not drop loot or trigger kill rewards. |
| Hit damage | Most shots and contact hits deal 1. Dashes, guardians, Bruisers, and floor blasts can deal 2. In standard contracts, a hit that breaks armor does no HP damage. In Iron and Endless the leftover damage reaches HP. |
| Hit protection | After a hit, protection lasts 75 steps (1.25 seconds) in standard contracts or 32 steps in Iron and Endless. Room entry grants at least 22 steps. Soul Knot grants 240 steps on revive. |
| Armor repair in combat | When enabled, repair 1 point after 300 hit-free steps (5 seconds), then 1 per 180 steps (3 seconds). Taking damage or entering a fight with missing armor restarts the initial timer. |
| Armor repair out of combat | All contracts shorten the timer to at most 86 steps after a clear, then recover 1 point every 53 steps until full. Gateward Seal can grant immediate armor on clear. |
| Between-room and portal recovery | Main Delve clears grant 6 energy above half capacity or 11 at or below half. Other contracts grant 11. Empty Stores grants 7. Portals restore 30 energy and refill armor. They heal 1 HP in Main Delve, 2 in Arsenal, Daily, and Endless, and none in Iron. |
| Health and loot safety | At 2 HP or less, ordinary room clears increase the heart-drop chance to 7 in 12. The free Ember Pistol fires when the selected weapon would cost more energy than you have. |
| Periodic hazard cadence | Rupture first marks a vent after 108–143 steps, then alternates vents every 160 steps. Gauntlets first mark blasts after 145–212 steps, then trigger every 190 steps minus 11 per biome index (capped at three) and 6 per Endless cycle (capped at four). |
| Guardian timing | Intros last up to 90 steps and can be skipped once the guardian appears. Guardian cooldowns tick down by 0.5 per step in standard contracts or 1.25 in Iron and Endless, before contract modifiers. Windups and dash durations use normal steps. |
| Regular-room pursuit | After the opening fight, ordinary attackers in standard contracts take 10–16% less recovery time than in the opening fight. Pursuers walk 16% faster and other foes 10% faster. In Iron and Endless, foes start with 12 fewer cooldown steps, recover 30–36% sooner, and walk 40% or 24% faster. Duel rivals tick down cooldowns 55% faster. |
| Attack and movement penalties | A weapon's attack delay is its base delay divided by haste, rounded with a floor of 4 steps. Swapping slots imposes at least 6 steps before firing. Slowed enemies move at 53% pace. Elites and guardians halve the slow's duration, or shorten it to one fifth for guardians at half HP or below. They resist new slows until 30 steps after the effect ends. |
| Cover and room size | Combat takes place inside a 384 × 168 pixel rectangle. Cover layout is randomized from ten layouts for ordinary fights, with fixed pillar patterns for Elite Hunt, Rupture, and guardian rooms. |

Source files for the tables include [keeper and boon definitions](../objects/obj_keep/Create_0.gml), [weapons and combat](../scripts/lk_combat/lk_combat.gml), [room generation and loot](../scripts/lk_run/lk_run.gml), [relics and reward selection](../scripts/lk_relics/lk_relics.gml), [contracts and checkpoints](../scripts/lk_contracts/lk_contracts.gml), [guardian attacks and hazards](../scripts/lk_encounters/lk_encounters.gml), [champions and special projectiles](../scripts/lk_expansion/lk_expansion.gml), and [the Gilded Eel and late weapon behavior](../scripts/lk_late_combat/lk_late_combat.gml).
