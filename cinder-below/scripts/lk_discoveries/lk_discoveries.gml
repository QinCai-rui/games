enum LK_OMEN { None, EmptyStores, Restless, Frugal, Unstable, Brittle, Deep }

function lk_discovery_catalog() {
    return [
        ["ROOT INSCRIPTION", "EXAMINE THE MARK IN ROOT GATES."],
        ["MOSS INSCRIPTION", "EXAMINE A SECOND MARK IN ROOT GATES."],
        ["GATE INSCRIPTION", "FIND THE LAST MARK BEFORE MOSSJAW."],
        ["SLUICE MACHINERY", "INTERACT WITH THE MACHINE AFTER ITS GUARDS FALL."],
        ["THE BURIED ARCHIVE", "FIND THREE INSCRIPTIONS AND PAY TO ENTER THE ARCHIVE."],
        ["THE DROWNED FURNACE", "BRING THE SLUICE SEAL TO THE HOLLOW SANCTUM."],
        ["CATHEDRAL LENS", "FUSE HEX LANTERN AND PRISM REPEATER."],
        ["BRIAR CRUCIBLE", "FUSE BRAMBLE SCYTHE AND VENOM FLASK."],
        ["WINTER WHEEL", "FUSE MOON DISC AND FROST RAIL."],
        ["SPARK CRUCIBLE", "FUSE ASH BEACON AND STORM ARC."],
        ["ASH CHORUS", "FUSE CINDER BUCKSHOT AND ECHO RIFLE."],
        ["CROWN OF EMBERS", "FUSE CROWN CHISEL AND WICK SPIRE."],
        ["UNTOUCHED ROOTS", "FELL MOSSJAW WITHOUT TAKING A HIT."],
        ["STRANGE FLAME", "FELL ONE OF THE FOUR ALTERNATE GUARDIANS."],
        ["QUICK HAND", "CLEAR A STAGE 4 OR LATER GUARDIAN IN 35 SECONDS."],
        ["LAST LIGHT", "FELL THE CROWN OF CINDERS WITH AT MOST ONE HIT."]
    ];
}

function lk_discover(_index) {
    if (discoveries[_index]) return false;
    discoveries[_index] = true;
    lk_save();
    lk_floater(player.px, player.py - 28, discovery_catalog[_index][0] + " RECORDED", C_GOLD, 100);
    return true;
}

function lk_guardian_mastery() {
    if (depth_no == 0 && guardian_hits == 0) lk_discover(12);
    if (lk_guardian_id(cell) != LK_GUARDIAN.Original) lk_discover(13);
    if (depth_no >= 3 && world_tick - guardian_started_at <= 2100) lk_discover(14);
    if (depth_no == 7 && guardian_hits <= 1) lk_discover(15);
}

function lk_blueprint_available(_id) {
    var _catalog = [24, 25, 26, 27, 29, 31, 32, 35];
    var _sources = [0, 2, 4, 5, 7, 9, 13, 14];
    for (var _i = 0; _i < array_length(_catalog); _i++) {
        if (_catalog[_i] == _id) return discoveries[_sources[_i]];
    }
    return false;
}

function lk_keeper_arms(_id, _alternate) {
    if (_alternate && chosen_contract != LK_CONTRACT.Daily) {
        if (_id == 0 && discoveries[12]) return [24, 1];
        if (_id == 1 && discoveries[13]) return [27, 0];
        if (_id == 3 && discoveries[4]) return [29, 0];
        if (_id == 6 && discoveries[5]) return [35, 1];
    }
    return heroes[_id].arms;
}

function lk_modifier_catalog() {
    return [
        ["NO MODIFIER", "STANDARD CONTRACT RULES.", -1],
        ["EMPTY STORES", "65 STARTING ENERGY. LESS ON CLEAR.", -1],
        ["RESTLESS", "ENEMIES RECOVER FASTER BETWEEN ATTACKS.", -1],
        ["FRUGAL FORGE", "FORGES SKIP EVEN-NUMBERED STAGES.", 6],
        ["UNSTABLE ARSENAL", "FITTINGS CHANGE AT SAFE STOPS.", 7],
        ["BRITTLE WARD", "ARMOR REPAIRS AFTER COMBAT ONLY.", 12],
        ["DEEP OMEN", "MORE ELITES AND BETTER TRIAL LOOT.", 13]
    ];
}

function lk_has_modifier(_id) {
    return variable_struct_exists(player, "challenge") && player.challenge == _id;
}

function lk_modifier_choice(_contract, _selected) {
    if (_contract == LK_CONTRACT.Daily) return 1 + lk_date_seed() mod (array_length(modifier_catalog) - 1);
    return _selected;
}

function lk_cycle_modifier(_current) {
    repeat (array_length(modifier_catalog)) {
        _current = (_current + 1) mod array_length(modifier_catalog);
        var _required = modifier_catalog[_current][2];
        if (_required < 0 || discoveries[_required]) return _current;
    }
    return LK_OMEN.None;
}

function lk_unstable_roll() {
    if (!lk_has_modifier(LK_OMEN.Unstable)) return;
    var _saved = player.slot;
    for (var _i = 0; _i < 2; _i++) {
        if (player.attachments[_i] == LK_FIT.None) continue;
        player.slot = _i;
        lk_equip_weapon(_i, player.arms[_i], player.temper[_i], lk_fit_for_forge());
        lk_floater(210 + _i * 60, 115, fittings[player.attachments[_i]].name, C_LILAC);
    }
    player.slot = _saved;
}
