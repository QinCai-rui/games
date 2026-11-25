function lk_is_waystation(_kind) {
    return _kind == LK_ROOM.Armory || _kind == LK_ROOM.SupplyPost || _kind == LK_ROOM.TemperRelay;
}

function lk_stage_waystation() {
    if (depth_no < 2 || !lk_standard_contract()) return -1;
    // Each run sees all three stops before any repeats, in a seed-based order.
    var _step = run_seed mod 2 == 0 ? 1 : 2;
    var _index = (run_seed + (depth_no - 2) * _step) mod 3;
    return [LK_ROOM.Armory, LK_ROOM.SupplyPost, LK_ROOM.TemperRelay][_index];
}

function lk_waystation_offer(_index) {
    var _offer = {kind: "waystation", index: _index, px: 181 + _index * 118, py: 137,
        label: "", detail: "", caption: "", tint: C_GOLD, icon: LK_LOOT.Coin, value: 10};
    if (cell.kind == LK_ROOM.Armory) {
        var _pool = array_length(weapons) - 2;
        var _offset = _index == 0 ? 0 : 1 + cell.seed mod (_pool - 1);
        var _weapon = 2 + (cell.stock - 2 + _offset) mod _pool;
        var _rank = cell.stock_temper;
        _offer.icon = LK_LOOT.Weapon;
        _offer.value = _weapon;
        _offer.tint = weapons[_weapon].color;
        _offer.caption = weapons[_weapon].name + (_rank > 0 ? " +" + string(_rank) : "");
        _offer.label = "TAKE " + _offer.caption;
        _offer.detail = lk_weapon_details(_weapon, _rank, true);
    } else if (cell.kind == LK_ROOM.SupplyPost && _index == 0) {
        _offer.icon = LK_LOOT.Energy;
        _offer.value = 35;
        _offer.tint = C_BLUE;
        _offer.caption = "+35 ENERGY";
        _offer.label = "TAKE ENERGY";
        _offer.detail = player.energy >= player.max_energy ? "ENERGY ALREADY FULL" : "RESTORE UP TO 35 ENERGY";
    } else if (cell.kind == LK_ROOM.TemperRelay && _index == 0) {
        _offer.icon = LK_LOOT.Weapon;
        _offer.value = player.arms[player.slot];
        _offer.caption = "MOVE 1 TEMPER";
        _offer.label = "MOVE 1 TEMPER";
        _offer.detail = player.temper[player.slot] >= 3 ? "ACTIVE WEAPON AT MAX TEMPER"
            : (player.temper[1 - player.slot] == 0 ? "OTHER WEAPON HAS NO TEMPER"
            : "SLOT " + string(2 - player.slot) + " TO SLOT " + string(1 + player.slot));
    } else {
        _offer.caption = "+" + string(_offer.value) + " GOLD";
        _offer.label = "TAKE " + string(_offer.value) + " GOLD";
        _offer.detail = "USE AT A SHOP OR FORGE";
    }
    return _offer;
}

function lk_claim_waystation(_index) {
    if (!lk_is_waystation(cell.kind) || cell.opened) return false;
    var _offer = lk_waystation_offer(_index);
    var _slot = player.slot;
    if (cell.kind == LK_ROOM.Armory) {
        lk_drop(LK_LOOT.Weapon, _offer.px, _offer.py + 13, player.arms[_slot], player.temper[_slot]);
        player.arms[_slot] = _offer.value;
        player.temper[_slot] = cell.stock_temper;
        lk_remember_weapon(_offer.value);
    } else if (cell.kind == LK_ROOM.TemperRelay && _index == 0) {
        var _source = 1 - _slot;
        if (player.temper[_source] == 0 || player.temper[_slot] >= 3) return false;
        player.temper[_source] -= 1;
        player.temper[_slot] += 1;
    } else if (_offer.icon == LK_LOOT.Energy) {
        if (player.energy >= player.max_energy) return false;
        player.energy = min(player.max_energy, player.energy + _offer.value);
    } else {
        player.coins += _offer.value;
    }
    cell.opened = true;
    lk_sparks(_offer.px, _offer.py - 8, _offer.tint, 22, 1.6);
    return true;
}

function lk_rupture_room() {
    return cell.kind == LK_ROOM.Fight && cell.encounter == 3;
}

function lk_rupture_vent(_side) {
    return _side == 0 ? {px: 153, py: 174} : {px: 327, py: 112};
}

function lk_room_hazard_step() {
    var _rupture = lk_rupture_room();
    if (cell.clear || (!_rupture && cell.kind != LK_ROOM.Gauntlet)) return;
    hazard_wait -= 1;
    if (hazard_wait > 0) return;
    if (_rupture) {
        var _vent = lk_rupture_vent(hazard_side);
        lk_field(_vent.px, _vent.py, 1, 36, 1, 17, lk_theme_tint(floor_no), true);
        hazard_side = 1 - hazard_side;
        hazard_wait = 160;
    } else {
        lk_gauntlet_hazards();
        hazard_wait = 190 - min(floor_no, 3) * 11 - min(run_cycle, 4) * 6;
    }
}

function lk_gauntlet_hazards() {
    var _px = player.px + move_x * 21;
    var _py = player.py + move_y * 21;
    switch (floor_no) {
        case 0:
            for (var _i = -1; _i <= 1; _i++) {
                lk_field(_px + _i * 29, _py + abs(_i) * 17, 1, 35 + abs(_i) * 9, 1, 17, C_MINT, true);
            }
            break;
        case 1:
            for (var _i = 0; _i < 3; _i++) {
                lk_field(_px + (_i - 1) * 30, _py, 1, 23 + _i * 12, 2, 18, C_PINK, true);
            }
            break;
        case 2:
            for (var _i = 0; _i < 3; _i++) {
                var _a = (cell.seed mod 360) + _i * 120;
                lk_field(_px + lengthdir_x(25, _a), _py + lengthdir_y(25, _a), 1, 43, 2, 18, C_LILAC, true);
            }
            break;
        case 3:
            var _a = point_direction(240, 143, player.px, player.py) + 90;
            for (var _i = -1; _i <= 1; _i++) {
                lk_field(_px + lengthdir_x(_i * 27, _a), _py + lengthdir_y(_i * 27, _a),
                    1, 30 + (_i + 1) * 10, 2, 19, C_BLUE, true);
            }
            break;
        case 4:
            var _angle = (world_tick * 17) mod 360;
            for (var _i = 0; _i < 4; _i++) {
                var _a = _angle + _i * 90;
                lk_field(_px + lengthdir_x(30, _a), _py + lengthdir_y(30, _a),
                    1, 27 + _i * 7, 2, 18 + (_i mod 2) * 4, C_GOLD, true);
            }
            break;
    }
}

function lk_bomb_trail(_angle, _count, _radius, _color, _windup = 32) {
    var _spacing = _radius * 2 + 12;
    var _dx = lengthdir_x(_spacing, _angle);
    var _dy = lengthdir_y(_spacing, _angle);
    var _half = (_count - 1) * .5;
    var _margin_x = 8 + abs(_dx) * _half;
    var _margin_y = 8 + abs(_dy) * _half;
    // Shift the whole trail at walls so the marked blasts don't bunch up.
    var _x = clamp(player.px, KEEP_LEFT + _margin_x, KEEP_RIGHT - _margin_x);
    var _y = clamp(player.py, KEEP_TOP + _margin_y, KEEP_BOTTOM - _margin_y);
    for (var _i = 0; _i < _count; _i++) {
        lk_field(_x + (_i - _half) * _dx, _y + (_i - _half) * _dy,
            1, _windup + _i * 12, 2, _radius, _color, true);
    }
}

function lk_sanctum_pattern(_e, _phase_two) {
    var _attack = _e.attack mod 3;
    var _px = player.px + move_x * 24;
    var _py = player.py + move_y * 24;
    switch (floor_no) {
        case 0:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 11, _e.angle, 2.13, C_GOLD);
            } else if (_attack == 1) {
                lk_enemy_burst(_e, 7, _e.angle, 12, 2.71, C_PINK);
                lk_enemy_burst(_e, 3, _e.angle + 37, 15, 2.28, C_MINT, LK_SHOT.Blast);
            } else {
                lk_bomb_trail(_e.angle + 90, 3, 18, C_MINT, lk_rootbound_standard() ? 28 : 32);
            }
            if (_phase_two && !lk_rootbound_standard()) lk_enemy_burst(_e, 4, _e.angle + 45, 90, 2.80, C_MINT, LK_SHOT.Blast);
            break;
        case 1:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 15, _e.angle + 20, 2.12, C_PINK);
            } else if (_attack == 1) {
                lk_bomb_trail(_e.angle, 4, 17, C_GOLD);
            } else {
                lk_enemy_burst(_e, 9, _e.angle, 7, 3.45, C_PINK);
                lk_enemy_burst(_e, 9, _e.angle + 180, 14, 2.46, C_GOLD, LK_SHOT.Blast);
            }
            break;
        case 2:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 15, _e.angle - 20, 1.95, C_LILAC);
            } else if (_attack == 1) {
                var _old_x = _e.px;
                var _old_y = _e.py;
                var _a = point_direction(_px, _py, _e.px, _e.py) + (_e.attack mod 2 == 0 ? 96 : -96);
                var _x = clamp(_px + lengthdir_x(91, _a), KEEP_LEFT + 24, KEEP_RIGHT - 24);
                var _y = clamp(_py + lengthdir_y(91, _a), KEEP_TOP + 23, KEEP_BOTTOM - 23);
                if (is_undefined(lk_prop_at(_x, _y, _e.radius))
                    && point_distance(_x, _y, player.px, player.py) > 48) {
                    _e.px = _x;
                    _e.py = _y;
                }
                lk_arc_fx(_old_x, _old_y, _e.px, _e.py, C_LILAC);
                lk_enemy_burst(_e, 7, lk_lead(_e, 3.6), 12, 3.52, C_BLUE);
            } else {
                lk_enemy_burst(_e, 8, _e.angle, 45, 2.11, C_LILAC, LK_SHOT.Ricochet);
                lk_field(_px, _py, 1, 31, 2, 34, C_LILAC, true);
            }
            if (_phase_two) lk_enemy_burst(_e, 5, _e.angle, 16, 3.7, C_PINK, LK_SHOT.Blast);
            break;
    }
}

function lk_boss_ability(_e) {
    if (_e.tell <= 0) return "";
    if (floor_no == 4) {
        return ["GOLDEN RUPTURE", "CINDER HALO", "ROYAL VOLLEY", "CROWN PRISM", "SOVEREIGN CHARGE"]
            [_e.attack mod (3 + _e.final_phase)];
    }
    if (floor_no == 3) {
        return ["GLASS SURGE", "FEN QUAKES", "GILDED CROSSFIRE", "SHATTER RING"][_e.attack mod 4];
    }
    var _moves = [
        ["MOSS CHARGE", "THORN FAN", "ROOT TRAP", "ROOT RING"],
        ["SEED HALO", "THORN SALVO", "ROOT ERUPTION"],
        ["RIVET MINES", "SHRAPNEL RING", "TIN VOLLEY"],
        ["FURNACE HALO", "COAL SEAMS", "BELLFIRE"],
        ["VEIL STEP", "PRISM BOUNCE", "VEIL SIGILS"],
        ["PALE HALO", "REGENT'S STEP", "HOLLOW SIGIL"]
    ];
    var _set = _moves[depth_no];
    return _set[_e.attack mod lk_boss_rotation(_e)];
}

function lk_boss_rotation(_e) {
    return depth_no == 0 && _e.enraged ? 4 : 3;
}

function lk_crown_attack(_e) {
    var _r = _e.hp / _e.max_hp;
    var _phase = _r > .69 ? 0 : (_r > .34 ? 1 : 2);
    if (_phase != _e.final_phase) {
        _e.final_phase = _phase;
        _e.attack = 0;
        _e.dash = 0;
        _e.echo = 0;
        _e.tell = 54;
        _e.cool = 41;
        _e.angle = lk_lead(_e, 3.4);
        banner = _phase == 1 ? "THE CROWN CRACKS" : "THE CROWN SHATTERS";
        banner_time = 98;
        lk_ring(_e.px, _e.py, _phase == 1 ? C_GOLD : C_PINK, 96, 37);
        lk_sound(snd_gate, _phase == 1 ? .73 : .59);
        shaking = 10;
        if (_phase == 1) lk_spawn(LK_ENEMY.Monk, 87, 191);
        if (_phase == 2) lk_spawn(LK_ENEMY.Prism, 392, 93);
        return;
    }
    if (_e.dash > 0) {
        lk_enemy_walk(_e, 4.1, _e.angle);
        _e.dash -= 1;
        if (_e.dash mod 5 == 0) {
            lk_enemy_burst(_e, 2, _e.angle + 90, 180, 2.29, C_GOLD);
            lk_sparks(_e.px, _e.py, C_PINK, 6, 1.9);
        }
        if (_e.dash == 0) lk_enemy_burst(_e, 11, _e.angle, 360 / 11, 2.63, C_PINK);
        return;
    }
    if (_e.echo > 0) {
        _e.echo -= 1;
        if ((_e.attack - 1) mod (3 + _phase) == 3) {
            // Sweep across the locked aim in five beats, including the opening pair.
            if (_e.echo mod 6 == 0) {
                var _sweep = (_e.echo / 6 - 2) * 32;
                lk_enemy_burst(_e, 2, _e.angle + _sweep, 14, 2.23, C_LILAC, LK_SHOT.Ricochet);
            }
        } else if (_e.echo == 0) {
            lk_enemy_open_ring(_e, 12, _e.angle + 22, 2.18, C_LILAC);
        }
    }
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        var _slot = _e.attack mod (3 + _phase);
        switch (_slot) {
            case 0:
                lk_bomb_trail(_e.angle + 90, _phase == 0 ? 3 : 4, 17, C_GOLD);
                break;
            case 1:
                lk_enemy_open_ring(_e, 15, _e.angle, 2.26, C_PINK);
                _e.echo = _phase > 0 ? 18 : 24;
                break;
            case 2:
                lk_enemy_burst(_e, 8, _e.angle, 11, 3.45, C_GOLD, LK_SHOT.Blast);
                lk_enemy_burst(_e, 7, _e.angle + 175, 11, 2.92, C_PINK);
                break;
            case 3:
                lk_enemy_burst(_e, 2, _e.angle + 64, 14, 2.23, C_LILAC, LK_SHOT.Ricochet);
                _e.echo = 24;
                break;
            case 4:
                _e.dash = 26;
                lk_sound(snd_dash, .67);
                break;
        }
        _e.attack += 1;
        _e.cool = 54 - _phase * 8;
        lk_sound(snd_heavy, .79 + .07 * _phase);
        shaking = max(shaking, 5);
        return;
    }
    if (_e.cool <= 0) {
        _e.angle = lk_lead(_e, 4.1);
        _e.tell = 34 - _phase * 4;
        lk_charge_sound(_e);
        lk_ring(_e.px, _e.py, C_PINK, 30, _e.tell);
    } else {
        var _toward = point_direction(_e.px, _e.py, player.px, player.py);
        if (point_distance(_e.px, _e.py, player.px, player.py) > 52) {
            lk_enemy_walk(_e, .95 + _phase * .17, _toward + dsin(world_tick * 4) * 29);
        }
    }
}

function lk_tide_step() {
    if (player.tide <= 0) return;
    var _front = (43 - player.tide) * 1.9;
    player.tide -= 1;
    for (var _i = 0; _i < array_length(shots); _i++) {
        var _b = shots[_i];
        if (!_b.friendly && point_distance(player.px, player.py, _b.px, _b.py) < _front + 5) _b.life = 1;
    }
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (_e.tided || !_e.alive || _e.emerge > 9
            || point_distance(player.px, player.py, _e.px, _e.py) > _front + _e.radius) continue;
        _e.tided = true;
        _e.slow = max(_e.slow, 106);
        var _a = point_direction(player.px, player.py, _e.px, _e.py);
        lk_enemy_damage(_e, ceil(7 * player.damage_scale), _a, true);
        if (_e.kind != LK_ENEMY.Boss) lk_move(_e, lengthdir_x(19, _a), lengthdir_y(19, _a), _e.radius);
    }
}
