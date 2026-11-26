randomize();
window_set_caption("Cinder Below " + LK_VERSION);

mode = LK_MODE.Title;
hero_id = 0;
tick = 0;
world_tick = 0;
muted = false;
music_voices = [];
music_gain = .82;
music_fade_in = 0;
weapons = lk_weapons();
fittings = lk_fittings();
fusion_recipes = lk_fusion_recipes();
discovery_catalog = lk_discovery_catalog();
discoveries = array_create(array_length(discovery_catalog), false);
modifier_catalog = lk_modifier_catalog();
chosen_modifier = LK_OMEN.None;
use_alt_loadout = false;
heroes = [
    {name: "WARDEN", hp: 6, armor: 5, speed: 1.86, arms: [0, 1], skill: "TWIN FLAME", recharge: 420,
        note: "FIRE AN EXTRA SHOT FOR 4 SECONDS.", tint: C_TEAL},
    {name: "OUTRIDER", hp: 5, armor: 4, speed: 2.20, arms: [2, 0], skill: "PHASE STEP", recharge: 142,
        note: "DASH THROUGH SHOTS AND STRIKE ENEMIES.", tint: C_PINK},
    {name: "HEXSMITH", hp: 5, armor: 4, speed: 1.78, arms: [3, 0], skill: "NULL FIELD", recharge: 320,
        note: "CLEAR NEARBY SHOTS AND DAMAGE ENEMIES.", tint: C_LILAC},
    {name: "ALCHEMIST", hp: 5, armor: 4, speed: 1.94, arms: [14, 0], skill: "GREEN FIRE", recharge: 370,
        note: "CAST A TWIN POISON POOL THAT SLOWS FOES.", tint: C_MINT},
    {name: "SENTINEL", hp: 7, armor: 5, speed: 1.62, arms: [13, 0], skill: "AEGIS", recharge: 390,
        note: "REFLECT SHOTS IN THE DIRECTION YOU AIM.", tint: C_BLUE},
    {name: "STARGAZER", hp: 4, armor: 4, speed: 2.04, arms: [15, 1], skill: "STARFALL", recharge: 410,
        note: "MARK NEARBY FOES FOR FALLING STARS.", tint: C_GOLD},
    {name: "TIDECALLER", hp: 6, armor: 4, speed: 1.89, arms: [19, 1], skill: "RIPTIDE", recharge: 390,
        note: "SEND OUT A WAVE THAT CLEARS SHOTS AND SHOVES FOES.", tint: C_BLUE},
    {name: "OATHBREAKER", hp: 6, armor: 3, speed: 2.03, arms: [20, 17], skill: "BLOOD OATH", recharge: 420,
        note: "SPEND 1 HEALTH FOR SPEED AND DAMAGE. KILLS CAN HEAL.", tint: C_PINK}
];
stage_names = ["ROOT GATES", "MOSSVAULT", "EMBERWORKS", "CINDER HALLS", "VEIL TUNNELS", "THE HOLLOW", "GLASSFEN", "BLACK RELIQUARY"];
boss_names = ["MOSSJAW", "THE ROOTBOUND", "THE TIN RAM", "THE BELL FORGE", "VEIL HARROW", "THE PALE REGENT", "THE GILDED EEL", "CROWN OF CINDERS"];
boss_titles = ["WARDEN OF THE ROOT GATES", "HEART OF THE MOSSVAULT", "SIEGE ENGINE OF THE EMBERWORKS",
    "THE FURNACE THAT WALKS", "HUNTER BETWEEN VEILS", "REGENT OF THE HOLLOW",
    "TERROR OF THE GLASSFEN", "LAST KEEPER OF THE FLAME"];
boons = [
    {name: "IRON BARK", short: "BARK", note: "+2 MAX ARMOR. REFILL ARMOR.", max_rank: 3, tint: C_TEAL},
    {name: "BLOODROOT", short: "BLOOD", note: "+2 MAX HEALTH. HEAL 3.", max_rank: 3, tint: C_PINK},
    {name: "COAL HEART", short: "COAL", note: "+20% WEAPON DAMAGE.", max_rank: 3, tint: C_GOLD},
    {name: "QUICKEN", short: "QUICK", note: "SHOOT AND RECAST SKILLS FASTER.", max_rank: 3, tint: C_LILAC},
    {name: "DEEP CELL", short: "CELL", note: "+30 MAX ENERGY. REFILL ENERGY.", max_rank: 3, tint: C_BLUE},
    {name: "FLEETFOOT", short: "FLEET", note: "+15% MOVEMENT SPEED.", max_rank: 3, tint: C_MINT},
    {name: "WARM CHAMBER", short: "WARM", note: "YOUR SKILL MAKES THE NEXT ATTACK FREE.", max_rank: 1, tint: C_GOLD},
    {name: "EDGEGUARD", short: "EDGE", note: "CUT BULLETS WITH MELEE TO RESTORE ENERGY.", max_rank: 1, tint: C_TEAL},
    {name: "VOLLEY RHYTHM", short: "VOLLEY", note: "EVERY SIXTH RANGED ATTACK FIRES EXTRA SHOTS.", max_rank: 1, tint: C_LILAC},
    {name: "CINDER FOCUS", short: "FOCUS", note: "WEAPONS COST 1 LESS ENERGY. MINIMUM 1.",
        upgrade: "WEAPONS COST 2 LESS ENERGY. MINIMUM 1.", max_rank: 2, tint: C_BLUE},
    {name: "MEDIC'S VOW", short: "MEDIC", note: "HEAL 1 HP EVERY FOUR COMBAT CLEARS.",
        upgrade: "HEAL 1 HP EVERY THREE COMBAT CLEARS.", max_rank: 2, tint: C_MINT},
    {name: "SMITH'S FAVOR", short: "SMITH", note: "WEAPON TEMPERING COSTS 3 LESS GOLD.",
        upgrade: "WEAPON TEMPERING COSTS 6 LESS GOLD.", max_rank: 2, tint: C_GOLD},
    {name: "STILL WICK", short: "WICK", note: "KEEPER SKILL COOLDOWN IS 12% SHORTER.",
        upgrade: "KEEPER SKILL COOLDOWN IS 24% SHORTER.", max_rank: 2, tint: C_TEAL},
    {name: "SALVAGER", short: "SALV", note: "GAIN 2 GOLD PER COMBAT CLEAR.",
        upgrade: "GAIN 4 GOLD PER COMBAT CLEAR.", max_rank: 2, tint: C_GOLD},
    {name: "AFTERSTROKE", short: "AFTER", note: "A MELEE HIT BOOSTS YOUR NEXT RANGED ATTACK.", max_rank: 1, tint: C_PINK},
    {name: "KINDLED STEP", short: "STEP", note: "MOVEMENT IN COMBAT CHARGES YOUR NEXT ATTACK.", max_rank: 1, tint: C_GOLD},
    {name: "CROSSDRAFT", short: "DRAFT", note: "SHOTS FROM THE SIDE OR REAR PUSH ENEMIES FARTHER.", max_rank: 1, tint: C_TEAL},
    {name: "LAST EMBER", short: "LAST", note: "YOUR LAST AFFORDABLE PAID ATTACK HITS HARDER.", max_rank: 1, tint: C_PINK},
    {name: "COLD CONDUCTOR", short: "COLD", note: "LIGHTNING ON A SLOWED ENEMY CAN ARC TO ANOTHER.", max_rank: 1, tint: C_BLUE},
    {name: "STILLHAND", short: "STILL", note: "STAND STILL TO BOOST NAIL DRIVER AND WHITE EMBER.", max_rank: 1, tint: C_LILAC},
    {name: "GUARDFALL", short: "GUARD", note: "CUT PROJECTILES TO BOOST YOUR NEXT ATTACK.", max_rank: 1, tint: C_MINT},
    {name: "PILGRIM'S WICK", short: "WICK", note: "THE FIRST NEW FIGHT EACH STAGE RESTORES 12 ENERGY.", max_rank: 1, tint: C_BLUE}
];
selected = 0;
relic_catalog = lk_relic_catalog();
weapon_found = array_create(array_length(weapons), false);
relic_found = array_create(array_length(relic_catalog), false);
contracts = lk_contract_list();
chosen_contract = LK_CONTRACT.Delve;
run_contract = LK_CONTRACT.Delve;
contract_from = LK_MODE.Title;
contract_best = array_create(array_length(contracts), 0);
daily_record_date = 0;
daily_record_depth = 0;
checkpoint_available = file_exists(LK_CHECKPOINT) || file_exists(LK_CHECKPOINT + ".previous");
journal_tab = 0;
journal_item = 0;
runs_started = 0;
total_kills = 0;
best_floor = 0;
wins = 0;
ini_open("lantern_keep.ini");
best_floor = ini_read_real("runs", "best_depth", 0);
wins = ini_read_real("runs", "expanded_wins", 0);
muted = ini_read_real("settings", "muted", 0) != 0;
integer_scaling = ini_read_real("settings", "integer_scaling", 0) != 0;
runs_started = ini_read_real("runs", "started", 0);
tour_next_run = ini_read_real("settings", "tour", runs_started == 0) != 0;
tour_skipped_seed = ini_read_real("settings", "tour_skipped_seed", -1);
total_kills = ini_read_real("runs", "archived_kills", 0);
daily_record_date = ini_read_real("daily", "date", 0);
daily_record_depth = ini_read_real("daily", "depth", 0);
for (var _i = 0; _i < array_length(contract_best); _i++) {
    contract_best[_i] = ini_read_real("contracts", string(_i), 0);
}
contract_best[LK_CONTRACT.Delve] = max(contract_best[LK_CONTRACT.Delve], best_floor);
for (var _i = 0; _i < array_length(weapon_found); _i++) {
    weapon_found[_i] = ini_read_real("armory", string(_i), 0) > 0;
}
for (var _i = 0; _i < array_length(relic_found); _i++) {
    relic_found[_i] = ini_read_real("relics", string(_i), 0) > 0;
}
for (var _i = 0; _i < array_length(discoveries); _i++) {
    discoveries[_i] = ini_read_real("discoveries", string(_i), 0) > 0;
}
ini_close();
lk_display_start();
