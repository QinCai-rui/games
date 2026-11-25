enum LK_SHOT { Pellet, Blade, Pierce, Blast, Ricochet, Buckshot, Chain, Disc, Vial, Star, Mortar, Echo, Orbit, Beacon, Wraith }

#macro LK_ARMOR_FIRST_REPAIR 180
#macro LK_ARMOR_FOLLOWUP 300

function lk_weapons() {
    return [
        {name: "EMBER PISTOL", damage: 3, delay: 15, cost: 0, speed: 6.0, count: 1, spread: 0, color: C_GOLD, kind: 0},
        {name: "KEEPER BLADE", damage: 5, delay: 21, cost: 0, speed: 0, count: 1, spread: 0, color: C_TEAL, kind: 1},
        {name: "THORN CARBINE", damage: 3, delay: 8, cost: 1, speed: 7.2, count: 1, spread: 0, color: C_MINT, kind: 0},
        {name: "HEX LANTERN", damage: 6, delay: 17, cost: 2, speed: 4.6, count: 1, spread: 0, color: C_LILAC, kind: 2},
        {name: "CINDER BUCKSHOT", damage: 3, delay: 24, cost: 3, speed: 5.4, count: 5, spread: 11, color: C_GOLD, kind: 0},
        {name: "FROST RAIL", damage: 12, delay: 27, cost: 4, speed: 12, count: 1, spread: 0, color: C_BLUE, kind: 2},
        {name: "FIRE MOTH", damage: 8, delay: 24, cost: 4, speed: 3.4, count: 1, spread: 0, color: C_PINK, kind: 3},
        {name: "BRAMBLE SCYTHE", damage: 9, delay: 21, cost: 0, speed: 0, count: 1, spread: 0, color: C_MINT, kind: 1},
        {name: "THUNDER FORK", damage: 4, delay: 15, cost: 3, speed: 6.6, count: 3, spread: 9, color: C_LILAC, kind: 2},
        {name: "PRISM REPEATER", damage: 4, delay: 11, cost: 1, speed: 7.5, count: 1, spread: 0, color: C_TEAL, kind: LK_SHOT.Ricochet},
        {name: "SALT CANNON", damage: 4, delay: 29, cost: 4, speed: 6.7, count: 7, spread: 8, color: C_PAPER, kind: LK_SHOT.Buckshot},
        {name: "STORM ARC", damage: 9, delay: 22, cost: 3, speed: 0, count: 1, spread: 0, color: C_BLUE, kind: LK_SHOT.Chain},
        {name: "MOON DISC", damage: 5, delay: 35, cost: 2, speed: 5.9, count: 1, spread: 0, color: C_LILAC, kind: LK_SHOT.Disc},
        {name: "SAWTOOTH", damage: 7, delay: 31, cost: 0, speed: 0, count: 1, spread: 0, color: C_GOLD, kind: LK_SHOT.Blade},
        {name: "VENOM FLASK", damage: 3, delay: 25, cost: 2, speed: 4.2, count: 1, spread: 0, color: C_MINT, kind: LK_SHOT.Vial},
        {name: "STARSHARD", damage: 7, delay: 19, cost: 3, speed: 9.2, count: 1, spread: 0, color: C_GOLD, kind: LK_SHOT.Star},
        {name: "ASHEN MORTAR", damage: 12, delay: 34, cost: 4, speed: 4.65, count: 1, spread: 0, color: C_PINK, kind: LK_SHOT.Mortar},
        {name: "GLASS NEEDLE", damage: 3, delay: 9, cost: 1, speed: 10.1, count: 2, spread: 3, color: C_TEAL, kind: LK_SHOT.Pierce},
        {name: "ECHO RIFLE", damage: 6, delay: 23, cost: 3, speed: 7.7, count: 1, spread: 0, color: C_LILAC, kind: LK_SHOT.Echo},
        {name: "FLOODGATE", damage: 4, delay: 23, cost: 3, speed: 6.25, count: 3, spread: 22, color: C_BLUE, kind: LK_SHOT.Ricochet},
        {name: "CROWN CHISEL", damage: 12, delay: 39, cost: 1, speed: 0, count: 1, spread: 0, color: C_GOLD, kind: LK_SHOT.Blade},
        {name: "WICK SPIRE", damage: 5, delay: 34, cost: 2, speed: 0, count: 1, spread: 0, color: C_GOLD, kind: LK_SHOT.Orbit},
        {name: "ASH BEACON", damage: 5, delay: 67, cost: 5, speed: 0, count: 1, spread: 0, color: C_PINK, kind: LK_SHOT.Beacon},
        {name: "WRAITH LANCE", damage: 8, delay: 23, cost: 3, speed: 10.8, count: 1, spread: 0, color: C_LILAC, kind: LK_SHOT.Wraith}
    ];
}

function lk_sparks(_x, _y, _color, _count, _force) {
    repeat (_count) {
        var _angle = random(360);
        var _speed = random_range(.25, _force);
        var _life = irandom_range(10, 26);
        array_push(particles, {px: _x, py: _y, dx: lengthdir_x(_speed, _angle),
            dy: lengthdir_y(_speed, _angle), life: _life, max_life: _life, color: _color,
            size: irandom_range(1, 3), kind: 0, angle: 0});
    }
}

function lk_floater(_x, _y, _text, _color, _life = 42) {
    array_push(floaters, {px: _x, py: _y, label: _text, color: _color, life: _life});
}

function lk_ring(_x, _y, _color, _radius, _life, _kind = 1, _angle = 0) {
    array_push(particles, {px: _x, py: _y, dx: 0, dy: 0, life: _life,
        max_life: _life, color: _color, size: _radius, kind: _kind, angle: _angle});
}

function lk_update_effects() {
    for (var _i = array_length(particles) - 1; _i >= 0; _i--) {
        var _p = particles[_i];
        _p.life -= 1;
        if (_p.life <= 0) { array_delete(particles, _i, 1); continue; }
        _p.px += _p.dx;
        _p.py += _p.dy;
        _p.dx *= .90;
        _p.dy *= .90;
    }
    for (var _i = array_length(floaters) - 1; _i >= 0; _i--) {
        floaters[_i].life -= 1;
        floaters[_i].py -= .31;
        if (floaters[_i].life <= 0) array_delete(floaters, _i, 1);
    }
}

function lk_later_fight() {
    return cell.kind == LK_ROOM.Fight && (depth_no > 0 || cell_index > 1);
}

function lk_spawn(_kind, _x = -1, _y = -1, _elite = false) {
    var _boss_hp = depth_no mod 2 == 0 ? 148 + depth_no * 35 : 184 + depth_no * 61;
    if (floor_no >= 3) _boss_hp = 380 + (floor_no - 3) * 109;
    var _boss_scale = lk_rootbound_standard() ? 1.2 : 1.6;
    var _hp = [9, 11, 17, 10, ceil(_boss_hp * _boss_scale), 13, 10, 23, 15, 13, 21];
    var _r = [7, 8, 9, 7, 16, 8, 7, 10, 8, 8, 9];
    var _colors = [C_MINT, C_GOLD, C_PINK, C_BLUE, lk_theme_tint(floor_no), C_GOLD,
        C_LILAC, C_PINK, C_TEAL, C_BLUE, C_GOLD];
    if (_x == -1) {
        repeat (50) {
            _x = irandom_range(75, 405);
            _y = irandom_range(81, 203);
            var _free = is_undefined(lk_prop_at(_x, _y, _r[_kind]))
                && point_distance(_x, _y, player.px, player.py) > 59;
            for (var _i = 0; _i < array_length(enemies); _i++) {
                if (point_distance(_x, _y, enemies[_i].px, enemies[_i].py) < 27) _free = false;
            }
            if (_free) break;
        }
    }
    var _health = _hp[_kind] + (_kind == LK_ENEMY.Boss ? 0 : depth_no * 2);
    var _scale = 1 + min(run_cycle, 7) * .12 + (run_contract == LK_CONTRACT.Iron ? .13 : 0);
    _health = ceil(_health * _scale * (_elite ? 2.25 : 1));
    var _tint = _elite ? C_GOLD : _colors[_kind];
    var _cool = irandom_range(30, 77);
    if (cell.kind == LK_ROOM.Duel) _cool = ceil(_cool / 4);
    else if (lk_later_fight()) _cool -= 12;
    array_push(enemies, {px: _x, py: _y, kind: _kind, hp: _health, max_hp: _health,
        radius: _r[_kind] + (_elite ? 2 : 0), color: _tint, emerge: 24, cool: _cool,
        tell: 0, angle: 0, facing: -1, hit: 0, dash: 0, alive: true, dash_hit: false,
        slow: 0, attack: 0, echo: 0, enraged: false, phase: irandom(160), elite: _elite, final_phase: 0, tided: false});
    lk_ring(_x, _y, _tint, _elite ? 27 : 18, 24);
}

function lk_spawn_wave() {
    wave += 1;
    wave_wait = -1;
    if (cell.kind == LK_ROOM.Boss) {
        lk_spawn(LK_ENEMY.Boss, 240, 107);
        lk_sound(snd_gate, .82);
        shaking = 6;
        return;
    }
    if (cell.kind == LK_ROOM.Duel) {
        var _rival = [LK_ENEMY.Charger, LK_ENEMY.Bruiser, LK_ENEMY.Leech, LK_ENEMY.Harpoon, LK_ENEMY.Monk];
        lk_spawn(_rival[floor_no], -1, -1, true);
        lk_sound(snd_gate, .93);
        return;
    }
    var _count = 4 + min(floor_no, 3) + min(wave - 1, 1) + irandom(1) + min(run_cycle, 2);
    var _pools = [
        [LK_ENEMY.Skulk, LK_ENEMY.Skulk, LK_ENEMY.Spitter, LK_ENEMY.Charger, LK_ENEMY.Sentry],
        [LK_ENEMY.Charger, LK_ENEMY.Spitter, LK_ENEMY.Bruiser, LK_ENEMY.Sentry, LK_ENEMY.Wisp],
        [LK_ENEMY.Wisp, LK_ENEMY.Leech, LK_ENEMY.Leech, LK_ENEMY.Bruiser, LK_ENEMY.Sentry],
        [LK_ENEMY.Harpoon, LK_ENEMY.Prism, LK_ENEMY.Harpoon, LK_ENEMY.Wisp, LK_ENEMY.Sentry],
        [LK_ENEMY.Monk, LK_ENEMY.Prism, LK_ENEMY.Monk, LK_ENEMY.Bruiser, LK_ENEMY.Harpoon]
    ];
    var _pool = _pools[floor_no];
    var _style = cell.encounter;
    if (_style == 2) {
        var _type = [LK_ENEMY.Charger, LK_ENEMY.Bruiser, LK_ENEMY.Leech, LK_ENEMY.Harpoon, LK_ENEMY.Monk][floor_no];
        lk_spawn(_type, 176, 120, true);
        lk_spawn(_type, 304, 167, true);
        _count = 2 + min(floor_no, 2);
    } else if (_style == 4) {
        _count += 2;
    }

    // Keep the first fight simple. Later fights use different mixes for each encounter.
    var _later = lk_later_fight();
    var _front = [LK_ENEMY.Skulk, LK_ENEMY.Charger, LK_ENEMY.Leech, LK_ENEMY.Prism, LK_ENEMY.Bruiser];
    var _back = [LK_ENEMY.Spitter, LK_ENEMY.Sentry, LK_ENEMY.Wisp, LK_ENEMY.Harpoon, LK_ENEMY.Monk];
    for (var _i = 0; _i < _count; _i++) {
        var _kind = _pool[irandom(array_length(_pool) - 1)];
        var _elite = _i < min(run_cycle, 2);
        var _px = -1;
        var _py = -1;
        if (_later && _style == 1 && _i == _count - 1) {
            // One roaming enemy can flush the keeper out of cover between the two firing lines.
            _kind = _front[floor_no];
        } else if (_style == 1) {
            var _left = [LK_ENEMY.Spitter, LK_ENEMY.Sentry, LK_ENEMY.Wisp, LK_ENEMY.Harpoon, LK_ENEMY.Monk];
            var _right = [LK_ENEMY.Sentry, LK_ENEMY.Spitter, LK_ENEMY.Sentry, LK_ENEMY.Prism, LK_ENEMY.Harpoon];
            _kind = _i mod 2 == 0 ? _left[floor_no] : _right[floor_no];
            _px = (_i mod 2 == 0) ? 85 : 395;
            _py = 80 + (floor(_i / 2) mod 5) * 28;
            if (point_distance(player.px, player.py, _px, _py) < 52 || !is_undefined(lk_prop_at(_px, _py, 11))) _px = -1;
        } else if (_style == 4) {
            var _rushers = [LK_ENEMY.Skulk, LK_ENEMY.Charger, LK_ENEMY.Leech, LK_ENEMY.Prism, LK_ENEMY.Bruiser];
            _kind = _rushers[floor_no];
        } else if (depth_no == 0 && cell_index == 1 && _i < 2) {
            _kind = LK_ENEMY.Skulk;
        } else if (_later && (_style == 0 || _style == 3) && _i < 2) {
            _kind = _i == 0 ? _front[floor_no] : _back[floor_no];
        } else if (_later && _style == 2 && _i == 0) {
            _kind = floor_no < 3 ? _back[floor_no] : _front[floor_no];
        }
        lk_spawn(_kind, _px, _py, _elite);
    }
    if (wave > 1) {
        banner = "WAVE " + string(wave) + " / " + string(wave_count);
        banner_time = 68;
    }
    lk_sound(snd_gate, 1.12);
}

function lk_finish_wave() {
    if (cell.clear || array_length(enemies) > 0 || wave_wait >= 0) return;
    if (wave < wave_count) {
        wave_wait = 50;
        return;
    }
    cell.clear = true;
    rooms_cleared += 1;
    player.coins += 2 * lk_boon_rank(LK_BOON.Salvager);
    player.energy = min(player.max_energy, player.energy + 11 + lk_relic_rank(LK_RELIC.Canteen) * 6);
    player.armor = min(player.max_armor, player.armor + lk_relic_rank(LK_RELIC.Gateward));
    var _medic = lk_boon_rank(LK_BOON.Medic);
    if (_medic > 0 && rooms_cleared mod (5 - _medic) == 0) player.hp = min(player.max_hp, player.hp + 1);
    player.regen = min(player.regen, 86);
    for (var _i = array_length(shots) - 1; _i >= 0; _i--) {
        var _b = shots[_i];
        if (!_b.friendly) {
            lk_sparks(_b.px, _b.py, _b.color, 2, .9);
            array_delete(shots, _i, 1);
        }
    }
    for (var _i = array_length(fields) - 1; _i >= 0; _i--) {
        if (fields[_i].hostile) array_delete(fields, _i, 1);
    }
    if (cell.kind == LK_ROOM.Boss) {
        banner = "GUARDIAN FELLED";
        lk_drop(LK_LOOT.Heart, 221, 137, 2);
        lk_drop(LK_LOOT.Energy, 259, 137, 35);
        lk_ring(240, 112, C_MINT, 50, 35);
    } else if (cell.kind == LK_ROOM.Duel) {
        banner = "DUEL WON";
        lk_drop(LK_LOOT.Weapon, 240, 151, irandom_range(7, array_length(weapons) - 1));
    } else if (cell.kind == LK_ROOM.Gauntlet) {
        banner = "GAUNTLET CLEARED";
        lk_drop(LK_LOOT.Weapon, 240, 151, irandom_range(7, array_length(weapons) - 1));
        lk_drop(LK_LOOT.Heart, 220, 147, 2);
        lk_drop(LK_LOOT.Energy, 260, 147, 25);
    } else {
        banner = "ROOM CLEAR";
        if (irandom(5) == 0 || (player.hp <= 2 && irandom(1) == 0)) lk_drop(LK_LOOT.Heart, 240, 145, 2);
        if (cell.encounter == 2 || irandom(5) == 0) {
            lk_drop(LK_LOOT.Weapon, 240, 152, irandom_range(1, array_length(weapons) - 1));
        }
    }
    banner_time = 94;
    lk_contract_loot();
    lk_gate_release();
    lk_sound(snd_clear);
    lk_save_checkpoint();
}

function lk_line_clear(_x, _y, _to_x, _to_y, _clearance = 1.25) {
    var _dx = _to_x - _x;
    var _dy = _to_y - _y;
    var _length_squared = _dx * _dx + _dy * _dy;
    if (_length_squared <= .001) return true;
    for (var _i = 0; _i < array_length(cell.props); _i++) {
        var _prop = cell.props[_i];
        if (!_prop.alive) continue;
        var _along = ((_prop.px - _x) * _dx + (_prop.py - _y) * _dy) / _length_squared;
        var _t = clamp(_along, 0, 1);
        var _offset_x = _x + _t * _dx - _prop.px;
        var _offset_y = _y + _t * _dy - _prop.py;
        var _radius = _prop.radius + _clearance;
        if (_offset_x * _offset_x + _offset_y * _offset_y < _radius * _radius) return false;
    }
    return true;
}

function lk_aim() {
    player.target = undefined;
    if (point_distance(0, 0, aim_x, aim_y) > .28) return point_direction(0, 0, aim_x, aim_y);
    if (pointer_fire) return point_direction(player.px, player.py - 7, pointer_x, pointer_y);
    var _best = 999;
    var _angle = player.aim;
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (!_e.alive) continue;
        var _distance = point_distance(player.px, player.py, _e.px, _e.py);
        if (!lk_line_clear(player.px, player.py, _e.px, _e.py)) _distance += 220;
        if (_distance < _best) {
            _best = _distance;
            player.target = _e;
            _angle = point_direction(player.px, player.py, _e.px, _e.py);
        }
    }
    if (_best == 999 && (move_x != 0 || move_y != 0)) _angle = point_direction(0, 0, move_x, move_y);
    return _angle;
}

function lk_shot(_friendly, _x, _y, _angle, _speed, _power, _color, _kind = 0) {
    var _radius = _kind == LK_SHOT.Blast || _kind == LK_SHOT.Disc || _kind == LK_SHOT.Mortar ? 5 : (_friendly ? 2 : 3);
    var _life = _friendly ? 88 : 186;
    if (_kind == LK_SHOT.Buckshot) _life = 16;
    if (_kind == LK_SHOT.Vial) _life = 27;
    if (_kind == LK_SHOT.Mortar) _life = 22;
    var _pierce = 0;
    if (_friendly) {
        if (_kind == LK_SHOT.Star || _kind == LK_SHOT.Wraith) _pierce = 4;
        if (_kind == LK_SHOT.Pierce) _pierce = 1;
    }
    var _bounces = _kind == LK_SHOT.Ricochet ? 2 : 0;
    if (_friendly && (_kind == LK_SHOT.Pellet || _kind == LK_SHOT.Pierce || _kind == LK_SHOT.Star || _kind == LK_SHOT.Echo)) {
        _bounces = lk_relic_rank(LK_RELIC.Mirror);
    }
    array_push(shots, {px: _x, py: _y, angle: _angle, speed: _speed, damage: _power, friendly: _friendly,
        color: _color, kind: _kind, radius: _radius, life: _life, pierce: _pierce, bounces: _bounces,
        age: 0, returning: false, hit_list: []});
}

function lk_enemy_damage(_enemy, _power, _angle, _quiet = false) {
    if (!_enemy.alive || _enemy.emerge > 9) return;
    if (_enemy.kind == LK_ENEMY.Boss) {
        var _rank = lk_relic_rank(LK_RELIC.Crown);
        if (_rank > 0) _power = ceil(_power * (_rank == 1 ? 1.25 : 1.40));
    }
    _enemy.hp -= _power;
    _enemy.hit = 7;
    if (_enemy.kind != LK_ENEMY.Boss) {
        lk_move(_enemy, lengthdir_x(2.3, _angle), lengthdir_y(2.3, _angle), _enemy.radius);
    }
    lk_sparks(_enemy.px, _enemy.py - 6, _enemy.color, 4, 1.5);
    lk_floater(_enemy.px, _enemy.py - _enemy.radius - 8, string(_power), C_PAPER);
    if (!_quiet) lk_sound(snd_hit, random_range(.87, 1.18));
    if (_enemy.hp > 0) return;
    _enemy.alive = false;
    kills += 1;
    lk_relic_on_kill(_enemy.px, _enemy.py);
    if (player.fury > 0 && kills mod 3 == 0) player.hp = min(player.max_hp, player.hp + 1);
    var _collapse = _enemy.kind == LK_ENEMY.Boss ? 33 : 18;
    array_push(particles, {px: _enemy.px, py: _enemy.py, dx: 0, dy: 0, life: _collapse,
        max_life: _collapse, color: _enemy.color, size: 0, kind: 5, angle: _enemy.facing, foe: _enemy.kind});
    hit_stop = max(hit_stop, _enemy.kind == LK_ENEMY.Boss ? 7 : 2);
    lk_sound(snd_kill, _enemy.kind == LK_ENEMY.Boss ? .72 : random_range(.93, 1.16));
    lk_ring(_enemy.px, _enemy.py, _enemy.color, _enemy.kind == LK_ENEMY.Boss ? 64 : 15, 20);
    shaking = max(shaking, _enemy.kind == LK_ENEMY.Boss ? 12 : 3);
    lk_sparks(_enemy.px, _enemy.py - 5, _enemy.color, _enemy.kind == LK_ENEMY.Boss ? 58 : 14, 2.7);
    var _gold = _enemy.kind == LK_ENEMY.Boss ? 14 + lk_relic_rank(LK_RELIC.Due) * 6 : (_enemy.elite ? 5 : irandom_range(1, 2));
    lk_drop(LK_LOOT.Coin, _enemy.px, _enemy.py, _gold);
    if (irandom(3) == 0) lk_drop(LK_LOOT.Energy, _enemy.px + 8, _enemy.py - 4, 9);
}

function lk_break_prop(_prop, _power) {
    if (_prop.hp < 0) return;
    _prop.hp -= max(1, floor(_power / 4));
    if (_prop.hp > 0) return;
    _prop.alive = false;
    lk_sparks(_prop.px, _prop.py - 6, _prop.kind == 2 ? C_BLUE : C_GOLD, 10, 2);
    if (irandom(2) == 0) lk_drop(LK_LOOT.Coin, _prop.px, _prop.py, 1);
}

function lk_weapon_cost(_id) {
    var _cost = weapons[_id].cost;
    return _cost == 0 ? 0 : max(1, _cost - lk_boon_rank(LK_BOON.Focus));
}

function lk_active_weapon() {
    var _id = player.arms[player.slot];
    // A keeper can always finish a locked room, even with two empty weapons.
    return !player.charged_shot && lk_weapon_cost(_id) > player.energy ? 0 : _id;
}

function lk_fire() {
    var _id = lk_active_weapon();
    var _w = weapons[_id];
    if (!player.charged_shot) player.energy -= lk_weapon_cost(_id);
    player.charged_shot = false;
    player.fire_wait = max(4, round(_w.delay / player.haste));
    player.kick = 6;
    var _direction = player.aim;
    var _tier = _id == player.arms[player.slot] ? player.temper[player.slot] : 0;
    var _light = lk_relic_rank(LK_RELIC.LowLight);
    var _desperate = _light > 0 && player.hp <= 1 + _light;
    var _power = ceil(_w.damage * player.damage_scale * (1 + _tier * .2)
        * (_desperate ? 1.40 : 1) * (player.fury > 0 ? 1.35 : 1));
    var _xx = player.px + lengthdir_x(10, _direction);
    var _yy = player.py + lengthdir_y(10, _direction);
    if (_w.kind == LK_SHOT.Chain) {
        lk_chain(_direction, _power + (player.skill_time > 0 ? 4 : 0));
        return;
    }
    if (_w.kind == LK_SHOT.Beacon) {
        lk_field(player.px + lengthdir_x(19, _direction), player.py + lengthdir_y(19, _direction),
            2, 10, _power, 120, _w.color);
        if (player.skill_time > 0) lk_field(player.px + lengthdir_x(26, _direction + 42),
            player.py + lengthdir_y(26, _direction + 42), 2, 16, _power, 120, C_TEAL);
        lk_sound(snd_wick);
        return;
    }
    if (_w.kind == LK_SHOT.Blade) {
        var _circle = _id == 13;
        var _range = _id == 20 ? 54 : (_id == 7 || _circle ? 40 : 33);
        if (_id == 20) lk_shot(true, player.px, player.py, _direction, 4.7, ceil(_power * .40), C_GOLD, LK_SHOT.Buckshot);
        lk_ring(player.px, player.py - 5, _w.color, _range, 12, _circle ? 1 : 2, _direction);
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _enemy = enemies[_i];
            var _angle = point_direction(player.px, player.py, _enemy.px, _enemy.py);
            if (point_distance(player.px, player.py, _enemy.px, _enemy.py) < _range + _enemy.radius
                && (_circle || abs(angle_difference(_angle, _direction)) < 82)) {
                lk_enemy_damage(_enemy, _power * (player.skill_time > 0 ? 2 : 1), _direction, true);
            }
        }
        var _cut = false;
        for (var _i = array_length(shots) - 1; _i >= 0; _i--) {
            var _b = shots[_i];
            if (!_b.friendly && point_distance(player.px, player.py, _b.px, _b.py) < _range
                && (_circle || abs(angle_difference(point_direction(player.px, player.py, _b.px, _b.py), _direction)) < 82)) {
                lk_sparks(_b.px, _b.py, C_MINT, 2, 1);
                array_delete(shots, _i, 1);
                _cut = true;
            }
        }
        if (_cut && player.traits[1]) player.energy = min(player.max_energy, player.energy + 3);
        for (var _i = 0; _i < array_length(cell.props); _i++) {
            var _p = cell.props[_i];
            if (_p.alive && point_distance(player.px, player.py, _p.px, _p.py) < _range
                && (_circle || abs(angle_difference(point_direction(player.px, player.py, _p.px, _p.py), _direction)) < 82)) {
                lk_break_prop(_p, _power);
            }
        }
        lk_sound(snd_blade, random_range(.92, 1.11));
        return;
    }
    for (var _i = 0; _i < _w.count; _i++) {
        var _angle = _direction + (_i - (_w.count - 1) * .5) * _w.spread;
        lk_shot(true, player.px, player.py, _angle, _w.speed, _power, _w.color, _w.kind);
    }
    if (player.skill_time > 0) lk_shot(true, player.px, player.py, _direction + random_range(-6, 6), _w.speed * .95, _power, C_TEAL, _w.kind);
    if (_w.speed > 0) {
        player.fire_number += 1;
        if (player.traits[2] && player.fire_number mod 6 == 0) {
            for (var _i = -1; _i <= 1; _i += 2) {
                lk_shot(true, player.px, player.py, _direction + _i * 15, 6.85, max(2, ceil(_power * .61)), C_LILAC);
            }
        }
    }
    if (_w.kind == LK_SHOT.Echo) {
        lk_field(player.px, player.py, 3, 7, _power, 16, C_LILAC, false, _direction + 6);
        lk_field(player.px, player.py, 3, 12, _power, 16, C_LILAC, false, _direction - 6);
    }
    lk_sparks(_xx, _yy - 5, _w.color, _w.count > 1 ? 7 : 3, 1.4);
    var _heavy = _w.count > 3 || _w.kind == 3 || _w.damage >= 10;
    if (_heavy) shaking = max(shaking, 2);
    lk_sound(lk_sfx_for_weapon(_id, _heavy), random_range(.90, 1.11));
}

function lk_skill_cooldown() {
    var _wick = 1 - .12 * lk_boon_rank(LK_BOON.StillWick);
    return max(1, round(heroes[hero_id].recharge * _wick / player.haste));
}

function lk_use_skill() {
    if (player.skill_wait > 0) return;
    player.skill_wait = lk_skill_cooldown();
    player.skill_anim = 19;
    if (player.traits[0]) player.charged_shot = true;
    if (hero_id == 0) {
        player.skill_time = 240;
        lk_ring(player.px, player.py, C_TEAL, 31, 26);
    } else if (hero_id == 1) {
        var _a = player.aim;
        if (move_x != 0 || move_y != 0) _a = point_direction(0, 0, move_x, move_y);
        lk_sound(snd_dash);
        player.dash_time = 12;
        player.dash_x = lengthdir_x(5.0, _a);
        player.dash_y = lengthdir_y(5.0, _a);
        for (var _i = 0; _i < array_length(enemies); _i++) enemies[_i].dash_hit = false;
    } else if (hero_id == 2) {
        for (var _i = array_length(shots) - 1; _i >= 0; _i--) {
            var _b = shots[_i];
            if (!_b.friendly && point_distance(player.px, player.py, _b.px, _b.py) <= 86) {
                lk_sparks(_b.px, _b.py, C_LILAC, 3, 1.6);
                array_delete(shots, _i, 1);
            }
        }
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _e = enemies[_i];
            if (point_distance(player.px, player.py, _e.px, _e.py) <= 86) {
                _e.slow = 150;
                lk_enemy_damage(_e, ceil(10 * player.damage_scale), point_direction(player.px, player.py, _e.px, _e.py), true);
            }
        }
        lk_ring(player.px, player.py, C_LILAC, 86, 26);
        lk_ring(player.px, player.py, C_BLUE, 72, 23);
        shaking = 6;
    } else if (hero_id == 3) {
        var _power = ceil(4 * player.damage_scale);
        for (var _i = -1; _i <= 1; _i += 2) {
            var _aim = player.aim + _i * 21;
            lk_field(player.px + lengthdir_x(64, _aim), player.py + lengthdir_y(64, _aim),
                0, 18, _power, 30, C_MINT);
        }
    } else if (hero_id == 4) {
        player.guard = 174;
        player.armor = min(player.max_armor, player.armor + 1);
        lk_ring(player.px, player.py - 3, C_BLUE, 28, 25);
    } else if (hero_id == 5) {
        var _marks = 0;
        for (var _i = 0; _i < array_length(enemies) && _marks < 5; _i++) {
            var _enemy = enemies[_i];
            if (!_enemy.alive || point_distance(player.px, player.py, _enemy.px, _enemy.py) > 132) continue;
            lk_field(_enemy.px, _enemy.py, 1, 16 + _marks * 8, ceil(15 * player.damage_scale), 26, C_GOLD);
            _marks += 1;
        }
        if (_marks == 0) lk_field(player.px + lengthdir_x(52, player.aim),
            player.py + lengthdir_y(52, player.aim), 1, 16, ceil(15 * player.damage_scale), 26, C_GOLD);
    } else if (hero_id == 6) {
        player.tide = 43;
        for (var _i = 0; _i < array_length(enemies); _i++) enemies[_i].tided = false;
        lk_ring(player.px, player.py, C_BLUE, 73, 37);
    } else {
        player.hp = max(1, player.hp - 1);
        player.fury = 188;
        lk_ring(player.px, player.py, C_PINK, 45, 30);
        shaking = max(shaking, 6);
    }
    lk_sparks(player.px, player.py - 7, heroes[hero_id].tint, 17, 2.0);
    if (hero_id != 1) lk_sound([snd_skill, snd_dash, snd_skill, snd_poison, snd_aegis, snd_starfall, snd_aegis, snd_wick][hero_id]);
}

function lk_combat_armor_enabled() {
    return lk_standard_contract();
}

function lk_rootbound_standard() {
    return depth_no == 1 && lk_standard_contract();
}

function lk_armor_timer(_frames) {
    player.regen = _frames;
    armor_repair_span = _frames;
}

function lk_armor_step() {
    if (player.armor >= player.max_armor || (!cell.clear && !lk_combat_armor_enabled())) return;
    player.regen = max(0, player.regen - 1);
    if (player.regen > 0) return;
    player.armor += 1;
    if (player.armor < player.max_armor) lk_armor_timer(cell.clear ? 53 : LK_ARMOR_FOLLOWUP);
    if (!cell.clear) {
        lk_ring(player.px, player.py - 4, C_TEAL, 16, 18);
        lk_sound(snd_armor);
    }
}

function lk_player_hurt(_power) {
    if (player.hurt > 0 || player.dash_time > 0 || mode != LK_MODE.Play) return false;
    var _shielded = player.armor > 0;
    if (_shielded) {
        var _absorbed = min(player.armor, _power);
        player.armor -= _absorbed;
        _power -= _absorbed;
        lk_ring(player.px, player.py - 4, C_TEAL, 16, 18);
        if (player.armor == 0) {
            var _shell = lk_relic_rank(LK_RELIC.Breaker);
            if (_shell > 0) lk_nova(_shell == 1 ? 72 : 104);
        }
    }
    player.hp = max(0, player.hp - _power);
    lk_armor_timer(lk_combat_armor_enabled() ? LK_ARMOR_FIRST_REPAIR : 150);
    player.hurt = 40;
    flash_screen = 9;
    shaking = 7;
    lk_sparks(player.px, player.py - 8, C_PINK, 12, 2.0);
    lk_sound(_shielded ? snd_shield : snd_hurt, _shielded && player.armor == 0 ? .83 : 1);
    if (player.hp == 0) {
        if (lk_relic_rank(LK_RELIC.Knot) > 0 && !player.knot_spent) {
            player.knot_spent = true;
            player.hp = min(player.max_hp, 3);
            player.hurt = 240;
            banner = "SOUL KNOT / REVIVED";
            banner_time = 115;
            lk_floater(player.px, player.py - 19, "REVIVED", C_GOLD, 94);
            lk_nova();
            lk_sound(snd_revive);
        } else {
            mode = LK_MODE.Dead;
            total_kills += kills;
            lk_save();
            lk_discard_checkpoint();
        }
    }
    return true;
}

function lk_enemy_walk(_e, _distance, _angle) {
    if (_e.slow > 0) _distance *= .53;
    if (run_contract == LK_CONTRACT.Iron) _distance *= 1.13;
    if (_e.elite) _distance *= (cell.kind == LK_ROOM.Duel && _e.dash == 0) ? 1.22 : 1.09;
    if (_e.dash == 0 && lk_later_fight()) {
        var _pursuit = _e.kind == LK_ENEMY.Skulk || _e.kind == LK_ENEMY.Charger
            || _e.kind == LK_ENEMY.Leech || _e.kind == LK_ENEMY.Bruiser;
        _distance *= _pursuit ? 1.22 : 1.12;
    }
    // Try a short diagonal when the direct line runs into a pillar.
    var _x = _e.px;
    var _y = _e.py;
    lk_move(_e, lengthdir_x(_distance, _angle), lengthdir_y(_distance, _angle), _e.radius);
    if (point_distance(_x, _y, _e.px, _e.py) < _distance * .22) {
        var _side = (_e.phase mod 2 == 0) ? 78 : -78;
        _angle += _side;
        lk_move(_e, lengthdir_x(_distance, _angle), lengthdir_y(_distance, _angle), _e.radius);
        if (point_distance(_x, _y, _e.px, _e.py) < _distance * .22) _e.phase += 1;
    }
}

function lk_enemy_shot_speed(_speed, _kind = LK_SHOT.Pellet) {
    // Keep slow patterns moving. Take more speed off fast shots than slow ones.
    var _readable = min(_speed, 2.2) + max(0, _speed - 2.2) * .55;
    return _kind == LK_SHOT.Blast ? _readable * .85 : _readable;
}

function lk_enemy_burst(_e, _count, _angle, _gap, _speed, _color, _kind = LK_SHOT.Pellet) {
    var _pace = lk_enemy_shot_speed(_speed, _kind);
    for (var _i = 0; _i < _count; _i++) {
        var _a = _angle + (_i - (_count - 1) * .5) * _gap;
        lk_shot(false, _e.px + lengthdir_x(_e.radius, _a), _e.py + lengthdir_y(_e.radius, _a),
            _a, _pace, 1, _color, _kind);
    }
}

function lk_enemy_open_ring(_e, _count, _opening, _speed, _color, _kind = LK_SHOT.Pellet) {
    // Two empty slots leave a lane through the ring.
    lk_enemy_burst(_e, _count, _opening + 180, 360 / (_count + 2), _speed, _color, _kind);
}

function lk_charge_sound(_enemy) {
    if (world_tick - charge_sound_at < 17) return;
    charge_sound_at = world_tick;
    lk_sound(snd_charge, _enemy.kind == LK_ENEMY.Boss ? .77 : random_range(.95, 1.19));
}

function lk_boss_step(_e, _toward, _range) {
    if (floor_no == 4) {
        lk_crown_attack(_e);
        return;
    }
    if (floor_no == 3) {
        lk_late_guardian(_e, _toward, _range);
        return;
    }
    if (depth_no mod 2 == 0) {
        lk_champion_step(_e, _toward, _range);
        return;
    }
    var _phase_two = _e.hp < _e.max_hp * .53;
    var _rootbound_standard = lk_rootbound_standard();
    if (_phase_two && !_e.enraged) {
        _e.enraged = true;
        lk_ring(_e.px, _e.py, C_PINK, 80, 38);
        lk_sparks(_e.px, _e.py - 10, _e.color, 40, 2.65);
        lk_sound(snd_gate, .64);
        shaking = max(shaking, 10);
        var _guard = [LK_ENEMY.Skulk, LK_ENEMY.Sentry, LK_ENEMY.Leech][floor_no];
        lk_spawn(_guard, 88, 192);
        if (!_rootbound_standard) lk_spawn(_guard, 392, 191);
        banner = "GUARDIAN ENRAGED";
        banner_time = 72;
    }
    if (_e.echo > 0) {
        _e.echo -= 1;
        if (_e.echo == 0) {
            lk_enemy_open_ring(_e, 7 + floor_no * 3, _e.angle + 28, 2.16, C_PINK);
            lk_sound(snd_heavy, .87);
        }
    }
    if (_e.tell > 0) {
        if (_e.tell > 1) return;
        lk_sanctum_pattern(_e, _phase_two);
        _e.attack += 1;
        if (_phase_two && (!lk_standard_contract() || (_e.attack - 1) mod 3 == 0)) _e.echo = 21;
        _e.cool = (_phase_two ? 36 : 53) - floor_no * 4;
        if (_rootbound_standard) _e.cool = _phase_two ? 42 : 47;
        shaking = max(shaking, 3);
        lk_sound(snd_heavy, .72 + floor_no * .1);
        return;
    }
    if (_e.cool <= 0) {
        _e.tell = _phase_two ? (_rootbound_standard ? 32 : 25) : 36;
        lk_charge_sound(_e);
        _e.angle = lk_lead(_e, 3.0);
        lk_ring(_e.px, _e.py, _e.color, 26, _e.tell);
    } else if (_range > 47) {
        lk_enemy_walk(_e, _phase_two ? .95 : .68, _toward + dsin(world_tick * 2) * 43);
    }
}

function lk_enemy_step(_e) {
    _e.hit = max(0, _e.hit - 1);
    _e.slow = max(0, _e.slow - 1);
    if (_e.emerge > 0) { _e.emerge -= 1; return; }
    var _range = point_distance(_e.px, _e.py, player.px, player.py);
    var _toward = point_direction(_e.px, _e.py, player.px, player.py);
    var _later = lk_later_fight();
    _e.facing = player.px >= _e.px ? 1 : -1;
    // Standard contracts leave more time to counterattack between boss moves.
    var _cool_rate = _e.kind == LK_ENEMY.Boss && !lk_standard_contract() ? 1.25 : 1;
    // A solo rival takes less downtime without shortening the tell or dash.
    if (cell.kind == LK_ROOM.Duel) _cool_rate = 1.55;
    _e.cool -= _cool_rate * (run_contract == LK_CONTRACT.Iron ? 1.17 : 1);
    if (_e.kind == LK_ENEMY.Sentry && _e.echo > 0) {
        _e.echo -= 1;
        if (_e.echo mod 8 == 0) {
            lk_enemy_burst(_e, 1, _e.angle, 0, 3.35 + depth_no * .12, C_PINK);
            lk_sound(snd_fire, 1.52);
            lk_sparks(_e.px, _e.py - 6, C_PINK, 3, 1.0);
        }
    }
    if (_e.kind == LK_ENEMY.Boss) {
        lk_boss_step(_e, _toward, _range);
    } else if (_e.dash > 0) {
        lk_enemy_walk(_e, _e.kind == LK_ENEMY.Leech ? 3.65 : (_e.kind == LK_ENEMY.Skulk ? 2.65 : 3.1), _e.angle);
        _e.dash -= 1;
    } else if (_e.tell > 0) {
        if (_e.tell == 1) {
            switch (_e.kind) {
                case LK_ENEMY.Spitter:
                    lk_enemy_burst(_e, floor_no == 0 ? 3 : 5, _e.angle, 14, 2.47 + floor_no * .23, C_PINK);
                    _e.cool = irandom_range(62, 88);
                    break;
                case LK_ENEMY.Charger:
                    _e.dash = 22;
                    _e.cool = 76;
                    break;
                case LK_ENEMY.Skulk:
                case LK_ENEMY.Leech:
                    _e.dash = _e.kind == LK_ENEMY.Leech ? 19 : 10;
                    _e.cool = _e.kind == LK_ENEMY.Leech ? 58 : 64;
                    break;
                case LK_ENEMY.Sentry:
                    _e.echo = 17;
                    _e.cool = 72 + irandom(14);
                    break;
                case LK_ENEMY.Bruiser:
                    lk_enemy_burst(_e, 3, _e.angle, 21, 2.31, C_GOLD, LK_SHOT.Blast);
                    lk_field(player.px + move_x * 14, player.py + move_y * 14, 1, 30, 2, 20, C_PINK, true);
                    _e.cool = 66 + irandom(13);
                    break;
                case LK_ENEMY.Harpoon:
                    lk_enemy_burst(_e, 1, _e.angle, 0, 5.9, C_PINK, LK_SHOT.Pierce);
                    lk_sound(snd_harpoon);
                    _e.cool = 84;
                    break;
                case LK_ENEMY.Prism:
                    lk_enemy_burst(_e, 5, _e.angle, 31, 2.72, C_LILAC, LK_SHOT.Ricochet);
                    _e.cool = 76;
                    break;
                case LK_ENEMY.Monk:
                    var _side = _e.angle + (_e.attack mod 2 == 0 ? 65 : -65);
                    lk_field(player.px, player.py, 1, 37, 2, 20, C_GOLD, true);
                    lk_field(player.px + lengthdir_x(38, _side), player.py + lengthdir_y(38, _side),
                        1, 53, 2, 18, C_GOLD, true);
                    _e.attack += 1;
                    _e.cool = 103;
                    break;
                case LK_ENEMY.Wisp:
                    lk_enemy_burst(_e, 8, _e.angle, 45, 2.13, C_LILAC);
                    _e.cool = irandom_range(86, 125);
                    break;
            }
            // Shorten the idle time after an attack, not its warning or release.
            if (_later) _e.cool = ceil(_e.cool * (.76 - min(depth_no, 3) * .02));
        }
    } else {
        switch (_e.kind) {
            case LK_ENEMY.Skulk:
            case LK_ENEMY.Leech:
                var _leech = _e.kind == LK_ENEMY.Leech;
                if (_e.cool <= 0 && _range < (_leech ? 119 : 67)) {
                    _e.tell = _leech ? 24 : 15;
                    _e.angle = lk_lead(_e, _leech ? 3.5 : 2.6);
                    lk_charge_sound(_e);
                } else {
                    lk_enemy_walk(_e, (_leech ? 1.42 : 1.16) + floor_no * .11,
                        _toward + (_leech ? dsin(world_tick * 5 + _e.phase) * 36 : 0));
                }
                break;
            case LK_ENEMY.Harpoon:
                if (_range < 96) {
                    lk_enemy_walk(_e, .94, _toward + 165);
                } else if (_range > 235 || !lk_line_clear(_e.px, _e.py, player.px, player.py)) {
                    lk_enemy_walk(_e, .98, _toward + dsin(world_tick * 3 + _e.phase) * 37);
                } else if (_e.cool <= 0) {
                    _e.tell = 42;
                    _e.angle = lk_lead(_e, lk_enemy_shot_speed(5.9));
                    lk_charge_sound(_e);
                }
                break;
            case LK_ENEMY.Prism:
                if (_e.cool <= 0 && _range < 180) {
                    _e.tell = 29;
                    _e.angle = lk_lead(_e, 2.72);
                    lk_charge_sound(_e);
                } else {
                    var _flank = clamp(72 - (_range - 115) * 2, 0, 148);
                    lk_enemy_walk(_e, 1.14, _toward + (_e.phase mod 2 == 0 ? _flank : -_flank));
                }
                break;
            case LK_ENEMY.Monk:
                if (_e.cool <= 0 && _range < 194) {
                    _e.tell = 29;
                    _e.angle = _toward;
                    lk_charge_sound(_e);
                    lk_ring(_e.px, _e.py, C_GOLD, 21, _e.tell);
                } else if (_range > 149) {
                    lk_enemy_walk(_e, .66, _toward);
                } else if (_range < 54) {
                    lk_enemy_walk(_e, .72, _toward + 155);
                }
                break;
            case LK_ENEMY.Sentry: {
                if (_e.echo > 0) break;
                var _clear = lk_line_clear(_e.px, _e.py, player.px, player.py);
                var _side = _e.phase mod 2 == 0 ? 1 : -1;
                if (_e.cool <= 0 && _range < 210 && _clear) {
                    _e.tell = 25;
                    _e.angle = lk_lead(_e, 3.35 + depth_no * .12);
                    lk_charge_sound(_e);
                } else if (_range > 152 || !_clear) {
                    lk_enemy_walk(_e, .88, _toward + (_later && !_clear ? _side * 45 : 0));
                } else if (_later) {
                    lk_enemy_walk(_e, .58, _toward + _side * (_range < 80 ? 120 : 90));
                }
                break;
            }
            case LK_ENEMY.Bruiser:
                if (_e.cool <= 0 && _range < 102) {
                    _e.tell = 34;
                    _e.angle = lk_lead(_e, 2.31);
                    lk_charge_sound(_e);
                } else if (_range > 35) {
                    lk_enemy_walk(_e, .93, _toward);
                }
                break;
            case LK_ENEMY.Spitter: {
                var _clear = !_later || lk_line_clear(_e.px, _e.py, player.px, player.py);
                var _side = _e.phase mod 2 == 0 ? 1 : -1;
                if (_e.cool <= 0 && _range < 170 && _clear) {
                    _e.tell = 27;
                    lk_charge_sound(_e);
                    _e.angle = lk_lead(_e, 2.47 + floor_no * .23);
                } else if (_range > 94 || !_clear) {
                    lk_enemy_walk(_e, .66 + floor_no * .09, _toward + (!_clear ? _side * 45 : 0));
                } else if (_range < 46) {
                    lk_enemy_walk(_e, .76, _toward + 164);
                } else if (_later) {
                    lk_enemy_walk(_e, .55, _toward + _side * 90);
                }
                break;
            }
            case LK_ENEMY.Wisp:
                if (_e.cool <= 0 && _range < 145) {
                    _e.tell = 30;
                    _e.angle = _toward + 22.5;
                    lk_charge_sound(_e);
                } else {
                    var _orbit = clamp(90 - (_range - 86) * 2.7, 0, 156);
                    lk_enemy_walk(_e, .91, _toward + (_e.phase mod 2 == 0 ? _orbit : -_orbit));
                }
                break;
            case LK_ENEMY.Charger:
                if (_e.cool <= 0 && _range < 132) {
                    _e.tell = 31;
                    lk_charge_sound(_e);
                    _e.angle = lk_lead(_e, 3.1);
                } else if (_range > 38) {
                    lk_enemy_walk(_e, .70, _toward);
                }
                break;
        }
    }
    _e.tell = max(0, _e.tell - 1);
    if (_range < _e.radius + 5) lk_player_hurt(_e.dash > 0 || _e.kind == LK_ENEMY.Boss || _e.kind == LK_ENEMY.Bruiser ? 2 : 1);

    // Soft separation prevents moving enemies from collapsing into one sprite.
    if (_e.kind != LK_ENEMY.Boss && _e.dash == 0) {
        for (var _j = 0; _j < array_length(enemies); _j++) {
            var _other = enemies[_j];
            if (_other == _e || !_other.alive) continue;
            var _gap = point_distance(_e.px, _e.py, _other.px, _other.py);
            if (_gap < _e.radius + _other.radius - 2) {
                var _away = _gap > .01 ? point_direction(_other.px, _other.py, _e.px, _e.py) : _e.phase * 15;
                lk_move(_e, lengthdir_x(.48, _away), lengthdir_y(.48, _away), _e.radius);
            }
        }
    }
}

function lk_explode(_b) {
    lk_sound(snd_blast, random_range(.90, 1.08));
    lk_ring(_b.px, _b.py - 3, _b.color, 31, 22);
    lk_sparks(_b.px, _b.py - 3, _b.color, 17, 2.6);
    shaking = max(shaking, 4);
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (point_distance(_b.px, _b.py, _e.px, _e.py) <= 30 + _e.radius) {
            lk_enemy_damage(_e, _b.damage, _b.angle, true);
        }
    }
}

function lk_shot_impact(_b) {
    if (!_b.friendly) return;
    if (_b.kind == LK_SHOT.Blast) lk_explode(_b);
    if (_b.kind == LK_SHOT.Vial) lk_field(_b.px, _b.py, 0, 4, _b.damage, 25, C_MINT);
    if (_b.kind == LK_SHOT.Mortar) lk_field(_b.px, _b.py, 1, 9, _b.damage, 40, C_PINK);
}

function lk_shot_step(_b) {
    if (_b.kind == LK_SHOT.Orbit) return lk_orbit_step(_b);
    _b.life -= 1;
    _b.age += 1;
    if (_b.life <= 0) {
        if (_b.kind == LK_SHOT.Vial || _b.kind == LK_SHOT.Mortar) lk_shot_impact(_b);
        return false;
    }
    var _disc = _b.kind == LK_SHOT.Disc;
    if (_disc && _b.age >= 21) lk_disc_turn(_b);
    if (_b.returning) {
        if (point_distance(_b.px, _b.py, player.px, player.py) < 8) return false;
        _b.angle = point_direction(_b.px, _b.py, player.px, player.py);
    }
    var _steps = ceil(_b.speed / 3);
    var _dx = lengthdir_x(_b.speed / _steps, _b.angle);
    var _dy = lengthdir_y(_b.speed / _steps, _b.angle);
    repeat (_steps) {
        _b.px += _dx;
        _b.py += _dy;
        if (!lk_keep_bounds(_b.px, _b.py, 0, false)) {
            if (_b.bounces > 0) {
                if (_b.px < KEEP_LEFT || _b.px > KEEP_RIGHT) _b.angle = 180 - _b.angle;
                if (_b.py < KEEP_TOP || _b.py > KEEP_BOTTOM) _b.angle = -_b.angle;
                _b.px = clamp(_b.px, KEEP_LEFT + 1, KEEP_RIGHT - 1);
                _b.py = clamp(_b.py, KEEP_TOP + 1, KEEP_BOTTOM - 1);
                _b.bounces -= 1;
                lk_sparks(_b.px, _b.py - 3, _b.color, 7, 1.35);
                lk_sound(snd_ricochet, random_range(.94, 1.13));
                return true;
            }
            if (_disc && !_b.returning) {
                _b.px -= _dx;
                _b.py -= _dy;
                lk_disc_turn(_b);
                return true;
            }
            lk_shot_impact(_b);
            return false;
        }
        var _prop = _b.returning || _b.kind == LK_SHOT.Wraith ? undefined : lk_prop_at(_b.px, _b.py, _b.radius * .5);
        if (!is_undefined(_prop)) {
            if (_b.bounces > 0 && _prop.kind == 1) {
                var _normal = point_direction(_prop.px, _prop.py, _b.px, _b.py);
                _b.px = _prop.px + lengthdir_x(_prop.radius + _b.radius + 1, _normal);
                _b.py = _prop.py + lengthdir_y(_prop.radius + _b.radius + 1, _normal);
                _b.angle = 2 * (_normal + 90) - _b.angle;
                _b.bounces -= 1;
                lk_sparks(_b.px, _b.py - 4, _b.color, 4, 1.15);
                lk_sound(snd_ricochet);
                return true;
            }
            if (_b.friendly) lk_break_prop(_prop, _b.damage);
            if (_disc) {
                lk_disc_turn(_b);
                return true;
            }
            lk_shot_impact(_b);
            lk_sparks(_b.px, _b.py - 4, _b.color, 3, 1.2);
            return false;
        }
        if (_b.friendly) {
            for (var _i = 0; _i < array_length(enemies); _i++) {
                var _e = enemies[_i];
                if (!_e.alive || _e.emerge > 9 || array_contains(_b.hit_list, _e)) continue;
                if (point_distance(_b.px, _b.py, _e.px, _e.py) >= _e.radius + _b.radius) continue;
                if (_b.kind == LK_SHOT.Blast || _b.kind == LK_SHOT.Vial || _b.kind == LK_SHOT.Mortar) {
                    lk_shot_impact(_b);
                    return false;
                }
                lk_enemy_damage(_e, _b.damage, _b.angle);
                if (_b.kind == LK_SHOT.Pierce) _e.slow = 55;
                if (!_disc && _b.pierce == 0) return false;
                _b.pierce -= 1;
                array_push(_b.hit_list, _e);
            }
        } else {
            if (lk_guard_shot(_b)) return true;
            if (point_distance(_b.px, _b.py, player.px, player.py) < _b.radius + 4
                && (lk_player_hurt(_b.damage) || player.dash_time > 0)) return false;
        }
    }
    return true;
}

function lk_update_loot() {
    var _picked_up = false;
    for (var _i = array_length(cell.loot) - 1; _i >= 0; _i--) {
        var _p = cell.loot[_i];
        if (_p.wait > 0) { _p.wait -= 1; continue; }
        if (_p.kind == LK_LOOT.Weapon) continue;
        if (_p.kind == LK_LOOT.Heart && player.hp >= player.max_hp) continue;
        if (_p.kind == LK_LOOT.Energy && player.energy >= player.max_energy) continue;
        var _dist = point_distance(_p.px, _p.py, player.px, player.py);
        if (_dist < 37) {
            var _a = point_direction(_p.px, _p.py, player.px, player.py);
            _p.px += lengthdir_x(2.2, _a);
            _p.py += lengthdir_y(2.2, _a);
        }
        if (_dist >= 12) continue;
        switch (_p.kind) {
            case LK_LOOT.Coin: player.coins += _p.value; break;
            case LK_LOOT.Heart: player.hp = min(player.max_hp, player.hp + _p.value); break;
            case LK_LOOT.Energy: player.energy = min(player.max_energy, player.energy + _p.value); break;
        }
        lk_sound(snd_pick, _p.kind == LK_LOOT.Coin ? 1.32 : .96);
        array_delete(cell.loot, _i, 1);
        _picked_up = true;
    }
    if (_picked_up && cell.clear) lk_save_checkpoint();
}

function lk_play_step() {
    if (hit_stop > 0) {
        hit_stop -= 1;
        buffered_skill = buffered_skill || skill_pressed;
        buffered_swap = buffered_swap || swap_pressed;
        buffered_interact = buffered_interact || interact_pressed;
        return;
    }
    skill_pressed = skill_pressed || buffered_skill;
    swap_pressed = swap_pressed || buffered_swap;
    interact_pressed = interact_pressed || buffered_interact;
    buffered_skill = false;
    buffered_swap = false;
    buffered_interact = false;
    world_tick += 1;
    banner_time = max(0, banner_time - 1);
    room_fade = max(0, room_fade - 1);
    door_cooldown = max(0, door_cooldown - 1);
    flash_screen = max(0, flash_screen - 1);
    shaking = max(0, shaking - .47);
    if (boss_intro > 0) {
        boss_intro -= 1;
        var _boss = enemies[0];
        _boss.emerge = max(0, _boss.emerge - 1);
        if (boss_intro > 0 && _boss.emerge == 0 && interact_pressed) boss_intro = 0;
        lk_update_effects();
        return;
    }
    player.hurt = max(0, player.hurt - 1);
    player.fire_wait = max(0, player.fire_wait - 1);
    player.kick = max(0, player.kick - 1);
    player.skill_time = max(0, player.skill_time - 1);
    player.skill_anim = max(0, player.skill_anim - 1);
    player.guard = max(0, player.guard - 1);
    player.fury = max(0, player.fury - 1);
    player.skill_wait = max(0, player.skill_wait - 1);
    lk_armor_step();
    lk_room_hazard_step();
    if (wave_wait >= 0) {
        wave_wait -= 1;
        if (wave_wait == 0) lk_spawn_wave();
    }
    if (swap_pressed || keyboard_check_pressed(ord("1")) || keyboard_check_pressed(ord("2"))) {
        var _slot = 1 - player.slot;
        if (keyboard_check_pressed(ord("1"))) _slot = 0;
        if (keyboard_check_pressed(ord("2"))) _slot = 1;
        if (_slot != player.slot) {
            player.slot = _slot;
            player.fire_wait = max(player.fire_wait, 6);
            lk_sound(snd_pick, .72);
        }
    }
    player.aim = lk_aim();
    var _face = lengthdir_x(1, player.aim);
    if (abs(_face) > .15) player.facing = sign(_face);
    if (skill_pressed) lk_use_skill();
    player.moving = move_x != 0 || move_y != 0 || player.dash_time > 0;
    if (player.dash_time > 0) {
        lk_move(player, player.dash_x, player.dash_y, 5, true);
        if (player.dash_time mod 3 == 0) {
            lk_ring(player.px, player.py, C_PINK, 0, 13, 3, player.facing);
        }
        lk_sparks(player.px, player.py - 5, C_PINK, 2, .85);
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _e = enemies[_i];
            if (!_e.dash_hit && point_distance(player.px, player.py, _e.px, _e.py) < _e.radius + 11) {
                _e.dash_hit = true;
                lk_enemy_damage(_e, ceil(8 * player.damage_scale), player.aim, true);
            }
        }
        player.dash_time -= 1;
        player.hurt = max(player.hurt, 3);
    } else {
        var _pace = player.move_pace * (player.guard > 0 ? .88 : 1) * (player.fury > 0 ? 1.23 : 1);
        lk_move(player, move_x * _pace, move_y * _pace, 5, true);
        if (player.moving && world_tick mod 8 == 0) {
            lk_sparks(player.px, player.py + 1, merge_color(lk_theme_tint(floor_no), C_PANEL, .60), 2, .58);
        }
    }
    if (lk_check_door()) return;
    if (fire_held && player.fire_wait == 0) lk_fire();
    if (interact_pressed) {
        lk_interact(lk_interaction());
        if (mode != LK_MODE.Play) return;
    }
    for (var _i = array_length(enemies) - 1; _i >= 0; _i--) {
        if (enemies[_i].alive) lk_enemy_step(enemies[_i]);
        else array_delete(enemies, _i, 1);
        if (mode == LK_MODE.Dead) return;
    }
    lk_tide_step();
    for (var _i = array_length(shots) - 1; _i >= 0; _i--) {
        if (!lk_shot_step(shots[_i])) array_delete(shots, _i, 1);
        if (mode == LK_MODE.Dead) return;
    }
    for (var _i = array_length(fields) - 1; _i >= 0; _i--) {
        if (!lk_field_step(fields[_i])) array_delete(fields, _i, 1);
        if (mode == LK_MODE.Dead) return;
    }
    lk_finish_wave();
    lk_update_loot();
    lk_update_effects();
}
