enum LK_RELIC { Breaker, Mirror, Ember, Knot, Siphon, LowLight, Crown, Vigor, Canteen, Mantle }
enum LK_BOON {
    Armor, Health, Damage, Haste, Energy, Speed, Warm, Edge, Volley, Focus, Medic, StillWick,
    Afterstroke, KindledStep, Crossdraft, Guardfall, Pilgrim
}

function lk_relic_catalog() {
    return [
        {name: "BREAKER SHELL", short: "SHELL", note: "CLEAR SHOTS ON ARMOR BREAK AND AGAIN WHEN PROTECTION ENDS.",
            upgrade: "BOTH ARMOR BREAK PULSES CLEAR A WIDER RADIUS.", max_rank: 2, tint: C_TEAL},
        {name: "MIRROR IRON", short: "MIRROR", note: "MOST SHOTS BOUNCE ONCE.",
            upgrade: "MOST SHOTS BOUNCE TWICE.", max_rank: 2, tint: C_BLUE},
        {name: "EMBER MOTH", short: "MOTH", note: "EVERY FIFTH KILL BURSTS.",
            upgrade: "EVERY FOURTH KILL BURSTS.", max_rank: 2, tint: C_PINK},
        {name: "SOUL KNOT", short: "KNOT", note: "REVIVE ONCE. 3 HP AND 4S OF PROTECTION.", max_rank: 1, tint: C_LILAC},
        {name: "HARVEST LAMP", short: "LAMP", note: "GAIN 10 ENERGY EVERY THIRD KILL.",
            upgrade: "GAIN 16 ENERGY EVERY THIRD KILL.", max_rank: 2, tint: C_GOLD},
        {name: "LOW LIGHT", short: "LIGHT", note: "HALF HP: +40% WEAPON DMG. SURVIVE HP HIT: +1 ARMOR ONCE PER FIGHT.",
            upgrade: "2/3 HP: +40% WEAPON DMG. SURVIVE HP HIT: +2 ARMOR ONCE PER FIGHT.", max_rank: 2, tint: C_MINT},
        {name: "KING'S RING", short: "RING", note: "+25% DAMAGE TO GUARDIANS.",
            upgrade: "+40% DAMAGE TO GUARDIANS.", max_rank: 2, tint: C_GOLD},
        {name: "QUICK HEART", short: "HEART", note: "KILLS CUT SKILL COOLDOWN BY 0.2S.",
            upgrade: "KILLS CUT SKILL COOLDOWN BY 0.4S.", max_rank: 2, tint: C_PINK},
        {name: "EMBER CANTEEN", short: "FLASK", note: "GAIN 6 EXTRA ENERGY PER COMBAT CLEAR.",
            upgrade: "GAIN 12 EXTRA ENERGY PER COMBAT CLEAR.", max_rank: 2, tint: C_BLUE},
        {name: "THRESHOLD MANTLE", short: "MANTLE", note: "COMBAT CLEARS GRANT 1 WARD. WARD TAKES DAMAGE BEFORE ARMOR.",
            upgrade: "COMBAT CLEARS GRANT 2 WARD. WARD TAKES DAMAGE BEFORE ARMOR.", max_rank: 2, tint: C_GOLD}
    ];
}

function lk_relic_rank(_relic) {
    // Older checkpoints store true for an owned relic.
    var _value = player.relics[_relic];
    return _value >= 2 ? 2 : (_value ? 1 : 0);
}

function lk_boon_rank(_boon) {
    var _rank = 0;
    for (var _i = 0; _i < array_length(player.boons); _i++) {
        if (player.boons[_i] == _boon) _rank += 1;
    }
    return _rank;
}

function lk_low_light_active(_rank) {
    return _rank > 0 && player.hp <= ceil(player.max_hp * (_rank == 1 ? .5 : 2 / 3));
}

function lk_reward_rank(_relic, _id) {
    return _relic ? lk_relic_rank(_id) : lk_boon_rank(_id);
}

function lk_reward_note(_item, _rank) {
    return _rank >= 2 && variable_struct_exists(_item, "upgrade") ? _item.upgrade : _item.note;
}

function lk_reward_pair(_primary, _new, _upgrades) {
    var _is_new = lk_boon_rank(_primary) == 0;
    var _alternatives = _is_new ? _upgrades : _new;
    if (array_length(_alternatives) == 0) {
        _alternatives = _is_new ? _new : _upgrades;
        for (var _i = 0; _i < array_length(_alternatives); _i++) {
            if (_alternatives[_i] != _primary) continue;
            array_delete(_alternatives, _i, 1);
            break;
        }
    }
    return array_length(_alternatives) > 0
        ? [_primary, _alternatives[irandom(array_length(_alternatives) - 1)]] : [_primary];
}

function lk_first_shrine_boon(_preferred, _new, _upgrades, _skip = -1) {
    for (var _i = 0; _i < array_length(_preferred); _i++) {
        var _id = _preferred[_i];
        if (_id != _skip && (array_contains(_new, _id) || array_contains(_upgrades, _id))) return _id;
    }
    return -1;
}

function lk_reward_choices(_relic, _sparks = false) {
    var _catalog = _relic ? relic_catalog : boons;
    var _spark_pool = [LK_BOON.Haste, LK_BOON.Warm, LK_BOON.Edge, LK_BOON.Volley, LK_BOON.Focus,
        LK_BOON.StillWick, LK_BOON.Afterstroke, LK_BOON.KindledStep, LK_BOON.Guardfall];
    var _new = [];
    var _upgrades = [];
    var _early_shrine = !_relic && !_sparks && depth_no < 2 && lk_combat_armor_enabled();
    var _blades = 0;
    var _uses_energy = false;
    if (_early_shrine) {
        for (var _slot = 0; _slot < array_length(player.arms); _slot++) {
            var _weapon = weapons[player.arms[_slot]];
            if (lk_is_blade(_weapon.kind)) _blades++;
            if (_weapon.cost > 0) _uses_energy = true;
        }
    }
    for (var _i = 0; _i < array_length(_catalog); _i++) {
        if (!_relic) {
            if (_sparks && !array_contains(_spark_pool, _i)) continue;
            if (!_sparks && _i == LK_BOON.StillWick) continue;
            if (_early_shrine && (_i == LK_BOON.Guardfall || _i == LK_BOON.Edge) && _blades == 0) continue;
            if (_early_shrine && _i == LK_BOON.Afterstroke && _blades != 1) continue;
            if (_early_shrine && _i == LK_BOON.Warm && !_uses_energy) continue;
        }
        var _rank = lk_reward_rank(_relic, _i);
        if (_rank == 0) array_push(_new, _i);
        else if (_rank < _catalog[_i].max_rank) array_push(_upgrades, _i);
    }
    if (!_relic && _sparks) {
        var _wick = lk_boon_rank(LK_BOON.StillWick);
        var _haste = lk_boon_rank(LK_BOON.Haste);
        var _cooldown = _wick < boons[LK_BOON.StillWick].max_rank && _wick <= _haste
            ? LK_BOON.StillWick : LK_BOON.Haste;
        if (lk_boon_rank(_cooldown) < boons[_cooldown].max_rank) return lk_reward_pair(_cooldown, _new, _upgrades);
    } else if (_early_shrine) {
        var _combat = [LK_BOON.Guardfall, LK_BOON.Afterstroke, LK_BOON.KindledStep, LK_BOON.Warm, LK_BOON.Damage];
        var _primary = -1;
        if (player.hp < player.max_hp) {
            _primary = lk_first_shrine_boon([LK_BOON.Health, LK_BOON.Armor, LK_BOON.Medic], _new, _upgrades);
        } else if (irandom(3) == 0) {
            var _defense = irandom(1) == 0 ? [LK_BOON.Health, LK_BOON.Armor] : [LK_BOON.Armor, LK_BOON.Health];
            _primary = lk_first_shrine_boon(_defense, _new, _upgrades);
        }
        if (_primary == -1) _primary = lk_first_shrine_boon(_combat, _new, _upgrades);
        if (_primary != -1) {
            var _other = lk_first_shrine_boon(_combat, _new, _upgrades, _primary);
            if (_other != -1) return [_primary, _other];
            return lk_reward_pair(_primary, _new, _upgrades);
        }
    }
    if (array_length(_new) > 0 && array_length(_upgrades) > 0) {
        return [_new[irandom(array_length(_new) - 1)], _upgrades[irandom(array_length(_upgrades) - 1)]];
    }
    var _pool = array_length(_new) > 0 ? _new : _upgrades;
    if (array_length(_pool) == 0) return [];
    var _first = irandom(array_length(_pool) - 1);
    var _choice = [_pool[_first]];
    array_delete(_pool, _first, 1);
    if (array_length(_pool) > 0) array_push(_choice, _pool[irandom(array_length(_pool) - 1)]);
    return _choice;
}

function lk_take_relic(_choice) {
    if (cell.kind == LK_ROOM.Relic) cell.opened = true;
    player.relics[_choice] = lk_relic_rank(_choice) + 1;
    relic_found[_choice] = true;
    mode = LK_MODE.Play;
    lk_sparks(240, 127, relic_catalog[_choice].tint, 24, 2);
    lk_ring(240, 137, relic_catalog[_choice].tint, 42, 24);
    lk_sound(snd_relic);
    lk_save();
    lk_save_checkpoint();
}

function lk_relic_on_kill(_x, _y) {
    var _moth = lk_relic_rank(LK_RELIC.Ember);
    if (_moth > 0 && kills mod (6 - _moth) == 0) {
        lk_field(_x, _y, 1, 11, ceil(9 * player.damage_scale), 31, C_PINK);
    }
    var _lamp = lk_relic_rank(LK_RELIC.Siphon);
    if (_lamp > 0 && kills mod 3 == 0) {
        player.energy = min(player.max_energy, player.energy + 4 + _lamp * 6);
        lk_sparks(player.px, player.py - 4, C_BLUE, 6, 1.2);
    }
    if (player.skill_wait > 0) {
        player.skill_wait = max(0, player.skill_wait - 12 * lk_relic_rank(LK_RELIC.Vigor));
    }
}

#macro LK_FX_BREAKER 6

function lk_nova(_radius = 72, _shell_color = -1) {
    var _x = player.px;
    var _y = player.py;
    if (_shell_color == -1) lk_ring(_x, _y, C_TEAL, _radius - 5, 23);
    else lk_ring(_x, _y, _shell_color, _radius, 22, LK_FX_BREAKER);
    lk_sound(snd_shield, .85);
    for (var _i = 0; _i < array_length(shots); _i++) {
        var _b = shots[_i];
        if (!_b.friendly && point_distance(_x, _y, _b.px, _b.py) < _radius) _b.life = 1;
    }
}

function lk_temper_cost() {
    return 9 + player.temper[player.slot] * 7 + depth_no + lk_forge_surcharge();
}

function lk_temper_changed() {
    if (player.temper[player.slot] >= 3) return false;
    var _slot = player.slot;
    if (player.coins < lk_temper_cost()) {
        lk_floater(240, 120, "NEED " + string(lk_temper_cost()) + "G", C_PINK);
        return false;
    }
    player.coins -= lk_temper_cost();
    player.temper[_slot] += 1;
    cell.forge_jobs = lk_forge_jobs() + 1;
    lk_sparks(240, 128, C_GOLD, 26, 2.4);
    lk_ring(240, 137, C_GOLD, 35, 26);
    return true;
}

function lk_remember_weapon(_id) {
    if (weapon_found[_id]) return;
    weapon_found[_id] = true;
    lk_save();
}

function lk_weapon_details(_id, _temper = 0, _in_run = false, _fit = LK_FIT.None) {
    var _weapon = weapons[_id];
    var _types = ["SHOT", "MELEE", "PIERCE", "BLAST", "BOUNCE", "CLOSE RANGE", "CHAIN", "RETURN",
        "POISON", "SHARD", "MORTAR", "ECHO", "ORBIT", "TURRET", "PHASE", "CHARGE BOLT", "SHOCK RING",
        "BEAM", "PULL", "STACKING POISON", "BURST", "WALL SPLIT", "CHARGE BEAM", "SLOW TRAIL",
        "REFRACT", "RETURN + BOLT", "ECHO PELLETS", "POISON BLADE", "ORBIT BLADE"];
    var _damage = ceil(_weapon.damage * (1 + _temper * .2));
    var _multiple = _weapon.count > 1 ? "X" + string(_weapon.count) : "";
    var _cost = _in_run && _weapon.cost > 0 ? max(1, _weapon.cost - lk_boon_rank(LK_BOON.Focus)) : _weapon.cost;
    return string(_damage) + _multiple + " DMG  " + string(_cost) + " EN  " + _types[_weapon.kind]
        + (_fit == LK_FIT.None ? "" : " / " + fittings[_fit].name);
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
