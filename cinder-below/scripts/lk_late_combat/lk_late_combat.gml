function lk_late_guardian(_e, _toward, _range) {
    var _depth = floor_no - 3;
    if (_e.hp <= _e.max_hp * .48 && !_e.enraged) {
        _e.enraged = true;
        banner = "GUARDIAN ENRAGED";
        banner_time = 90;
        shaking = max(shaking, 10);
        lk_sound(snd_gate, .68);
        lk_ring(_e.px, _e.py, _e.color, 84, 36);
        for (var _i = -1; _i <= 1; _i += 2) {
            lk_spawn(_depth == 0 ? LK_ENEMY.Prism : LK_ENEMY.Monk, 240 + _i * 132, 189);
        }
    }
    if (_e.dash > 0) {
        lk_enemy_walk(_e, 3.75 + _depth * .35, _e.angle);
        _e.dash -= 1;
        if (_e.dash mod 6 == 0) {
            lk_enemy_burst(_e, 2, _e.angle, 175, 2.48, _e.color);
            lk_sparks(_e.px, _e.py - 9, _e.color, 5, 2);
        }
        if (_e.dash == 0) {
            lk_field(_e.px, _e.py, 1, 24, 2, 29, C_PINK, true);
            lk_ring(_e.px, _e.py, _e.color, 30, 15);
        }
        return;
    }
    if (_e.echo > 0) {
        _e.echo -= 1;
        if (_e.echo == 0) {
            var _angle = _e.angle + _e.attack * 27;
            lk_enemy_open_ring(_e, 14, _angle, 2.26 + .21 * _depth, C_LILAC);
            lk_sound(snd_heavy, .92);
        }
    }
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        var _attack = _e.attack mod 4;
        if (_attack == 0 && _depth == 0) {
            _e.dash = 26;
            lk_sound(snd_dash, .79);
        } else if (_attack == 1 || _attack == 0 && _depth == 1) {
            var _direction = point_direction(_e.px, _e.py, player.px, player.py);
            lk_bomb_trail(_direction + 90, 4, 17, C_PINK);
        } else if (_attack == 2) {
            lk_enemy_burst(_e, 11, _e.angle, 12, 3.01 + .20 * _depth, C_PINK);
            lk_enemy_burst(_e, 5, _e.angle + 180, 45, 2.37, _e.color);
        } else {
            lk_enemy_open_ring(_e, 16, _e.angle, 2.08, _e.color);
            _e.echo = _e.enraged ? 15 : 24;
        }
        _e.attack += 1;
        _e.cool = _e.enraged ? 37 : 55;
        shaking = max(shaking, 5);
        lk_sound(snd_heavy, .75 + _depth * .09);
        return;
    }
    if (_e.cool <= 0) {
        _e.angle = lk_lead(_e, 3.4);
        _e.tell = _e.enraged ? 22 : 33;
        lk_charge_sound(_e);
        lk_ring(_e.px, _e.py, _e.color, 30, _e.tell);
    } else if (_range > 47) {
        lk_enemy_walk(_e, .89 + .13 * _depth + (_e.enraged ? .27 : 0), _toward + dsin(world_tick * 3) * 36);
    }
}

function lk_orbit_step(_b) {
    _b.age += 1;
    if (_b.age >= 110) return false;
    var _radius = 11 + min(27, _b.age * .68);
    var _theta = _b.angle + _b.age * 8;
    _b.px = player.px + lengthdir_x(_radius, _theta);
    _b.py = player.py + lengthdir_y(_radius, _theta);
    if (_b.age mod 22 == 0) _b.hit_list = [];
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (!_e.alive || _e.emerge > 9 || array_contains(_b.hit_list, _e)) continue;
        if (point_distance(_b.px, _b.py, _e.px, _e.py) >= _e.radius + _b.radius) continue;
        array_push(_b.hit_list, _e);
        lk_enemy_damage(_e, _b.damage, _theta, true);
    }
    return true;
}

function lk_beacon_tick(_field) {
    var _target = undefined;
    var _limit = _field.radius;
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (!_e.alive || _e.emerge > 9) continue;
        var _d = point_distance(_e.px, _e.py, _field.px, _field.py);
        if (_d >= _limit || !lk_line_clear(_field.px, _field.py, _e.px, _e.py)) continue;
        _target = _e;
        _limit = _d;
    }
    if (is_undefined(_target)) return;
    var _theta = point_direction(_field.px, _field.py, _target.px, _target.py);
    lk_shot(true, _field.px, _field.py, _theta, 6.8, _field.power, _field.color);
    lk_sound(snd_fire, 1.24);
}
