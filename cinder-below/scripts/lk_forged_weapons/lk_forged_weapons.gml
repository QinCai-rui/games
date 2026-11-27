enum LK_ARM {
    Nail = 24, Bell, Thread, Hook, Shale, Seep, Choir, Kite, Split, Ember, Fang, Silt,
    Lens, Briar, Winter, Spark, Ash, Crown
}

enum LK_FORGED_FIELD { Ring = 5, Seep, Burst, Silt }

function lk_forged_charge_limit(_id) {
    if (_id == LK_ARM.Nail) return 38;
    if (_id == LK_ARM.Ember) return 31;
    return 0;
}

function lk_forged_fire_step() {
    var _id = lk_active_weapon();
    var _limit = lk_forged_charge_limit(_id);
    var _charge = variable_struct_exists(player, "forged_charge") ? player.forged_charge : 0;
    if (_charge > 0 && (player.forged_slot != player.slot || player.forged_arm != _id)) {
        _charge = 0;
        player.forged_charge = 0;
    }
    if (_limit == 0) {
        if (fire_held && player.fire_wait == 0) lk_fire();
        return;
    }
    if (player.fire_wait > 0) return;
    var _explicit = explicit_fire_held || (_charge > 0 && player.forged_explicit);
    if (_explicit ? explicit_fire_held : fire_held) {
        player.forged_arm = _id;
        player.forged_slot = player.slot;
        player.forged_aim = player.aim;
        player.forged_explicit = _explicit;
        player.forged_charge = min(_limit, _charge + 1);
    } else if (_charge > 0) {
        player.aim = player.forged_aim;
        lk_fire();
        player.forged_charge = 0;
    }
}

function lk_forged_aim_line(_angle, _reach, _width, _power, _color) {
    var _x = player.px;
    var _y = player.py;
    var _end_x = _x;
    var _end_y = _y;
    for (var _d = 4; _d <= _reach; _d += 4) {
        var _next_x = _x + lengthdir_x(_d, _angle);
        var _next_y = _y + lengthdir_y(_d, _angle);
        if (!lk_keep_bounds(_next_x, _next_y, 0, false) || !is_undefined(lk_prop_at(_next_x, _next_y, 1))) break;
        _end_x = _next_x;
        _end_y = _next_y;
    }
    var _dx = _end_x - _x;
    var _dy = _end_y - _y;
    var _length_sq = _dx * _dx + _dy * _dy;
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (!_e.alive || _e.emerge > 9) continue;
        var _t = ((_e.px - _x) * _dx + (_e.py - _y) * _dy) / max(1, _length_sq);
        if (_t < 0 || _t > 1) continue;
        if (point_distance(_x + _t * _dx, _y + _t * _dy, _e.px, _e.py) > _width + _e.radius) continue;
        lk_enemy_damage(_e, _power, _angle, true);
    }
    lk_arc_fx(_x, _y, _end_x, _end_y, _color);
}

function lk_forged_special_fire(_id, _direction, _power, _charge, _w) {
    switch (_id) {
        case LK_ARM.Bell:
            lk_field(player.px, player.py, LK_FORGED_FIELD.Ring, 0, _power, 62, _w.color);
            lk_sound(snd_wick, .7);
            return true;
        case LK_ARM.Thread:
            lk_forged_aim_line(_direction, 135, 2, _power, _w.color);
            lk_sound(snd_zap, 1.36);
            return true;
        case LK_ARM.Ember:
            lk_forged_aim_line(_direction, lerp(38, 94, _charge), lerp(2, 9, _charge),
                ceil(_power * lerp(.55, 1.9, _charge)), _w.color);
            lk_sound(snd_heavy, lerp(1.3, .76, _charge));
            return true;
    }
    return false;
}

function lk_forged_turn(_b) {
    if (_b.returning) return;
    if (_b.kind == LK_SHOT.Winter) {
        var _to_keeper = point_direction(_b.px, _b.py, player.px, player.py);
        lk_shot(true, _b.px, _b.py, _to_keeper + 180, 10.5, ceil(_b.damage * .85), C_BLUE, LK_SHOT.Pierce);
        lk_sparks(_b.px, _b.py, C_BLUE, 6, 1.5);
    }
    lk_disc_turn(_b);
}

function lk_forged_terrain(_b, _normal) {
    if (!_b.friendly || (_b.kind != LK_SHOT.Split && _b.kind != LK_SHOT.Lens)) return false;
    var _reflected = 2 * (_normal + 90) - _b.angle;
    var _x = _b.px + lengthdir_x(3, _normal);
    var _y = _b.py + lengthdir_y(3, _normal);
    if (_b.kind == LK_SHOT.Split) {
        for (var _i = -1; _i <= 1; _i++) {
            lk_shot(true, _x, _y, _reflected + _i * 24, 7.1, ceil(_b.damage * .65), _b.color, LK_SHOT.Buckshot);
        }
    } else {
        lk_shot(true, _x, _y, _reflected, 9.2, ceil(_b.damage * .75), _b.color, LK_SHOT.Pellet);
    }
    lk_sparks(_x, _y, _b.color, 9, 1.6);
    lk_sound(snd_ricochet);
    return true;
}

function lk_forged_seep(_x, _y, _power, _color) {
    for (var _i = 0; _i < array_length(fields); _i++) {
        var _f = fields[_i];
        if (_f.kind != LK_FORGED_FIELD.Seep || point_distance(_f.px, _f.py, _x, _y) > 30) continue;
        var _old_source = variable_struct_exists(_f, "armory") ? _f.armory : undefined;
        if (!lk_armory_same_weapon(_old_source, armory_source)) continue;
        _f.stacks = min(3, _f.stacks + 1);
        _f.power = max(_f.power, _power);
        _f.radius = 23 + (_f.stacks - 1) * 5;
        // Extend the timer without restarting its damage cadence.
        _f.life = max(_f.life, 132);
        return;
    }
    lk_field(_x, _y, LK_FORGED_FIELD.Seep, 0, _power, 23, _color);
}

function lk_forged_field_step(_f, _age) {
    if (_f.kind == LK_FORGED_FIELD.Burst) {
        if (_age == 0) {
            var _ash = _f.radius == 3;
            var _count = _ash ? 5 : _f.radius;
            for (var _i = 0; _i < _count; _i++) {
                var _angle = _f.shot_angle + (_i - (_count - 1) * .5) * (_ash ? 8 : 6);
                lk_shot(true, _f.px, _f.py, _angle, _ash ? 6.4 : 6.9, _f.power, _f.color,
                    _ash ? LK_SHOT.Buckshot : LK_SHOT.Pellet);
            }
            lk_sparks(_f.px, _f.py - 5, _f.color, 5, 1.4);
            lk_sound(snd_fire, _ash ? .81 : (1.3 - _count * .15));
        }
        return true;
    }
    var _ring = _f.kind == LK_FORGED_FIELD.Ring;
    var _seep = _f.kind == LK_FORGED_FIELD.Seep;
    if (_seep) _f.tick += 1;
    if (_seep && _f.tick mod 25 != 1) return true;
    if (_ring) _f.radius = min(_f.reach, 7 + _age * 4);
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (!_e.alive || _e.emerge > 9 || point_distance(_f.px, _f.py, _e.px, _e.py) > _f.radius + _e.radius) continue;
        if (_ring) {
            if (array_contains(_f.hit_list, _e) || !lk_line_clear(_f.px, _f.py, _e.px, _e.py)) continue;
            array_push(_f.hit_list, _e);
        } else {
            lk_slow_enemy(_e, _seep ? 32 : 12);
        }
        if (_f.power > 0) {
            var _power = _seep ? ceil(_f.power * (1 + (_f.stacks - 1) * .5)) : _f.power;
            lk_enemy_damage(_e, _power, point_direction(_f.px, _f.py, _e.px, _e.py), true);
        }
    }
    return true;
}

function lk_forged_beacon_tick(_f) {
    if (_f.weapon_id == LK_ARM.Kite) {
        var _angle = _f.shot_angle + ((_f.duration - _f.life) div _f.cadence) * 36;
        lk_shot(true, _f.px, _f.py, _angle, 7, _f.power, _f.color);
        lk_shot(true, _f.px, _f.py, _angle + 180, 7, _f.power, _f.color);
        lk_sparks(_f.px, _f.py - 3, _f.color, 3, 1);
        lk_sound(snd_fire, 1.32);
        return true;
    }
    if (_f.weapon_id != LK_ARM.Spark) return false;
    var _x = _f.px;
    var _y = _f.py;
    var _hit = [];
    for (var _hop = 0; _hop < 3; _hop++) {
        var _range = _hop == 0 ? _f.radius : 41;
        var _target = undefined;
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _e = enemies[_i];
            if (!_e.alive || _e.emerge > 9 || array_contains(_hit, _e)) continue;
            var _distance = point_distance(_x, _y, _e.px, _e.py);
            if (_distance >= _range || !lk_line_clear(_x, _y, _e.px, _e.py)) continue;
            _range = _distance;
            _target = _e;
        }
        if (is_undefined(_target)) break;
        array_push(_hit, _target);
        lk_arc_fx(_x, _y, _target.px, _target.py, _f.color);
        lk_enemy_damage(_target, max(1, _f.power - _hop), point_direction(_x, _y, _target.px, _target.py), true);
        _x = _target.px;
        _y = _target.py;
    }
    if (array_length(_hit) > 0) lk_sound(snd_zap, 1.13);
    return true;
}

function lk_forged_field_draw(_f, _x, _y, _age) {
    var _color = _f.color;
    switch (_f.kind) {
        case 2:
            if (_f.weapon_id != LK_ARM.Kite && _f.weapon_id != LK_ARM.Spark) return false;
            var _a = _f.shot_angle + (max(0, _age) div _f.cadence) * 36;
            lk_shadow(_x, _y, 6);
            lk_glow(_x, _y - 5, 12, _color, .45);
            lk_weapon_draw(_f.weapon_id, _x, _y - 4, _a, .64);
            return true;
        case LK_FORGED_FIELD.Ring:
            var _r = _f.radius;
            draw_set_color(_color);
            draw_set_alpha(.2 + .76 * (_f.life / _f.duration));
            draw_circle(_x, _y, _r, true);
            draw_set_color(C_PAPER);
            draw_set_alpha(.35);
            draw_circle(_x, _y, max(1, _r - 3), true);
            draw_set_alpha(1);
            return true;
        case LK_FORGED_FIELD.Burst:
            lk_diamond(_x, _y - 5, 2 + (_age >= -4), _color);
            return true;
        case LK_FORGED_FIELD.Seep:
        case LK_FORGED_FIELD.Silt:
            var _r = _f.radius;
            draw_set_color(_color);
            draw_set_alpha(min(.22 + _f.stacks * .04, _f.life / 55));
            draw_ellipse(_x - _r, _y - _r * .62, _x + _r, _y + _r * .62, false);
            draw_set_alpha(min(.67, _f.life / 34));
            draw_ellipse(_x - _r, _y - _r * .62, _x + _r, _y + _r * .62, true);
            for (var _i = 0; _i < 2 + _f.stacks; _i++) {
                var _a = world_tick * 3 + _i * 120;
                lk_diamond(_x + lengthdir_x(_r * .7, _a), _y + lengthdir_y(_r * .35, _a), 1, C_PAPER);
            }
            draw_set_alpha(1);
            return true;
    }
    return false;
}
