enum LK_RELIC { Breaker, Mirror, Ember, Knot, Siphon, LowLight, Crown, Vigor }

function lk_relic_catalog() {
    return [
        {name: "BREAKER SHELL", short: "SHELL", note: "ARMOR BREAK CLEARS THEIR SHOTS.", tint: C_TEAL},
        {name: "MIRROR IRON", short: "MIRROR", note: "MOST SHOTS BOUNCE ONCE.", tint: C_BLUE},
        {name: "EMBER MOTH", short: "MOTH", note: "EVERY FIFTH KILL BURSTS.", tint: C_PINK},
        {name: "SOUL KNOT", short: "KNOT", note: "REVIVE ONCE. 3 HP AND 4S OF PROTECTION.", tint: C_LILAC},
        {name: "HARVEST LAMP", short: "LAMP", note: "GAIN ENERGY EVERY THIRD KILL.", tint: C_GOLD},
        {name: "LOW LIGHT", short: "LIGHT", note: "EXTRA DAMAGE AT 2 HEALTH.", tint: C_MINT},
        {name: "KING'S RING", short: "RING", note: "EXTRA DAMAGE TO GUARDIANS.", tint: C_GOLD},
        {name: "QUICK HEART", short: "HEART", note: "KILLS LOWER SKILL COOLDOWN.", tint: C_PINK}
    ];
}

function lk_has_relic(_relic) {
    return player.relics[_relic];
}

function lk_relic_choices() {
    var _pool = [];
    for (var _i = 0; _i < array_length(relic_catalog); _i++) if (!lk_has_relic(_i)) array_push(_pool, _i);
    if (array_length(_pool) <= 0) return [];
    var _first = irandom(array_length(_pool) - 1);
    var _choice = [_pool[_first]];
    array_delete(_pool, _first, 1);
    if (array_length(_pool) > 0) array_push(_choice, _pool[irandom(array_length(_pool) - 1)]);
    return _choice;
}

function lk_take_relic(_choice) {
    cell.opened = true;
    player.relics[_choice] = true;
    relic_found[_choice] = true;
    mode = LK_MODE.Play;
    lk_sparks(240, 127, relic_catalog[_choice].tint, 24, 2);
    lk_ring(240, 137, relic_catalog[_choice].tint, 42, 24);
    lk_sound(snd_relic);
    lk_save();
}

function lk_relic_on_kill(_x, _y) {
    if (lk_has_relic(LK_RELIC.Ember) && kills mod 5 == 0) {
        lk_field(_x, _y, 1, 11, ceil(9 * player.power), 31, C_PINK);
    }
    if (lk_has_relic(LK_RELIC.Siphon) && kills mod 3 == 0) {
        player.energy = min(player.max_energy, player.energy + 10);
        lk_sparks(player.px, player.py - 4, C_BLUE, 6, 1.2);
    }
    if (lk_has_relic(LK_RELIC.Vigor) && player.skill_wait > 0) {
        player.skill_wait = max(0, player.skill_wait - 12);
    }
}

function lk_nova() {
    var _x = player.px;
    var _y = player.py;
    lk_ring(_x, _y, C_TEAL, 67, 23);
    lk_sound(snd_shield, .85);
    for (var _i = 0; _i < array_length(shots); _i++) {
        var _b = shots[_i];
        if (!_b.friendly && point_distance(_x, _y, _b.px, _b.py) < 72) _b.life = 1;
    }
}

function lk_temper_cost() {
    return 9 + player.temper[player.slot] * 7 + depth_no;
}

function lk_temper_changed() {
    var _slot = player.slot;
    if (player.coins < lk_temper_cost()) {
        lk_floater(240, 120, "NEED " + string(lk_temper_cost()) + "G", C_PINK);
        return false;
    }
    player.coins -= lk_temper_cost();
    player.temper[_slot] += 1;
    cell.opened = true;
    lk_sparks(240, 128, C_GOLD, 26, 2.4);
    lk_ring(240, 137, C_GOLD, 35, 26);
    return true;
}

function lk_remember_weapon(_id) {
    if (weapon_found[_id]) return;
    weapon_found[_id] = true;
    lk_save();
}

function lk_weapon_details(_id, _temper = 0) {
    var _weapon = weapons[_id];
    var _types = ["SHOT", "MELEE", "PIERCE", "BLAST", "BOUNCE", "CLOSE RANGE", "CHAIN", "RETURN",
        "POISON", "SHARD", "MORTAR", "ECHO", "ORBIT", "TURRET", "PHASE"];
    var _damage = ceil(_weapon.damage * (1 + _temper * .2));
    var _multiple = _weapon.count > 1 ? "X" + string(_weapon.count) : "";
    return string(_damage) + _multiple + " DMG  " + string(_weapon.cost) + " EN  " + _types[_weapon.kind];
}

function lk_sfx_for_weapon(_id, _heavy) {
    switch (_id) {
        case 12: return snd_disc;
        case 14: return snd_poison;
        case 16: return snd_mortar;
        case 21:
        case 22: return snd_wick;
    }
    return _heavy ? snd_heavy : snd_fire;
}
