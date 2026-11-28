enum LK_GUARDIAN { Original, Indexer, Sluice, Matron, Split }

// Checkpoints keep the chosen room, including its guardian. Older rooms use the original.
function lk_guardian_id(_room) {
    return variable_struct_exists(_room, "guardian") ? _room.guardian : LK_GUARDIAN.Original;
}

function lk_assign_guardian(_room) {
    if (_room.kind != LK_ROOM.Boss || variable_struct_exists(_room, "guardian")) return;
    var _variant = lk_route_variant();
    _room.guardian = LK_GUARDIAN.Original;
    if (_variant == 1) _room.guardian = LK_GUARDIAN.Indexer;
    else if (_variant == 2) _room.guardian = LK_GUARDIAN.Sluice;
    else if (_room.seed mod 2 == 0) {
        if (depth_no == 1) _room.guardian = LK_GUARDIAN.Matron;
        if (depth_no == 5) _room.guardian = LK_GUARDIAN.Split;
    }
}

function lk_guardian_name(_room) {
    switch (lk_guardian_id(_room)) {
        case LK_GUARDIAN.Indexer: return "THE INDEXER";
        case LK_GUARDIAN.Sluice: return "SLUICE SOVEREIGN";
        case LK_GUARDIAN.Matron: return "BRIAR MATRON";
        case LK_GUARDIAN.Split: return "THE SPLIT REGENT";
    }
    return boss_names[depth_no];
}

function lk_guardian_title(_room) {
    switch (lk_guardian_id(_room)) {
        case LK_GUARDIAN.Indexer: return "BREAK THE PANELS TO WEAKEN ITS WARD";
        case LK_GUARDIAN.Sluice: return "MOVE BETWEEN THE FLOOD CHANNELS";
        case LK_GUARDIAN.Matron: return "CUT THE PODS BEFORE THEY HATCH";
        case LK_GUARDIAN.Split: return "WATCH THE DOUBLE. DODGE THE REAL STRIKE.";
    }
    return boss_titles[depth_no];
}

function lk_furnish_guardian(_room) {
    switch (lk_guardian_id(_room)) {
        case LK_GUARDIAN.Indexer:
            lk_add_prop(_room, 132, 106, 1);
            lk_add_prop(_room, 348, 106, 1);
            return true;
        case LK_GUARDIAN.Sluice:
            lk_add_prop(_room, 95, 143, 1);
            lk_add_prop(_room, 385, 143, 1);
            return true;
        case LK_GUARDIAN.Matron:
            lk_add_prop(_room, 122, 105, 0);
            lk_add_prop(_room, 358, 105, 0);
            lk_add_prop(_room, 110, 186, 1);
            lk_add_prop(_room, 370, 186, 1);
            return true;
        case LK_GUARDIAN.Split:
            lk_add_prop(_room, 112, 127, 1);
            lk_add_prop(_room, 368, 159, 1);
            return true;
    }
    return false;
}

function lk_guardian_start(_e) {
    _e.guardian_parts = [];
    switch (_e.guardian) {
        case LK_GUARDIAN.Indexer:
            _e.color = C_GOLD;
            _e.guardian_parts = [lk_guardian_part(_e, 164, 157), lk_guardian_part(_e, 316, 157)];
            _e.guardian_parts[0].emerge = 0;
            _e.guardian_parts[1].emerge = 0;
            break;
        case LK_GUARDIAN.Sluice:
            _e.color = C_BLUE;
            break;
        case LK_GUARDIAN.Matron:
            _e.color = C_MINT;
            _e.guardian_parts = [lk_guardian_part(_e, 162, 154), lk_guardian_part(_e, 318, 154)];
            _e.guardian_parts[0].emerge = 0;
            _e.guardian_parts[1].emerge = 0;
            _e.regrow = 240;
            _e.next_pod = 0;
            break;
        case LK_GUARDIAN.Split:
            _e.color = C_LILAC;
            _e.px = 193;
            _e.py = 113;
            break;
    }
}

function lk_guardian_part(_owner, _x, _y) {
    var _part = lk_spawn(LK_ENEMY.Sentry, _x, _y, false, true);
    _part.guardian_owner = _owner;
    _part.color = _owner.guardian == LK_GUARDIAN.Indexer ? C_GOLD : C_MINT;
    _part.radius = 11;
    _part.hp = lk_enemy_max_hp(9 + depth_no * 2);
    _part.max_hp = _part.hp;
    _part.cool = 130;
    _part.sprout = undefined;
    _part.hatching = false;
    return _part;
}

function lk_guardian_part_step(_part) {
    var _owner = _part.guardian_owner;
    if (_owner.guardian != LK_GUARDIAN.Matron) return;
    if (!is_undefined(_part.sprout) && _part.sprout.alive) return;
    if (_part.cool <= 30 && !_part.hatching) {
        _part.hatching = true;
        _part.cool = 30;
        lk_ring(_part.px, _part.py, C_MINT, 24, 30);
    }
    if (_part.cool > 0) return;
    // A living pod hatches one sprout at a time.
    _part.sprout = lk_spawn(_part.px < 240 ? LK_ENEMY.Sentry : LK_ENEMY.Charger, _part.px, _part.py + 15, false, true);
    _part.cool = 170;
    _part.hatching = false;
    lk_sparks(_part.px, _part.py - 4, C_MINT, 12, 1.55);
}

function lk_guardian_ward(_e) {
    var _panels = 0;
    for (var _i = 0; _i < array_length(_e.guardian_parts); _i++) {
        if (_e.guardian_parts[_i].alive) _panels += 1;
    }
    return _panels;
}

function lk_guardian_cleanup(_e) {
    for (var _i = 0; _i < array_length(_e.guardian_parts); _i++) {
        var _part = _e.guardian_parts[_i];
        _part.alive = false;
        if (!is_undefined(_part.sprout)) _part.sprout.alive = false;
    }
}

function lk_guardian_ability(_e) {
    if (_e.tell <= 0) return "";
    switch (_e.guardian) {
        case LK_GUARDIAN.Indexer: return _e.attack mod 2 == 0 ? "INK VOLLEY" : "INDEX BEAM";
        case LK_GUARDIAN.Sluice: return _e.attack mod 2 == 0 ? "OPEN SIDE CHANNELS" : "OPEN CENTRAL CHANNEL";
        case LK_GUARDIAN.Matron: return _e.attack mod 2 == 0 ? "BRIAR FAN" : "ROOT ERUPTION";
        case LK_GUARDIAN.Split: return _e.attack mod 2 == 0 ? "MIRROR OF SPEARS" : "MIRROR OF PRISMS";
    }
    return "";
}

function lk_guardian_step(_e, _toward, _range) {
    var _even = _e.attack mod 2 == 0;
    if (_e.guardian == LK_GUARDIAN.Matron) {
        _e.regrow -= 1;
        if (_e.regrow <= 0) {
            for (var _i = 0; _i < array_length(_e.guardian_parts); _i++) {
                var _slot = (_e.next_pod + _i) mod array_length(_e.guardian_parts);
                var _part = _e.guardian_parts[_slot];
                if (_part.alive) continue;
                _e.guardian_parts[_slot] = lk_guardian_part(_e, _part.px, _part.py);
                _e.next_pod = 1 - _slot;
                break;
            }
            _e.regrow = 240;
        }
    }
    if (_e.tell > 0) {
        if (_e.tell > 1) return;
        lk_guardian_strike(_e, _even);
        _e.attack += 1;
        _e.cool = _e.guardian == LK_GUARDIAN.Sluice ? 118 : 53;
        return;
    }
    if (_e.cool > 0) {
        if (_e.guardian == LK_GUARDIAN.Matron && _range > 81) lk_enemy_walk(_e, .76, _toward + 22);
        if (_e.guardian == LK_GUARDIAN.Split) {
            var _step = clamp((_even ? 193 : 287) - _e.px, -1.7, 1.7);
            lk_move(_e, _step, 0, _e.radius);
        }
        return;
    }
    _e.angle = lk_lead(_e, 3.8);
    _e.tell = _e.guardian == LK_GUARDIAN.Split ? 54 : 44;
    lk_ring(_e.px, _e.py, _e.color, 27, _e.tell);
    lk_charge_sound(_e);
    switch (_e.guardian) {
        case LK_GUARDIAN.Indexer:
            if (!_even) lk_guardian_aimed_lane(_e, 7, 42);
            break;
        case LK_GUARDIAN.Sluice:
            // The slowest keeper can cross out of a standard channel during its warning.
            var _standard = lk_standard_contract();
            var _duration = _standard ? 60 : 94;
            if (_even) {
                var _width = _standard ? 52 : 78;
                lk_lane(126, KEEP_TOP, 126, KEEP_BOTTOM, _width, 43, _duration, 2, C_BLUE, _e);
                lk_lane(354, KEEP_TOP, 354, KEEP_BOTTOM, _width, 43, _duration, 2, C_BLUE, _e);
            } else {
                lk_lane(240, KEEP_TOP, 240, KEEP_BOTTOM, _standard ? 44 : 59, 43, _duration, 2, C_BLUE, _e);
            }
            break;
        case LK_GUARDIAN.Matron:
            if (!_even) {
                _e.enraged = _e.hp < _e.max_hp * .53;
                if (_e.enraged) lk_ring(_e.px, _e.py, C_PINK, 48, _e.tell);
                lk_field(player.px, player.py, 1, 37, 2, 25, C_MINT, true);
                lk_field(player.px + keeper_dx * 49, player.py + keeper_dy * 49, 1, 43, 2, 20, C_MINT, true);
            }
            break;
    }
}

function lk_guardian_aimed_lane(_e, _width, _wait) {
    var _x = _e.px;
    var _y = _e.py;
    var _cos = dcos(_e.angle);
    var _sin = -dsin(_e.angle);
    var _reach_x = abs(_cos) < .001 ? 999 : ((_cos > 0 ? KEEP_RIGHT : KEEP_LEFT) - _x) / _cos;
    var _reach_y = abs(_sin) < .001 ? 999 : ((_sin > 0 ? KEEP_BOTTOM : KEEP_TOP) - _y) / _sin;
    var _reach = min(_reach_x, _reach_y);
    lk_lane(_x, _y, _x + _cos * _reach, _y + _sin * _reach, _width, _wait, 16, 2, _e.color, _e);
}

function lk_guardian_strike(_e, _even) {
    switch (_e.guardian) {
        case LK_GUARDIAN.Indexer:
            if (_even) lk_enemy_burst(_e, 5 + 2 * lk_guardian_ward(_e), _e.angle, 13, 3.1, C_GOLD);
            break;
        case LK_GUARDIAN.Sluice:
            lk_enemy_open_ring(_e, 9, _e.angle, 2.45, C_TEAL);
            break;
        case LK_GUARDIAN.Matron:
            if (_even) lk_enemy_burst(_e, 7, _e.angle, 16, 3, C_MINT, LK_SHOT.Pellet, 2);
            else if (_e.enraged) lk_enemy_open_ring(_e, 11, _e.angle + 60, 2.4, C_PINK);
            break;
        case LK_GUARDIAN.Split:
            if (_even) lk_enemy_burst(_e, 3, _e.angle, 11, 4.5, C_LILAC, LK_SHOT.Pierce);
            else lk_enemy_burst(_e, 5, _e.angle, 18, 3.35, C_LILAC, LK_SHOT.Ricochet);
            break;
    }
    lk_sound(snd_heavy, .9);
}
