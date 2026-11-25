enum LK_MODE { Title, Select, Play, Pause, Boon, Dead, Won, Journal, Contract }
enum LK_ROOM { Landing, Fight, Cache, Shop, Shrine, Boss, Gauntlet, Relic, Forge, SparkShrine, Armory, SupplyPost, TemperRelay, Duel }
enum LK_LOOT { Coin, Energy, Heart, Weapon }
enum LK_ENEMY { Skulk, Spitter, Charger, Wisp, Boss, Sentry, Leech, Bruiser, Harpoon, Prism, Monk }

#macro C_INK $1B1015
#macro C_DEEP $2B191E
#macro C_PANEL $39282C
#macro C_EDGE $574042
#macro C_PAPER $C8E7F5
#macro C_MUTED $AC9D9E
#macro C_GOLD $70C5F4
#macro C_TEAL $B7D567
#macro C_MINT $A9EBAD
#macro C_PINK $7682F4
#macro C_LILAC $E4B39E
#macro C_BLUE $F0BC75
#macro KEEP_LEFT 48
#macro KEEP_RIGHT 432
#macro KEEP_TOP 59
#macro KEEP_BOTTOM 227
#macro KEEP_MID_Y 143
#macro LK_BOSS_INTRO 90
#macro LK_VERSION "1.2.1+dev"

function lk_input() {
    pad = -1;
    for (var _i = 0; _i < gamepad_get_device_count(); _i++) {
        if (gamepad_is_connected(_i)) { pad = _i; break; }
    }
    var _pad = pad >= 0;
    accept_pressed = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)
        || (_pad && gamepad_button_check_pressed(pad, gp_face1));
    back_pressed = keyboard_check_pressed(vk_escape)
        || (_pad && gamepad_button_check_pressed(pad, gp_start));
    menu_left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        || (_pad && gamepad_button_check_pressed(pad, gp_padl));
    menu_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
        || (_pad && gamepad_button_check_pressed(pad, gp_padr));
    menu_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))
        || (_pad && gamepad_button_check_pressed(pad, gp_padu));
    menu_down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))
        || (_pad && gamepad_button_check_pressed(pad, gp_padd));
    menu_vert = menu_up || menu_down;
    move_x = keyboard_check(ord("D")) + keyboard_check(vk_right) - keyboard_check(ord("A")) - keyboard_check(vk_left);
    move_y = keyboard_check(ord("S")) + keyboard_check(vk_down) - keyboard_check(ord("W")) - keyboard_check(vk_up);
    aim_x = 0;
    aim_y = 0;
    if (_pad) {
        move_x += gamepad_axis_value(pad, gp_axislh);
        move_y += gamepad_axis_value(pad, gp_axislv);
        move_x += gamepad_button_check(pad, gp_padr) - gamepad_button_check(pad, gp_padl);
        move_y += gamepad_button_check(pad, gp_padd) - gamepad_button_check(pad, gp_padu);
        aim_x = gamepad_axis_value(pad, gp_axisrh);
        aim_y = gamepad_axis_value(pad, gp_axisrv);
    }
    var _speed = point_distance(0, 0, move_x, move_y);
    if (_speed < 0.20) { move_x = 0; move_y = 0; }
    if (_speed > 1) { move_x /= _speed; move_y /= _speed; }
    manual_fire = pointer_fire || point_distance(0, 0, aim_x, aim_y) > 0.28;
    fire_held = manual_fire || keyboard_check(vk_space) || (_pad && (gamepad_button_check(pad, gp_shoulderr) || gamepad_button_check(pad, gp_shoulderrb)));
    skill_pressed = keyboard_check_pressed(ord("Q")) || (_pad && gamepad_button_check_pressed(pad, gp_shoulderl));
    interact_pressed = keyboard_check_pressed(ord("E")) || (_pad && gamepad_button_check_pressed(pad, gp_face1));
    swap_pressed = keyboard_check_pressed(vk_tab) || (pointer_inside && (mouse_wheel_up() || mouse_wheel_down()))
        || (_pad && gamepad_button_check_pressed(pad, gp_face3));
}

function lk_save() {
    ini_open("lantern_keep.ini");
    ini_write_real("runs", "best_depth", best_floor);
    ini_write_real("runs", "expanded_wins", wins);
    ini_write_real("settings", "muted", muted);
    ini_write_real("runs", "started", runs_started);
    ini_write_real("runs", "archived_kills", total_kills);
    ini_write_real("daily", "date", daily_record_date);
    ini_write_real("daily", "depth", daily_record_depth);
    for (var _i = 0; _i < array_length(contract_best); _i++) {
        ini_write_real("contracts", string(_i), contract_best[_i]);
    }
    for (var _i = 0; _i < array_length(weapon_found); _i++) {
        if (weapon_found[_i]) ini_write_real("armory", string(_i), 1);
    }
    for (var _i = 0; _i < array_length(relic_found); _i++) {
        if (relic_found[_i]) ini_write_real("relics", string(_i), 1);
    }
    ini_close();
}

function lk_sound(_sound, _pitch = 1) {
    if (!muted) {
        var _instance = audio_play_sound(_sound, 2, false);
        audio_sound_pitch(_instance, _pitch);
    }
}

function lk_music() {
    if (muted) {
        for (var _i = 0; _i < array_length(music_voices); _i++) audio_stop_sound(music_voices[_i].id);
        music_voices = [];
        music_fade_in = 0;
        return;
    }

    var _track = snd_title;
    if (mode == LK_MODE.Play || mode == LK_MODE.Pause || mode == LK_MODE.Boon) {
        _track = cell.kind == LK_ROOM.Boss && !cell.clear
            ? (floor_no == 4 ? snd_boss_crown : snd_boss)
            : [snd_music, snd_cinder, snd_hollow, snd_glassfen, snd_reliquary][floor_no];
    }
    var _seconds = clamp(delta_time * .000001, 0, .05);
    var _volume = (mode == LK_MODE.Pause || mode == LK_MODE.Boon) ? .35 : .82;
    music_gain += clamp(_volume - music_gain, -_seconds * 1.3, _seconds * 1.3);
    var _step = _seconds / 1.8;
    music_fade_in = min(1, music_fade_in + _step);
    var _power = 0;
    var _found = false;
    for (var _i = array_length(music_voices) - 1; _i >= 0; _i--) {
        var _voice = music_voices[_i];
        var _current = _voice.track == _track;
        _voice.fade = clamp(_voice.fade + (_current ? _step : -_step), 0, 1);
        if ((!_current && _voice.fade == 0) || !audio_is_playing(_voice.id)) {
            audio_stop_sound(_voice.id);
            array_delete(music_voices, _i, 1);
            continue;
        }
        _found = _found || _current;
        _voice.gain = dsin(_voice.fade * 90);
        _power += sqr(_voice.gain);
    }
    if (!_found) {
        var _instance = audio_play_sound(_track, 0, true);
        audio_sound_gain(_instance, 0, 0);
        array_push(music_voices, {id: _instance, track: _track, fade: 0, gain: 0, applied: 0});
    }
    // Keep overlapping tracks near the same perceived level during a crossfade.
    var _mix = music_gain * dsin(music_fade_in * 90) / sqrt(max(.0001, _power));
    for (var _i = 0; _i < array_length(music_voices); _i++) {
        var _voice = music_voices[_i];
        var _gain = _voice.gain * _mix;
        if (abs(_gain - _voice.applied) < .0001) continue;
        audio_sound_gain(_voice.id, _gain, 22);
        _voice.applied = _gain;
    }
}

function lk_begin_run() {
    var _hero = heroes[hero_id];
    player = {
        px: 240, py: 155, hp: _hero.hp, max_hp: _hero.hp,
        armor: _hero.armor, max_armor: _hero.armor, energy: 100, max_energy: 100,
        regen: 0, hurt: 0, fire_wait: 0, kick: 0, facing: 1, aim: 0, moving: false,
        skill_wait: 0, skill_time: 0, guard: 0, skill_anim: 0, target: undefined, dash_time: 0, dash_x: 0, dash_y: 0,
        arms: [_hero.arms[0], _hero.arms[1]], slot: 0, coins: 0,
        damage_scale: 1, haste: 1, move_pace: _hero.speed,
        relics: array_create(array_length(relic_catalog), 0), knot_spent: false,
        temper: [0, 0], boons: [], tide: 0, fury: 0, traits: [false, false, false],
        charged_shot: false, fire_number: 0
    };
    lk_contract_setup();
    runs_started += 1;
    weapon_found[_hero.arms[0]] = true;
    weapon_found[_hero.arms[1]] = true;
    choose_relic = false;
    depth_no = 0;
    floor_no = 0;
    rooms_cleared = 0;
    kills = 0;
    world_tick = 0;
    lk_start_floor();
    mode = LK_MODE.Play;
}

function lk_new_room(_gx, _gy, _kind) {
    return {gx: _gx, gy: _gy, kind: _kind, exits: [-1,-1,-1,-1], visited: false,
        clear: _kind != LK_ROOM.Fight && _kind != LK_ROOM.Boss && _kind != LK_ROOM.Gauntlet && _kind != LK_ROOM.Duel,
        layout: irandom_range(0, 9), seed: irandom_range(20, 9000), props: [], loot: [],
        opened: false, bought: [false, false, false], stock: irandom_range(2, array_length(weapons) - 1),
        stock_temper: depth_no >= 3 ? irandom_range(1, clamp(floor(depth_no / 2), 1, 3)) : 0,
        encounter: _kind == LK_ROOM.Fight && array_length(dungeon) > 1 ? irandom(4) : 0,
        shrine_used: false};
}

function lk_find_room(_gx, _gy) {
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        if (dungeon[_i].gx == _gx && dungeon[_i].gy == _gy) return _i;
    }
    return -1;
}

function lk_link_room(_from, _kind, _preferred = -1) {
    var _dx = [1, 0, -1, 0];
    var _dy = [0, 1, 0, -1];
    var _parent = dungeon[_from];
    var _start = _preferred >= 0 ? _preferred : irandom(3);
    for (var _i = 0; _i < 4; _i++) {
        var _dir = (_start + _i) mod 4;
        var _gx = _parent.gx + _dx[_dir];
        var _gy = _parent.gy + _dy[_dir];
        if (lk_find_room(_gx, _gy) != -1) continue;
        var _next = array_length(dungeon);
        var _cell = lk_new_room(_gx, _gy, _kind);
        _parent.exits[_dir] = _next;
        _cell.exits[(_dir + 2) mod 4] = _from;
        array_push(dungeon, _cell);
        return _next;
    }
    return -1;
}

function lk_stage_fights() {
    return 3 + min(depth_no, 5) - (lk_stage_waystation() >= 0);
}

function lk_make_route(_preferred) {
    dungeon = [];
    array_push(dungeon, lk_new_room(0, 0, LK_ROOM.Landing));
    var _station = lk_stage_waystation();
    var _length = lk_stage_fights() + (_station >= 0);
    var _station_index = _station >= 0 ? irandom_range(2, _length) : -1;
    var _parent = 0;
    for (var _i = 1; _i <= _length; _i++) {
        _parent = lk_link_room(_parent, _i == _station_index ? _station : LK_ROOM.Fight, _preferred);
        if (_parent == -1) return false;
    }
    return lk_link_room(_parent, LK_ROOM.Boss, _preferred) >= 0;
}

function lk_stage_biome(_stage) {
    return _stage < 6 ? floor(_stage / 2) : _stage - 3;
}

function lk_add_branches() {
    var _route_end = array_length(dungeon) - 1;
    var _trial = lk_stage_waystation() == LK_ROOM.SupplyPost ? LK_ROOM.Duel : LK_ROOM.Gauntlet;
    var _branches = [LK_ROOM.Shrine, LK_ROOM.Forge, LK_ROOM.Cache, LK_ROOM.Shop, _trial];
    if (depth_no > 0) {
        array_push(_branches, LK_ROOM.SparkShrine);
        array_push(_branches, LK_ROOM.Relic);
    }
    for (var _j = 0; _j < array_length(_branches); _j++) {
        var _start = irandom(_route_end - 1);
        var _placed = false;
        for (var _i = 0; _i < _route_end; _i++) {
            if (lk_link_room((_start + _i) mod _route_end, _branches[_j]) < 0) continue;
            _placed = true;
            break;
        }
        if (!_placed) return false;
    }
    return true;
}

function lk_build_stage_map() {
    repeat (36) {
        if (lk_make_route(-1) && lk_add_branches()) return;
    }
    // A straight route leaves space for every branch.
    lk_make_route(0);
    lk_add_branches();
}

function lk_start_floor() {
    floor_no = lk_stage_biome(depth_no);
    if (run_contract == LK_CONTRACT.Daily) random_set_seed(run_seed + depth_no * 8731);
    lk_build_stage_map();
    lk_contract_record();
    lk_save();
    lk_enter_room(0, -1);
    lk_save_checkpoint();
}

function lk_add_prop(_cell, _x, _y, _kind) {
    array_push(_cell.props, {px: _x, py: _y, kind: _kind, radius: _kind == 1 ? 11 : 8,
        hp: _kind == 1 ? -1 : 2, alive: true});
}

function lk_furnish(_cell) {
    if (_cell.kind == LK_ROOM.Boss) {
        lk_add_prop(_cell, 116, 142, 1);
        lk_add_prop(_cell, 364, 142, 1);
        return;
    }
    if (_cell.kind == LK_ROOM.Duel) {
        lk_add_prop(_cell, 162, 160, 1);
        lk_add_prop(_cell, 318, 124, 1);
        return;
    }
    if (_cell.kind != LK_ROOM.Fight && _cell.kind != LK_ROOM.Gauntlet) return;
    if (_cell.encounter == 2) {
        lk_add_prop(_cell, 115, 99, 1);
        lk_add_prop(_cell, 365, 99, 1);
        lk_add_prop(_cell, 115, 190, 1);
        lk_add_prop(_cell, 365, 190, 1);
        return;
    }
    if (_cell.encounter == 3) {
        var _stagger = _cell.seed mod 2 * 17;
        for (var _i = 0; _i < 3; _i++) {
            lk_add_prop(_cell, 143 + _i * 22, 119 - _stagger, 1);
            lk_add_prop(_cell, 337 - _i * 22, 167 + _stagger, 1);
        }
        return;
    }
    switch (_cell.layout) {
        case 0:
            lk_add_prop(_cell, 156, 105, 1);
            lk_add_prop(_cell, 324, 185, 1);
            lk_add_prop(_cell, 179, 112, 0);
            lk_add_prop(_cell, 303, 177, 2);
            break;
        case 1:
            lk_add_prop(_cell, 124, 185, 0);
            lk_add_prop(_cell, 141, 185, 2);
            lk_add_prop(_cell, 354, 103, 0);
            lk_add_prop(_cell, 372, 108, 0);
            break;
        case 2:
            lk_add_prop(_cell, 168, 97, 1);
            lk_add_prop(_cell, 315, 97, 1);
            lk_add_prop(_cell, 168, 191, 1);
            lk_add_prop(_cell, 315, 191, 1);
            break;
        case 3:
            lk_add_prop(_cell, 225, 142, 2);
            lk_add_prop(_cell, 242, 142, 0);
            lk_add_prop(_cell, 259, 142, 2);
            lk_add_prop(_cell, 242, 160, 0);
            break;
        case 4:
            lk_add_prop(_cell, 112, 94, 2);
            lk_add_prop(_cell, 368, 193, 2);
            lk_add_prop(_cell, 207, 109, 1);
            lk_add_prop(_cell, 272, 176, 1);
            break;
        case 5:
            lk_add_prop(_cell, 126, 145, 1);
            lk_add_prop(_cell, 352, 145, 1);
            lk_add_prop(_cell, 142, 149, 0);
            lk_add_prop(_cell, 336, 149, 0);
            break;
        case 6:
            for (var _i = 0; _i < 3; _i++) {
                lk_add_prop(_cell, 152 + _i * 14, 98 + _i * 16, 1);
                lk_add_prop(_cell, 328 - _i * 14, 190 - _i * 16, 1);
            }
            break;
        case 7:
            lk_add_prop(_cell, 230, 109, 1);
            lk_add_prop(_cell, 250, 179, 1);
            lk_add_prop(_cell, 119, 173, 2);
            lk_add_prop(_cell, 361, 111, 2);
            break;
        case 8:
            for (var _i = 0; _i < 4; _i++) {
                lk_add_prop(_cell, 98 + _i * 17, 105, _i mod 3);
                lk_add_prop(_cell, 382 - _i * 17, 186, _i mod 3);
            }
            break;
        case 9:
            lk_add_prop(_cell, 204, 128, 1);
            lk_add_prop(_cell, 276, 159, 1);
            lk_add_prop(_cell, 216, 151, 0);
            lk_add_prop(_cell, 264, 134, 2);
            break;
    }
}

function lk_enter_room(_index, _entry) {
    cell_index = _index;
    cell = dungeon[_index];
    enemies = [];
    shots = [];
    fields = [];
    particles = [];
    floaters = [];
    wave = 0;
    wave_count = cell.kind == LK_ROOM.Boss || cell.kind == LK_ROOM.Duel ? 1 : (cell.kind == LK_ROOM.Gauntlet ? 3
        : ((depth_no > 0 || _index mod 3 != 1) ? 2 : 1));
    if (cell.kind == LK_ROOM.Fight && (cell.encounter == 2 || cell.encounter == 4)) wave_count = 1;
    hazard_wait = lk_rupture_room() ? 108 + cell.seed mod 36 : 145 + cell.seed mod 68;
    hazard_side = cell.seed mod 2;
    wave_wait = -1;
    shaking = 0;
    hit_stop = 0;
    buffered_skill = false;
    buffered_swap = false;
    buffered_interact = false;
    charge_sound_at = -30;
    flash_screen = 0;
    room_fade = 13;
    door_cooldown = 19;
    player.px = 240;
    player.py = 183;
    player.dash_time = 0;
    player.tide = 0;
    player.target = undefined;
    player.hurt = max(22, player.hurt);
    armor_repair_span = LK_ARMOR_FIRST_REPAIR;
    if (!cell.clear && player.armor < player.max_armor && lk_combat_armor_enabled()) {
        lk_armor_timer(LK_ARMOR_FIRST_REPAIR);
    }
    switch (_entry) {
        case 0: player.px = 403; player.py = KEEP_MID_Y; break;
        case 1: player.py = 205; break;
        case 2: player.px = 77; player.py = KEEP_MID_Y; break;
        case 3: player.py = 81; break;
    }
    if (!cell.visited) {
        cell.visited = true;
        lk_furnish(cell);
    }
    banner = lk_room_name(cell.kind);
    banner_time = 105;
    boss_intro = 0;
    if (!cell.clear) {
        if (cell.kind == LK_ROOM.Boss) {
            boss_intro = LK_BOSS_INTRO;
            banner_time = 0;
            player.moving = false;
            lk_spawn_wave();
        } else {
            wave_wait = 48;
        }
    }
}

function lk_is_shrine(_kind) {
    return _kind == LK_ROOM.Shrine || _kind == LK_ROOM.SparkShrine;
}

function lk_room_name(_kind) {
    switch (_kind) {
        case LK_ROOM.Landing: return stage_names[depth_no];
        case LK_ROOM.Fight: return ["AMBUSH", "CROSSFIRE", "ELITE HUNT", "RUPTURE", "SWARM"][cell.encounter];
        case LK_ROOM.Cache: return "SUPPLY CACHE";
        case LK_ROOM.Shop: return "TINKER'S SHOP";
        case LK_ROOM.Shrine: return "SHRINE OF ASH";
        case LK_ROOM.SparkShrine: return "SHRINE OF SPARKS";
        case LK_ROOM.Gauntlet: return "GAUNTLET";
        case LK_ROOM.Relic: return "RELIQUARY";
        case LK_ROOM.Forge: return "TEMPER FORGE";
        case LK_ROOM.Armory: return "SALVAGE RACK";
        case LK_ROOM.SupplyPost: return "KEEPER'S STORES";
        case LK_ROOM.TemperRelay: return "TEMPER RELAY";
        case LK_ROOM.Duel: return "ELITE DUEL";
        case LK_ROOM.Boss: return boss_names[depth_no];
    }
    return "";
}

function lk_door_open(_dir) {
    return cell.clear && cell.exits[_dir] >= 0;
}

function lk_keep_bounds(_x, _y, _r, _through_doors) {
    if (_x - _r < KEEP_LEFT && !(_through_doors && lk_door_open(2) && abs(_y - KEEP_MID_Y) < 14)) return false;
    if (_x + _r > KEEP_RIGHT && !(_through_doors && lk_door_open(0) && abs(_y - KEEP_MID_Y) < 14)) return false;
    if (_y - _r < KEEP_TOP && !(_through_doors && lk_door_open(3) && abs(_x - 240) < 16)) return false;
    if (_y + _r > KEEP_BOTTOM && !(_through_doors && lk_door_open(1) && abs(_x - 240) < 16)) return false;
    return true;
}

function lk_prop_at(_x, _y, _r) {
    for (var _i = 0; _i < array_length(cell.props); _i++) {
        var _p = cell.props[_i];
        if (_p.alive && point_distance(_p.px, _p.py, _x, _y) < _p.radius + _r) return _p;
    }
    return undefined;
}

function lk_move(_body, _dx, _dy, _r, _player = false) {
    _player = _player && door_cooldown <= 0;
    var _x = _body.px + _dx;
    var _y = _body.py + _dy;
    if (lk_keep_bounds(_x, _body.py, _r, _player) && is_undefined(lk_prop_at(_x, _body.py, _r))) _body.px = _x;
    if (lk_keep_bounds(_body.px, _y, _r, _player) && is_undefined(lk_prop_at(_body.px, _y, _r))) _body.py = _y;
}

function lk_check_door() {
    if (!cell.clear || door_cooldown > 0) return false;
    var _dir = -1;
    if (player.px >= KEEP_RIGHT + 6) _dir = 0;
    if (player.py >= KEEP_BOTTOM + 6) _dir = 1;
    if (player.px <= KEEP_LEFT - 6) _dir = 2;
    if (player.py <= KEEP_TOP - 8) _dir = 3;
    if (_dir == -1 || !lk_door_open(_dir)) return false;
    var _next = cell.exits[_dir];
    if (!dungeon[_next].clear) lk_save_checkpoint();
    lk_enter_room(_next, (_dir + 2) mod 4);
    if (cell.clear) lk_save_checkpoint();
    return true;
}

function lk_drop(_kind, _x, _y, _value, _temper = -1) {
    if (_temper < 0) {
        _temper = 0;
        if (_kind == LK_LOOT.Weapon && depth_no >= 3) {
            _temper = clamp(floor((depth_no - 1) / 2), 1, 3);
            if (irandom(2) == 0) _temper = max(1, _temper - 1);
        }
    }
    array_push(cell.loot, {kind: _kind, px: _x, py: _y, value: _value, temper: _temper,
        wait: 16, phase: irandom(99), alive: true});
}

function lk_shop_item(_i) {
    var _name = weapons[cell.stock].name + (cell.stock_temper > 0 ? " +" + string(cell.stock_temper) : "");
    var _names = ["TONIC", "ENERGY CELL", _name];
    var _prices = [5, 4, 10 + floor_no * 3 + cell.stock_temper * 2];
    return {px: 173 + 67 * _i, py: 135, name: _names[_i], price: _prices[_i]};
}

function lk_interaction() {
    var _reach = 23;
    var _near = undefined;
    var _distance = _reach;
    for (var _i = 0; _i < array_length(cell.loot); _i++) {
        var _loot = cell.loot[_i];
        if (!_loot.alive || _loot.kind != LK_LOOT.Weapon || _loot.wait > 0) continue;
        var _range = point_distance(player.px, player.py, _loot.px, _loot.py);
        if (_range < _distance) {
            _distance = _range;
            var _quality = _loot.temper > 0 ? " +" + string(_loot.temper) : "";
            _near = {kind: "weapon", target: _loot, label: "TAKE " + weapons[_loot.value].name + _quality,
                detail: lk_weapon_details(_loot.value, _loot.temper, true)};
        }
    }
    if (cell.kind == LK_ROOM.Cache && !cell.opened && point_distance(player.px, player.py, 240, 137) < _reach) {
        return {kind: "chest", label: "OPEN CHEST"};
    }
    if (cell.kind == LK_ROOM.Shop) {
        for (var _i = 0; _i < 3; _i++) {
            var _item = lk_shop_item(_i);
            if (!cell.bought[_i] && point_distance(player.px, player.py, _item.px, _item.py) < _distance) {
                return {kind: "shop", index: _i, label: _item.name + " / " + string(_item.price) + "G"};
            }
        }
    }
    if (lk_is_waystation(cell.kind) && !cell.opened) {
        for (var _i = 0; _i < 2; _i++) {
            var _offer = lk_waystation_offer(_i);
            if (point_distance(player.px, player.py, _offer.px, _offer.py) < _reach) return _offer;
        }
    }
    if (lk_is_shrine(cell.kind) && !cell.shrine_used && point_distance(player.px, player.py, 240, 137) < _reach) {
        return {kind: "shrine", label: cell.kind == LK_ROOM.SparkShrine ? "CHOOSE A SPARK BOON" : "CHOOSE A BOON"};
    }
    if (cell.kind == LK_ROOM.Relic && !cell.opened && point_distance(player.px, player.py, 240, 137) < _reach) {
        return {kind: "relic", label: "CLAIM A RELIC"};
    }
    if (cell.kind == LK_ROOM.Forge && !cell.opened && player.temper[player.slot] < 3
        && point_distance(player.px, player.py, 240, 137) < _reach) {
        return {kind: "forge", label: "TEMPER WEAPON / " + string(lk_temper_cost()) + "G",
            detail: "+20% BASE DAMAGE FOR THIS WEAPON"};
    }
    if (cell.kind == LK_ROOM.Boss && cell.clear && point_distance(player.px, player.py, 240, 113) < 25) {
        return {kind: "portal", label: depth_no != array_length(stage_names) - 1 ? "DESCEND" :
            (run_contract == LK_CONTRACT.Endless ? "DESCEND AGAIN" : "RESTORE THE LANTERN")};
    }
    return _near;
}

function lk_interact(_action) {
    if (is_undefined(_action)) return;
    var _sound = snd_pick;
    switch (_action.kind) {
        case "weapon":
            var _loot = _action.target;
            var _old = player.arms[player.slot];
            var _temper = player.temper[player.slot];
            lk_remember_weapon(_loot.value);
            player.arms[player.slot] = _loot.value;
            player.temper[player.slot] = _loot.temper;
            _loot.value = _old;
            _loot.temper = _temper;
            _loot.wait = 25;
            break;
        case "chest":
            cell.opened = true;
            _sound = snd_chest;
            var _weapon = irandom_range(2, array_length(weapons) - 1);
            while (_weapon == player.arms[0] || _weapon == player.arms[1]) _weapon = irandom_range(2, array_length(weapons) - 1);
            lk_drop(LK_LOOT.Weapon, 240, 145, _weapon);
            lk_drop(LK_LOOT.Energy, 259, 148, 20);
            lk_drop(LK_LOOT.Coin, 220, 149, 3);
            lk_sparks(240, 134, C_GOLD, 25, 2);
            break;
        case "shop":
            var _index = _action.index;
            var _item = lk_shop_item(_index);
            if (player.coins < _item.price) {
                lk_floater(_item.px, _item.py - 12, "NEED " + string(_item.price) + "G", C_PINK);
                return;
            }
            if (_index == 0 && player.hp == player.max_hp || _index == 1 && player.energy == player.max_energy) {
                lk_floater(_item.px, _item.py - 12, "ALREADY FULL", C_MUTED);
                return;
            }
            player.coins -= _item.price;
            cell.bought[_index] = true;
            if (_index == 0) player.hp = min(player.max_hp, player.hp + 3);
            if (_index == 1) player.energy = min(player.max_energy, player.energy + 40);
            if (_index == 2) {
                lk_drop(LK_LOOT.Weapon, _item.px, _item.py + 13, player.arms[player.slot], player.temper[player.slot]);
                player.arms[player.slot] = cell.stock;
                player.temper[player.slot] = cell.stock_temper;
                lk_remember_weapon(cell.stock);
            }
            break;
        case "shrine":
            boon_options = lk_reward_choices(false, cell.kind == LK_ROOM.SparkShrine);
            if (array_length(boon_options) == 0) {
                cell.shrine_used = true;
                lk_drop(LK_LOOT.Coin, 240, 137, 8);
                break;
            }
            choose_relic = false;
            selected = 0;
            mode = LK_MODE.Boon;
            break;
        case "relic":
            boon_options = lk_reward_choices(true);
            if (array_length(boon_options) == 0) {
                cell.opened = true;
                lk_drop(LK_LOOT.Coin, 240, 137, 8);
                break;
            }
            selected = 0;
            choose_relic = true;
            mode = LK_MODE.Boon;
            _sound = snd_relic;
            break;
        case "forge":
            if (!lk_temper_changed()) return;
            _sound = snd_relic;
            break;
        case "waystation":
            if (!lk_claim_waystation(_action.index)) return;
            break;
        case "portal":
            _sound = snd_portal;
            if (depth_no == array_length(stage_names) - 1 && run_contract != LK_CONTRACT.Endless) {
                mode = LK_MODE.Won;
                wins += 1;
                total_kills += kills;
                lk_save();
                lk_discard_checkpoint();
            } else {
                depth_no += 1;
                if (depth_no >= array_length(stage_names)) {
                    depth_no = 0;
                    run_cycle += 1;
                }
                player.energy = min(player.max_energy, player.energy + 30);
                if (run_contract != LK_CONTRACT.Iron) player.hp = min(player.max_hp, player.hp + 2);
                player.armor = player.max_armor;
                lk_start_floor();
            }
            break;
    }
    lk_sound(_sound);
    if (mode == LK_MODE.Play && _action.kind != "portal") lk_save_checkpoint();
}

function lk_take_boon(_boon) {
    cell.shrine_used = true;
    var _old_cooldown = lk_skill_cooldown();
    array_push(player.boons, _boon);
    switch (_boon) {
        case LK_BOON.Armor: player.max_armor += 2; player.armor = player.max_armor; break;
        case LK_BOON.Health: player.max_hp += 2; player.hp = min(player.max_hp, player.hp + 3); break;
        case LK_BOON.Damage: player.damage_scale *= 1.25; break;
        case LK_BOON.Haste: player.haste *= 1.20; break;
        case LK_BOON.Energy: player.max_energy += 30; player.energy = player.max_energy; break;
        case LK_BOON.Speed: player.move_pace *= 1.15; break;
        case LK_BOON.Warm: player.traits[0] = true; break;
        case LK_BOON.Edge: player.traits[1] = true; break;
        case LK_BOON.Volley: player.traits[2] = true; break;
    }
    if (_boon == LK_BOON.Haste || _boon == LK_BOON.StillWick) {
        player.skill_wait = round(player.skill_wait * lk_skill_cooldown() / _old_cooldown);
    }
    mode = LK_MODE.Play;
    lk_sparks(240, 127, boons[_boon].tint, 24, 2);
    lk_sound(snd_clear);
    lk_save_checkpoint();
}
