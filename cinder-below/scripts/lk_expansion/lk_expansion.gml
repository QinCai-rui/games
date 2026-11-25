function lk_field(_x, _y, _kind, _wait, _power, _radius, _color, _hostile = false, _angle = 0) {
    var _duration = [142, 22, 185, 6][_kind];
    if (_hostile && _kind == 1) _wait += 18;
    array_push(fields, {px: clamp(_x, KEEP_LEFT + 8, KEEP_RIGHT - 8), py: clamp(_y, KEEP_TOP + 8, KEEP_BOTTOM - 8),
        kind: _kind, life: _duration + _wait, duration: _duration, radius: _radius,
        power: _power, color: _color, hostile: _hostile, shot_angle: _angle, windup: _wait});
}

function lk_field_step(_field) {
    _field.life -= 1;
    if (_field.life < 0) return false;
    var _age = _field.duration - _field.life;
    if (_age < 0) return true;
    if (_field.kind == 2) {
        if (_age mod 28 == 0) lk_beacon_tick(_field);
        return true;
    }
    if (_field.kind == 3) {
        if (_age == 0) {
            lk_shot(true, _field.px, _field.py, _field.shot_angle, 7.7, _field.power, _field.color, LK_SHOT.Echo);
            lk_sound(snd_fire, 1.37);
        }
        return true;
    }
    if (_age == 0) {
        lk_ring(_field.px, _field.py, _field.color, _field.radius + 6, 21);
        lk_sparks(_field.px, _field.py - 6, _field.color, 16, 2);
        lk_sound(_field.hostile ? snd_heavy : snd_zap, _field.kind == 0 ? .84 : 1);
        if (_field.kind == 1) shaking = max(shaking, 4);
    }
    if (_age mod 27 != 0) return true;
    if (_field.hostile) {
        if (point_distance(player.px, player.py, _field.px, _field.py) < _field.radius + 3) lk_player_hurt(_field.power);
        return true;
    }
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _enemy = enemies[_i];
        if (point_distance(_enemy.px, _enemy.py, _field.px, _field.py) >= _field.radius + _enemy.radius) continue;
        if (_field.kind == 0) _enemy.slow = max(_enemy.slow, 38);
        var _direction = point_direction(_field.px, _field.py, _enemy.px, _enemy.py);
        lk_enemy_damage(_enemy, _field.power, _direction, true);
    }
    return true;
}

function lk_field_draw(_field, _xx, _yy) {
    var _x = round(_field.px + _xx);
    var _y = round(_field.py + _yy);
    var _age = _field.duration - _field.life;
    var _r = _field.radius;
    var _edge = _field.hostile ? _r + 3 : _r;
    var _height = _field.hostile ? _edge : _r * .64;
    var _color = _field.color;
    var _warning = _age < 0;
    if (_field.kind == 2) {
        lk_diamond(_x, _y - 6, 5, _color);
        lk_line(_x - 5, _y, _x, _y - 5, C_PAPER);
        lk_line(_x, _y - 5, _x + 5, _y, C_PAPER);
        if (_age > 0) lk_glow(_x, _y - 7, 15, _color, .36);
        return;
    }
    if (_field.kind == 3) {
        lk_diamond(_x, _y - 6, _warning ? 2 : 4, C_LILAC);
        return;
    }
    if (_warning && _field.hostile && _field.kind == 1) {
        var _progress = 1 + _age / _field.windup;
        var _fill = _edge * _progress;
        draw_set_color(_color);
        draw_set_alpha(.10 + _progress * .19);
        draw_circle(_x, _y, _edge, false);
        draw_set_alpha(.45 + _progress * .40);
        if (_fill > 1) draw_circle(_x, _y, _fill, true);
        draw_set_color(merge_color(_color, C_PAPER, .38));
        draw_circle(_x, _y, _edge, true);
        lk_line(_x - 4, _y, _x + 4, _y, C_PAPER);
        lk_line(_x, _y - 4, _x, _y + 4, C_PAPER);
        draw_set_alpha(1);
        return;
    }
    if (_warning) {
        draw_set_alpha(.34 + abs(dsin(world_tick * 11)) * .34);
        draw_set_color(_color);
        draw_ellipse(_x - _edge, _y - _height, _x + _edge, _y + _height, true);
        lk_diamond(_x, _y, 3, _color);
        draw_set_alpha(1);
        return;
    }
    var _opacity = min(1, _field.life / 20);
    gpu_set_blendmode(bm_add);
    lk_light(_x, _y - 1, _r * 1.6, _color, (_field.kind == 0 ? .36 : .7) * _opacity, .69);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(.53 * _opacity);
    draw_set_color(_color);
    draw_ellipse(_x - _edge, _y - _height, _x + _edge, _y + _height, true);
    if (_field.kind == 0) {
        for (var _i = 0; _i < 9; _i++) {
            var _rad = (_i * 13 mod _r) * .85;
            var _a = world_tick * (2 + (_i mod 3)) + _i * 89;
            var _bx = _x + lengthdir_x(_rad, _a);
            var _by = _y + lengthdir_y(_rad * .6, _a);
            lk_rect(_bx, _by, _bx + 1, _by + 1, _i mod 3 == 0 ? C_PAPER : _color);
        }
    } else {
        var _size = min(_r, max(2, 11 - _age));
        lk_diamond(_x, _y - max(0, 9 - _age), _size, C_PAPER);
        lk_line(_x + 4, _y - 12, _x + 17, _y - 44, _color);
    }
    draw_set_alpha(1);
}

function lk_guard_shot(_b) {
    if (player.guard <= 0 || mode != LK_MODE.Play) return false;
    if (point_distance(_b.px, _b.py, player.px, player.py) >= 22 + _b.radius) return false;
    var _toward = point_direction(player.px, player.py, _b.px, _b.py);
    if (abs(angle_difference(_toward, player.aim)) > 85) return false;
    _b.friendly = true;
    _b.color = C_BLUE;
    _b.damage = 3;
    _b.speed = max(4.8, _b.speed * 1.3);
    _b.angle = _toward;
    _b.life = 60;
    lk_sparks(_b.px, _b.py - 6, C_BLUE, 5, 1.5);
    if (world_tick mod 3 == 0) lk_sound(snd_shield, 1.25);
    return true;
}

function lk_arc_fx(_x, _y, _to_x, _to_y, _color) {
    array_push(particles, {px: _x, py: _y - 6, tx: _to_x, ty: _to_y - 6, dx: 0, dy: 0,
        life: 11, max_life: 11, color: _color, size: 0, kind: 4, angle: irandom(360)});
}

function lk_arc_draw(_effect, _xx, _yy) {
    var _px = _effect.px + _xx;
    var _py = _effect.py + _yy;
    var _angle = point_direction(_effect.px, _effect.py, _effect.tx, _effect.ty);
    for (var _i = 1; _i <= 5; _i++) {
        var _t = _i / 5;
        var _bend = _i < 5 ? dsin(_effect.angle + _i * 109) * 5 : 0;
        var _x = lerp(_effect.px, _effect.tx, _t) + lengthdir_x(_bend, _angle + 90) + _xx;
        var _y = lerp(_effect.py, _effect.ty, _t) + lengthdir_y(_bend, _angle + 90) + _yy;
        draw_set_color(_effect.color);
        draw_line_width(_px, _py, _x, _y, 3);
        lk_line(_px, _py, _x, _y, C_PAPER);
        _px = _x;
        _py = _y;
    }
}

function lk_chain(_angle, _power) {
    var _xx = player.px;
    var _yy = player.py;
    var _marked = [];
    for (var _order = 0; _order < 4; _order++) {
        var _best = _order == 0 ? 118 : 66;
        var _target = undefined;
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _enemy = enemies[_i];
            if (!_enemy.alive || _enemy.emerge > 9 || array_contains(_marked, _enemy)) continue;
            var _gap = point_distance(_xx, _yy, _enemy.px, _enemy.py);
            if (_gap >= _best || !lk_line_clear(_xx, _yy, _enemy.px, _enemy.py)) continue;
            if (_order == 0 && abs(angle_difference(point_direction(_xx, _yy, _enemy.px, _enemy.py), _angle)) > 47) continue;
            _best = _gap;
            _target = _enemy;
        }
        if (is_undefined(_target)) {
            if (_order == 0) lk_arc_fx(_xx, _yy, _xx + lengthdir_x(47, _angle), _yy + lengthdir_y(47, _angle), C_BLUE);
            break;
        }
        array_push(_marked, _target);
        lk_arc_fx(_xx, _yy, _target.px, _target.py, C_BLUE);
        lk_enemy_damage(_target, max(2, _power - _order * 2), point_direction(_xx, _yy, _target.px, _target.py), true);
        _xx = _target.px;
        _yy = _target.py;
    }
    lk_sound(snd_zap, random_range(.92, 1.05));
}

function lk_disc_turn(_b) {
    if (_b.returning) return;
    _b.returning = true;
    _b.hit_list = [];
    _b.speed = max(5, _b.speed + .45);
}

function lk_lead(_enemy, _speed) {
    var _time = min(31, point_distance(_enemy.px, _enemy.py, player.px, player.py) / _speed);
    return point_direction(_enemy.px, _enemy.py, player.px + move_x * player.move_pace * _time * .50,
        player.py + move_y * player.move_pace * _time * .50);
}

function lk_champion_step(_e, _toward, _range) {
    var _enraged = _e.enraged;
    if (_e.dash > 0) {
        lk_enemy_walk(_e, 3.25 + floor_no * .26, _e.angle);
        _e.dash -= 1;
        if (_e.dash mod 3 == 0) lk_sparks(_e.px, _e.py - 4, _e.color, 3, 1.35);
        if (_e.dash == 0) {
            lk_enemy_burst(_e, 8 + floor_no * 2, _e.angle, 360 / (8 + floor_no * 2), 2.46, C_PINK);
            lk_ring(_e.px, _e.py, _e.color, 39, 20);
            shaking = max(shaking, 6);
            lk_sound(snd_blast, .84);
        }
        return;
    }
    if (_e.echo > 0) {
        _e.echo -= 1;
        if (_e.echo == 0) {
            lk_enemy_burst(_e, 3, _e.angle + 24, 11, 2.95, C_PINK);
            lk_sound(snd_heavy, .92);
        }
    }
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        var _move = _e.attack mod lk_boss_rotation(_e);
        switch (floor_no) {
            case 0:
                if (_move == 0) {
                    _e.dash = 20;
                    lk_sound(snd_dash, .72);
                } else if (_move == 1) {
                    lk_enemy_burst(_e, 7, _e.angle, 15, 2.61, C_PINK);
                    if (_enraged) lk_enemy_burst(_e, 7, _e.angle + 180, 13, 2.26, C_MINT);
                } else if (_move == 2) {
                    lk_bomb_trail(_e.angle, 3, 18, C_TEAL);
                } else {
                    // Leave gaps between the marked eruptions so players can step through.
                    for (var _i = 0; _i < 6; _i++) {
                        var _a = _e.angle + _i * 60;
                        lk_field(_e.px + lengthdir_x(50, _a), _e.py + lengthdir_y(50, _a),
                            1, 36, 2, 15, C_MINT, true);
                    }
                }
                break;
            case 1:
                if (_move == 0) {
                    lk_bomb_trail(_e.angle + 90, 4, 17, C_GOLD);
                } else if (_move == 1) {
                    lk_enemy_open_ring(_e, 12, _e.angle, 2.28, C_PINK, LK_SHOT.Blast);
                    lk_sound(snd_mortar);
                } else {
                    lk_enemy_burst(_e, 3, _e.angle - 24, 11, 2.95, C_GOLD);
                    _e.echo = _enraged ? 13 : 18;
                }
                break;
            case 2:
                if (_move == 0) {
                    var _old_x = _e.px;
                    var _old_y = _e.py;
                    var _a = point_direction(_e.px, _e.py, player.px, player.py);
                    var _x = clamp(player.px + lengthdir_x(78, _a), KEEP_LEFT + 24, KEEP_RIGHT - 24);
                    var _y = clamp(player.py + lengthdir_y(78, _a), KEEP_TOP + 23, KEEP_BOTTOM - 23);
                    if (is_undefined(lk_prop_at(_x, _y, _e.radius)) && point_distance(_x, _y, player.px, player.py) > 46) {
                        _e.px = _x;
                        _e.py = _y;
                    }
                    lk_arc_fx(_old_x, _old_y, _e.px, _e.py, C_LILAC);
                    lk_ring(_e.px, _e.py, C_LILAC, 29, 18);
                    lk_enemy_burst(_e, 5, lk_lead(_e, 3.7), 12, 3.65, C_LILAC);
                    lk_sound(snd_zap, .78);
                } else if (_move == 1) {
                    lk_enemy_burst(_e, 9, _e.angle + 18, 40, 2.42, C_LILAC, LK_SHOT.Ricochet);
                } else {
                    for (var _i = 0; _i < 4; _i++) {
                        var _a = _e.attack * 20 + _i * 90;
                        lk_field(player.px + lengthdir_x(31, _a), player.py + lengthdir_y(31, _a),
                            1, 31 + _i * 5, 2, _enraged ? 27 : 22, C_LILAC, true);
                    }
                }
                break;
        }
        _e.attack += 1;
        _e.cool = _enraged ? 40 : 54;
        return;
    }
    if (_e.cool <= 0) {
        // Lock the phase before the tell so the move can't change during its windup.
        _e.enraged = _e.hp <= _e.max_hp * .51;
        _e.angle = lk_lead(_e, 3.1);
        _e.tell = _e.enraged ? 22 : 29;
        lk_charge_sound(_e);
        lk_ring(_e.px, _e.py, _e.color, 25, _e.tell);
    } else if (_range > 45) {
        lk_enemy_walk(_e, 1.05 + floor_no * .16, _toward + dsin(world_tick * 4) * 21);
    }
}
