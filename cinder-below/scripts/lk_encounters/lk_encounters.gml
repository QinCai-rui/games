function lk_hazard_pressure() {
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

function lk_sanctum_pattern(_e, _phase_two) {
    var _attack = _e.attack mod 3;
    var _px = player.px + move_x * 24;
    var _py = player.py + move_y * 24;
    switch (floor_no) {
        case 0:
            if (_attack == 0) {
                lk_enemy_burst(_e, 13, _e.angle, 360 / 13, 2.27, C_GOLD);
            } else if (_attack == 1) {
                lk_enemy_burst(_e, 7, _e.angle, 12, 2.71, C_PINK);
                lk_enemy_burst(_e, 3, _e.angle + 37, 15, 2.28, C_MINT, LK_SHOT.Blast);
            } else {
                var _a = _e.angle + 90;
                for (var _i = -1; _i <= 1; _i++) {
                    lk_field(_px + lengthdir_x(_i * 28, _a), _py + lengthdir_y(_i * 28, _a),
                        1, 33 + abs(_i) * 10, 2, 22, C_MINT, true);
                }
            }
            if (_phase_two) lk_enemy_burst(_e, 4, _e.angle + 45, 90, 2.80, C_MINT, LK_SHOT.Blast);
            break;
        case 1:
            if (_attack == 0) {
                lk_enemy_burst(_e, 18, _e.angle + _e.attack * 14, 20, 2.31, C_PINK);
                lk_enemy_burst(_e, _phase_two ? 7 : 3, _e.angle, 10, 3.0, C_GOLD, LK_SHOT.Blast);
            } else if (_attack == 1) {
                for (var _i = 0; _i < 4; _i++) {
                    lk_field(_px + (_i - 1.5) * 28, _py + lengthdir_y((_i - 1.5) * 14, _e.angle + 90),
                        1, 23 + _i * 10, 2, 20, C_GOLD, true);
                }
                lk_enemy_burst(_e, 5, _e.angle + 35, 16, 2.94, C_PINK);
            } else {
                lk_enemy_burst(_e, 9, _e.angle, 7, 3.45, C_PINK);
                lk_enemy_burst(_e, 9, _e.angle + 180, 14, 2.46, C_GOLD, LK_SHOT.Blast);
            }
            break;
        case 2:
            if (_attack == 0) {
                lk_enemy_burst(_e, 20, _e.angle, 18, 1.91, C_LILAC);
                lk_enemy_burst(_e, 12, _e.angle + 9, 30, 2.83, C_BLUE);
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

function lk_crown_attack(_e) {
    var _r = _e.hp / _e.max_hp;
    var _phase = _r > .69 ? 0 : (_r > .34 ? 1 : 2);
    if (_phase != _e.final_phase) {
        _e.final_phase = _phase;
        _e.attack = 0;
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
        if (_e.echo == 0) lk_enemy_burst(_e, 14, _e.angle + 26, 360 / 14, 2.61, C_LILAC);
    }
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        var _slot = _e.attack mod (3 + _phase);
        switch (_slot) {
            case 0:
                var _a = _e.angle + 90;
                for (var _i = -2; _i <= 2; _i++) {
                    var _side = _i * 23;
                    lk_field(player.px + lengthdir_x(_side, _a), player.py + lengthdir_y(_side, _a),
                        1, 25 + (_i + 2) * 9, 2, 20 + (_phase > 0) * 2, C_GOLD, true);
                }
                break;
            case 1:
                lk_enemy_burst(_e, 17, _e.angle, 360 / 17, 2.26, C_PINK);
                _e.echo = _phase > 0 ? 13 : 20;
                break;
            case 2:
                lk_enemy_burst(_e, 8, _e.angle, 11, 3.45, C_GOLD, LK_SHOT.Blast);
                lk_enemy_burst(_e, 7, _e.angle + 175, 11, 2.92, C_PINK);
                break;
            case 3:
                lk_enemy_burst(_e, 7, _e.angle + 23, 360 / 7, 2.66, C_LILAC, LK_SHOT.Ricochet);
                lk_enemy_burst(_e, 7, _e.angle, 360 / 7, 2.80, C_PINK);
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
        lk_enemy_damage(_e, ceil(7 * player.power), _a, true);
        if (_e.kind != LK_ENEMY.Boss) lk_move(_e, lengthdir_x(19, _a), lengthdir_y(19, _a), _e.radius);
    }
}
