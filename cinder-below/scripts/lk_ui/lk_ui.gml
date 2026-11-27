function lk_text(_label, _x, _y, _color = C_PAPER, _big = false) {
    var _step = _big ? 9 : 6;
    var _alpha = draw_get_alpha();
    _x = round(_x);
    _y = round(_y);
    for (var _i = 1; _i <= string_length(_label); _i++) {
        var _c = ord(string_char_at(_label, _i)) - 32;
        if (_c > 0 && _c < 96) {
            var _left = (_c mod 16) * 10;
            var _top = (floor(_c / 16) + (_big ? 6 : 0)) * 12;
            draw_sprite_part_ext(spr_font, 0, _left, _top, 10, 12, _x, _y, 1, 1, _color, _alpha);
        }
        _x += _step;
    }
}

function lk_text_center(_label, _x, _y, _color = C_PAPER, _big = false) {
    lk_text(_label, _x - string_length(_label) * (_big ? 9 : 6) * .5, _y, _color, _big);
}

function lk_text_right(_label, _x, _y, _color = C_PAPER) {
    lk_text(_label, _x - string_length(_label) * 6, _y, _color);
}

function lk_ornament(_x1, _y, _x2, _color) {
    lk_line(_x1 + 5, _y, _x2 - 5, _y, _color);
    lk_diamond(_x1, _y, 2, _color);
    lk_diamond(_x2, _y, 2, _color);
}

function lk_panel(_x1, _y1, _x2, _y2, _selected = false, _accent = C_GOLD) {
    lk_rect(_x1 + 2, _y1 + 3, _x2 + 2, _y2 + 3, C_INK);
    lk_rect(_x1, _y1, _x2, _y2, _selected ? $382933 : C_DEEP);
    lk_border(_x1, _y1, _x2, _y2, _selected ? _accent : C_EDGE);
    if (_selected) {
        lk_rect(_x1, _y1, _x1 + 5, _y1 + 1, _accent);
        lk_rect(_x2 - 5, _y2 - 1, _x2, _y2, _accent);
    }
}

function lk_button(_label, _x1, _yt, _x2, _hot) {
    var _yb = _yt + 24;
    lk_panel(_x1, _yt, _x2, _yb, _hot, C_GOLD);
    lk_text_center(_label, (_x1 + _x2) * .5, _yt + 6, _hot ? C_PAPER : C_MUTED);
    if (_hot) {
        lk_diamond(_x1 + 10, _yt + 12, 2, C_GOLD);
        lk_diamond(_x2 - 10, _yt + 12, 2, C_GOLD);
    }
}

function lk_draw_menu() {
    draw_sprite(spr_cover, 0, 0, 0);
    for (var _i = 0; _i < 21; _i++) {
        var _x = 271 + ((_i * 23 + floor(tick / (4 + _i mod 5))) mod 184);
        var _y = 62 + ((_i * 19 - floor(tick / 6) + 360000) mod 163);
        draw_set_alpha(.2 + .25 * abs(dsin(tick * 3 + _i * 25)));
        lk_rect(_x, _y, _x + (_i mod 4 == 0), _y, C_GOLD);
    }
    draw_set_alpha(1);
    if (mode == LK_MODE.Title) {
        lk_ornament(32, 43, 63, C_GOLD);
        draw_sprite(spr_wordmark, 0, 25, 47);
        lk_text("RELIGHT THE KEEP.", 32, 156, C_MUTED);
        if (checkpoint_available) {
            lk_button("CONTINUE RUN", 32, 181, 177, true);
            lk_button(pad >= 0 ? "X  NEW RUN" : "N  NEW RUN", 32, 209, 177, false);
        } else {
            lk_button("ENTER THE KEEP", 32, 181, 177, true);
            lk_text("ENTER OR CLICK TO BEGIN", 32, 213, C_MUTED);
        }
        gpu_set_blendmode(bm_add);
        lk_light(358, 168, 66, C_GOLD, .36 + dsin(tick * 5) * .07, 1.13);
        lk_light(267, 171, 26, C_GOLD, .25 + dsin(tick * 15) * .10);
        lk_light(434, 176, 26, C_GOLD, .28 + dsin(tick * 11) * .10);
        gpu_set_blendmode(bm_normal);
        lk_shadow(361, 194, 15);
        lk_actor(0, 0, 359, 193, 1, 2);
        lk_button(pad >= 0 ? "B  CONTRACTS" : "R  CONTRACTS", 337, 181, 447, true);
        lk_button("J  JOURNAL", 337, 209, 447, false);
        lk_ornament(32, 240, 448, C_EDGE);
        lk_text("M  " + (muted ? "UNMUTE" : "MUTE"), 32, 247, C_MUTED);
        lk_text("F11 FULLSCREEN", 128, 247, C_MUTED);
        lk_text("F10 " + (integer_scaling ? "INTEGER" : "FIT"), 232, 247, C_MUTED);
        if (best_floor > 0) lk_text_right("DEEPEST  " + string(best_floor) + " / " + string(array_length(stage_names)), 448, 247, C_MUTED);
        lk_text_right(LK_VERSION, 448, 258, C_MUTED);
        return;
    }

    draw_set_alpha(.78);
    lk_rect(0, 0, 479, 269, C_INK);
    draw_set_alpha(1);
    var _contract = contracts[chosen_contract];
    lk_ornament(95, 18, 185, C_EDGE);
    lk_text_center(_contract.name, 240, 12, _contract.tint);
    lk_ornament(295, 18, 385, C_EDGE);
    lk_text_center("CHOOSE A KEEPER", 240, 31, C_PAPER, true);
    if (hero_id == 0) {
        var _goal = "FELL MOSSJAW WITHOUT TAKING A HIT TO UNLOCK THE NAIL DRIVER KIT.";
        if (discoveries[LK_UNTOUCHED_ROOTS]) _goal = chosen_contract == LK_CONTRACT.Daily
            ? "NAIL DRIVER KIT UNLOCKED. DAILY USES THE ORIGINAL KIT." : "MOSSJAW MASTERY: NAIL DRIVER KIT UNLOCKED.";
        lk_text_center(_goal, 240, 51, C_GOLD);
    }
    for (var _i = 0; _i < array_length(heroes); _i++) {
        var _x = 36 + 103 * (_i mod 4);
        var _y = 70 + 64 * floor(_i / 4);
        var _hero = heroes[_i];
        var _active = _i == hero_id;
        lk_panel(_x, _y, _x + 99, _y + 59, _active, _hero.tint);
        lk_glow(_x + 17, _y + 29, 17, _hero.tint, _active ? .48 : .24);
        lk_shadow(_x + 16, _y + 47, 9);
        lk_hero_sprite(_i, _active && tick mod 80 > 71 ? 3 : 0, _x + 15, _y + 47, 1, 1.10);
        lk_text(_hero.name, _x + 32, _y + 8, _active ? C_PAPER : C_MUTED);
        lk_text(_hero.skill, _x + 32, _y + 21, _hero.tint);
        lk_text("HP" + string(_hero.hp) + "  ARM" + string(_hero.armor), _x + 32, _y + 34, C_MUTED);
        lk_text("PACE " + string_format(_hero.speed, 0, 1), _x + 32, _y + 46, C_MUTED);
    }
    var _keeper = heroes[hero_id];
    var _arms = lk_keeper_arms(hero_id, use_alt_loadout);
    lk_text_center(_keeper.note, 240, 199, C_PAPER);
    lk_text_center(weapons[_arms[0]].name + "  /  " + weapons[_arms[1]].name, 240, 211, C_MUTED);
    lk_text_center((pad >= 0 ? "Y" : "H") + (tour_next_run ? "  GUIDED TOUR ON" : "  GUIDED TOUR OFF"),
        240, 221, tour_next_run ? C_GOLD : C_MUTED);
    lk_button("DESCEND", 167, 232, 313, true);
    if (lk_keeper_has_alt_kit(hero_id)) {
        var _kit = use_alt_loadout ? "ORIGINAL KIT" : (hero_id == 0 ? "NAIL DRIVER" : "ALT KIT");
        lk_button((pad >= 0 ? "X " : "TAB ") + _kit, 321, 232, 445, true);
    }
    if (checkpoint_available) lk_text_center("STARTING OVER REPLACES YOUR SAVE", 240, 257, C_GOLD);
    lk_text(pad >= 0 ? "START BACK" : "ESC BACK", 36, 237, C_MUTED);
    lk_text(pad >= 0 ? "B CONTRACT" : "R CONTRACT", 36, 251, C_MUTED);
}

function lk_meter(_label, _x, _y, _width, _amount, _limit, _color, _segments, _refill = 0) {
    lk_text(_label, _x, _y - 4, _color);
    var _left = _x + 25;
    lk_rect(_left, _y, _left + _width, _y + 4, C_PANEL);
    if (_amount > 0) {
        lk_rect(_left, _y, _left + round(_width * clamp(_amount / _limit, 0, 1)), _y + 3, _color);
    }
    if (_segments) {
        for (var _i = 1; _i < _limit; _i++) {
            var _at = _left + round(_width * _i / _limit);
            lk_rect(_at, _y, _at, _y + 4, C_DEEP);
        }
    }
    if (_refill > 0 && _amount < _limit) {
        var _from = round(_width * _amount / _limit) + 1;
        var _to = round(_width * (_amount + 1) / _limit) - 1;
        var _fill = floor((_to - _from + 1) * _refill);
        if (_fill > 0) {
            lk_rect(_left + _from, _y + 3, _left + _from + _fill - 1, _y + 3, merge_color(C_PANEL, _color, .53));
        }
    }
}

function lk_map_visible_rooms() {
    var _visible = array_create(array_length(dungeon), false);
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        var _room = dungeon[_i];
        if (!_room.visited && _i != cell_index) continue;
        _visible[_i] = true;
        for (var _dir = 0; _dir < 4; _dir++) {
            var _next = _room.exits[_dir];
            if (_next >= 0) _visible[_next] = true;
        }
    }
    return _visible;
}

function lk_map_bounds(_visible) {
    var _bounds = {left: cell.gx, right: cell.gx, top: cell.gy, bottom: cell.gy};
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        if (!_visible[_i]) continue;
        var _room = dungeon[_i];
        _bounds.left = min(_bounds.left, _room.gx);
        _bounds.right = max(_bounds.right, _room.gx);
        _bounds.top = min(_bounds.top, _room.gy);
        _bounds.bottom = max(_bounds.bottom, _room.gy);
    }
    return _bounds;
}

function lk_map_pitch(_bounds, _width, _height) {
    return floor(min(_width / max(1, _bounds.right - _bounds.left),
        _height / max(1, _bounds.bottom - _bounds.top)));
}

function lk_minimap_layout() {
    // Keep the map inside the original top-right HUD space.
    var _left = 371;
    var _right = 469;
    var _top = 3;
    var _bottom = 28;
    var _padding = 3;
    var _width = _right - _left - _padding * 2;
    var _height = _bottom - _top - _padding * 2;
    var _visible = lk_map_visible_rooms();
    var _bounds = lk_map_bounds(_visible);
    var _pitch = lk_map_pitch(_bounds, _width, _height);
    // Focus on nearby rooms when the whole explored route would erase corridor gaps.
    var _minimum_pitch = 8;
    if (_pitch < _minimum_pitch) {
        var _columns = floor(_width / (2 * _minimum_pitch));
        var _rows = floor(_height / (2 * _minimum_pitch));
        for (var _i = 0; _i < array_length(dungeon); _i++) {
            var _room = dungeon[_i];
            _visible[_i] = _visible[_i] && abs(_room.gx - cell.gx) <= _columns && abs(_room.gy - cell.gy) <= _rows;
        }
        _bounds = lk_map_bounds(_visible);
        _pitch = lk_map_pitch(_bounds, _width, _height);
    }
    _pitch = min(10, _pitch);
    return {
        visible: _visible,
        pitch: _pitch,
        radius: floor(_pitch * .35),
        x: round((_left + _right - (_bounds.left + _bounds.right) * _pitch) * .5),
        y: round((_top + _bottom - (_bounds.top + _bounds.bottom) * _pitch) * .5)
    };
}

function lk_minimap() {
    var _layout = lk_minimap_layout();
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        if (!_layout.visible[_i]) continue;
        var _room = dungeon[_i];
        var _x = _layout.x + _room.gx * _layout.pitch;
        var _y = _layout.y + _room.gy * _layout.pitch;
        for (var _dir = 0; _dir < 4; _dir++) {
            var _next = _room.exits[_dir];
            if (_next <= _i || !_layout.visible[_next]) continue;
            var _target = dungeon[_next];
            var _locked = !lk_route_entry_available(_room) || !lk_route_entry_available(_target);
            var _active = _i == cell_index || _next == cell_index;
            var _tint = _locked ? C_GOLD : (_active ? C_TEAL : C_MUTED);
            var _tx = _layout.x + _target.gx * _layout.pitch;
            var _ty = _layout.y + _target.gy * _layout.pitch;
            lk_rect(min(_x, _tx), min(_y, _ty), max(_x, _tx) + (_x == _tx), max(_y, _ty) + (_y == _ty), _tint);
        }
    }
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        if (!_layout.visible[_i]) continue;
        var _room = dungeon[_i];
        var _x = _layout.x + _room.gx * _layout.pitch;
        var _y = _layout.y + _room.gy * _layout.pitch;
        var _plain = lk_route_role(_room) == LK_ROUTE_ROOM.None && (_room.kind == LK_ROOM.Fight || _room.kind == LK_ROOM.Landing);
        var _color = _plain ? (_room.visited && !_room.clear ? C_PINK : C_MUTED) : lk_route_room_color(_room);
        var _current = _i == cell_index;
        var _r = _layout.radius;
        lk_rect(_x - _r, _y - _r, _x + _r, _y + _r, _room.visited ? merge_color(C_DEEP, _color, .52) : C_INK);
        lk_border(_x - _r, _y - _r, _x + _r, _y + _r, _current ? C_TEAL : _color);
        if (_current) lk_diamond(_x, _y, _r - 1, C_PAPER);
    }
}

function lk_draw_hud() {
    lk_rect(0, 0, 479, 30, C_INK);
    lk_line(0, 30, 479, 30, C_EDGE);
    lk_meter("HP", 12, 5, 53, player.hp, player.max_hp, C_PINK, true);
    var _armor_refill = !cell.clear && lk_combat_armor_enabled()
        ? clamp(1 - player.regen / armor_repair_span, 0, 1) : 0;
    lk_meter("ARM", 12, 15, 53, player.armor, player.max_armor, C_TEAL, true, _armor_refill);
    lk_meter("EN", 102, 5, 41, player.energy, player.max_energy, C_BLUE, false);
    lk_loot_icon(LK_LOOT.Coin, 106, 18, 0);
    lk_text(string(player.coins), 115, 13, C_GOLD);
    lk_text_center(lk_route_stage_name(), 250, 3, C_PAPER, true);
    var _depth = run_contract == LK_CONTRACT.Endless ? "DEPTH " + string(lk_run_depth()) : "DEPTH "
        + string(depth_no + 1) + " / " + string(array_length(stage_names));
    lk_text_center(_depth, 250, 19, C_MUTED);
    lk_minimap();

    lk_rect(0, 246, 479, 269, C_INK);
    lk_line(0, 246, 479, 246, C_EDGE);
    for (var _i = 0; _i < 2; _i++) {
        var _x = 8 + _i * 105;
        var _w = weapons[player.arms[_i]];
        var _active = _i == player.slot;
        lk_rect(_x, 250, _x + 101, 266, _active ? C_PANEL : C_DEEP);
        if (_active) lk_line(_x, 250, _x + 101, 250, _w.color);
        lk_text(string(_i + 1), _x + 3, 253, _active ? _w.color : C_MUTED);
        var _backup = _active && lk_active_weapon() != player.arms[_i];
        var _name = string_length(_w.name) <= 14 ? _w.name : string_copy(_w.name, 1, 13) + ".";
        lk_text(_backup ? "BACKUP PISTOL" : _name, _x + 12, 252, _backup ? C_GOLD : (_active ? C_PAPER : C_MUTED));
        if (player.attachments[_i] > 0) lk_rect(_x + 12, 263, _x + 20, 263, fittings[player.attachments[_i]].tint);
        for (var _j = 0; _j < player.temper[_i]; _j++) lk_diamond(_x + 91 - _j * 6, 263, 2, C_GOLD);
    }
    var _skill = heroes[hero_id].skill;
    var _skill_info = (pad >= 0 ? "LB " : "Q ") + _skill;
    var _skill_tint = heroes[hero_id].tint;
    if (player.skill_wait > 0) _skill_info += " " + string(ceil(player.skill_wait / 60)) + "S";
    lk_text(_skill_info, 228, 251, player.skill_wait > 0 ? C_MUTED : _skill_tint);
    var _ready = clamp(1 - player.skill_wait / lk_skill_cooldown(), 0, 1);
    lk_rect(228, 263, 333, 264, C_PANEL);
    if (_ready > 0) lk_rect(228, 263, 228 + floor(_ready * 105), 264, _skill_tint);
    lk_text_right(pad >= 0 ? "START  PAUSE" : "ESC  PAUSE", 468, 253, C_MUTED);

    if (boss_intro > 0) {
        var _tint = lk_theme_tint(floor_no);
        lk_panel(100, 148, 380, 213, true, _tint);
        lk_text_center("GUARDIAN " + string(depth_no + 1) + " / " + string(array_length(boss_names)),
            240, 153, _tint);
        lk_text_center(lk_guardian_name(cell), 240, 167, C_PAPER, true);
        lk_ornament(130, 184, 350, _tint);
        lk_text_center(lk_guardian_title(cell), 240, 190, C_PAPER);
        if (boss_intro <= LK_BOSS_INTRO - 24) {
            lk_text_center(pad >= 0 ? "A TO SKIP" : "E TO SKIP", 240, 218, C_MUTED);
        }
        return;
    }
    var _boss_room = !cell.clear && cell.kind == LK_ROOM.Boss;
    if (_boss_room) {
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _boss = enemies[_i];
            if (_boss.kind != LK_ENEMY.Boss || !_boss.alive) continue;
            lk_rect(55, 35, 210, 54, C_INK);
            lk_text_center(lk_guardian_name(cell), 132, 36, _boss.color);
            lk_rect(60, 48, 204, 51, C_PANEL);
            lk_rect(60, 48, 60 + floor(144 * max(0, _boss.hp / _boss.max_hp)), 50, _boss.color);
            var _ability = lk_boss_ability(_boss);
            var _anchors = floor_no == 4 && _boss.final_phase == 1 ? lk_crown_anchors() : 0;
            if (_ability != "") {
                lk_rect(55, 54, 210, 66, C_INK);
                lk_text_center(_ability, 132, 54, C_GOLD);
            }
            if (_anchors > 0) {
                lk_rect(55, 66, 210, 77, C_INK);
                lk_text_center("SHIELDED BY " + string(_anchors) + (_anchors == 1 ? " ANCHOR" : " ANCHORS"), 132, 67, C_GOLD);
            }
            break;
        }
    }
    if (seals_left > 0) {
        lk_rect(63, 35, 205, 52, C_INK);
        lk_line(63, 51, 205, 51, C_LILAC);
        lk_text_center("CLOSE SEALS " + string(array_length(room_seals) - seals_left) + " / 2", 134, 38, C_LILAC);
    } else if (banner_time > 0) {
        draw_set_alpha(min(1, banner_time / 20));
        var _w = max(104, string_length(banner) * 7 + 20);
        var _banner_x = _boss_room ? 346 : 134;
        lk_rect(_banner_x - _w / 2, 35, _banner_x + _w / 2, 52, C_INK);
        lk_line(_banner_x - _w / 2, 51, _banner_x + _w / 2, 51, C_EDGE);
        lk_text_center(banner, _banner_x, 38, cell.clear ? C_GOLD : C_PAPER, false);
        if (!cell.clear && cell.kind == LK_ROOM.Fight) {
            var _hint = "";
            if (cell.encounter == LK_FIGHT.ShieldLine) _hint = "FLANK THE BULWARK";
            if (cell.encounter == LK_FIGHT.BroodNest) _hint = "DESTROY THE BROOD HUSK";
            if (cell.encounter == LK_FIGHT.RelayGuard) _hint = "STOP THE BELLKEEPER";
            if (cell.encounter == LK_FIGHT.HeatWorks) _hint = "KEEP CLEAR OF HOT GROUND";
            if (cell.encounter == LK_FIGHT.ThreadedCrossing) _hint = "BREAK THE LINKS";
            if (cell.encounter == LK_FIGHT.FloodPulse) _hint = "MOVE BETWEEN THE LANES";
            if (_hint != "") {
                var _tip_width = string_length(_hint) * 6 + 12;
                lk_rect(134 - _tip_width / 2, 52, 134 + _tip_width / 2, 64, C_INK);
                lk_text_center(_hint, 134, 53, C_MUTED);
            }
        }
        draw_set_alpha(1);
    }
    var _tour = lk_tour_prompt();
    var _action = lk_interaction();
    if (!is_undefined(_action)) {
        var _text = (pad >= 0 ? "A" : "E") + "  " + _action.label;
        var _detail = variable_struct_exists(_action, "detail") ? _action.detail : "";
        var _w = max(string_length(_text), string_length(_detail)) * 6 + 14;
        var _height = _detail == "" ? 12 : 24;
        var _x = clamp(round(player.px), _w / 2 + 9, 471 - _w / 2);
        var _y = clamp(round(player.py) + 8, 57, (_tour == "" ? 241 : 230) - _height);
        lk_rect(_x - _w / 2, _y, _x + _w / 2, _y + _height, C_INK);
        lk_text_center(_text, _x, _y + 1, C_GOLD);
        if (_detail != "") lk_text_center(_detail, _x, _y + 12, C_PAPER);
    } else if (cell.clear) lk_draw_route_hint();
    if (_tour != "") lk_draw_tour(_tour);
    if (!variable_struct_exists(player, "tour") && cell.kind == LK_ROOM.Landing && depth_no == 0 && world_tick < 520) {
        var _tip = pad >= 0 ? "LEFT STICK MOVE   RT FIRE   LB SKILL   X SWAP"
            : "WASD MOVE   SPACE AUTO-AIM   LMB AIM/FIRE   TAB SWAP";
        lk_text_center(_tip, 240, 198, C_PAPER);
    }
}

function lk_draw_route_hint() {
    var _door = -1;
    var _distance = 43;
    for (var _dir = 0; _dir < 4; _dir++) {
        var _next = cell.exits[_dir];
        if (_next < 0 || lk_route_role(dungeon[_next]) == LK_ROUTE_ROOM.None) continue;
        var _x = [426, 240, 54, 240][_dir];
        var _y = [143, 222, 143, 65][_dir];
        var _range = point_distance(player.px, player.py, _x, _y);
        if (_range >= _distance) continue;
        _distance = _range;
        _door = _dir;
    }
    if (_door < 0) return;
    var _label = lk_route_door_hint(_door);
    var _half = string_length(_label) * 3 + 3;
    var _x = [410 - _half, 240, 72 + _half, 240][_door];
    var _y = [138, 206, 138, 68][_door];
    draw_set_alpha(.74);
    lk_rect(_x - _half, _y, _x + _half, _y + 11, C_INK);
    draw_set_alpha(1);
    var _tint = lk_route_door_available(_door) ? lk_route_room_color(dungeon[cell.exits[_door]]) : C_MUTED;
    lk_text_center(_label, _x, _y, _tint);
}

function lk_pause_inventory(_relic, _top) {
    var _catalog = _relic ? relic_catalog : boons;
    var _hover = undefined;
    var _count = 0;
    lk_text(_relic ? "RELICS" : "BOONS", 199, _top - 13, _relic ? C_LILAC : C_GOLD);
    for (var _i = 0; _i < array_length(_catalog); _i++) {
        var _rank = lk_reward_rank(_relic, _i);
        if (_rank == 0) continue;
        var _item = _catalog[_i];
        var _x = 199 + (_count mod 4) * 56;
        var _y = _top + floor(_count / 4) * 14;
        var _active = pointer_inside && pointer_x >= _x && pointer_x <= _x + 53
            && pointer_y >= _y && pointer_y <= _y + 13;
        lk_panel(_x, _y, _x + 53, _y + 13, _active, _item.tint);
        lk_text(_item.short, _x + 3, _y + 1, _item.tint);
        if (_item.max_rank > 1) lk_text_right(string(_rank), _x + 51, _y + 1, C_PAPER);
        if (_active) {
            var _label = _item.name + (_item.max_rank > 1 ? " / RANK " + string(_rank) : "");
            var _note = _relic && _i == LK_RELIC.Knot && player.knot_spent
                ? "THE REVIVE HAS ALREADY BEEN USED." : lk_reward_note(_item, _rank);
            if (!_relic && _i <= LK_BOON.Speed && _rank > 1) _note = "EACH RANK: " + _note;
            _hover = {label: _label, note: _note, tint: _item.tint};
        }
        _count += 1;
    }
    if (_count == 0) lk_text("NONE YET", 199, _top + 1, C_MUTED);
    return _hover;
}

function lk_draw_pause() {
    lk_panel(40, 31, 440, 242, true, C_GOLD);
    lk_text_center("PAUSED", 240, 39, C_PAPER, true);
    lk_ornament(55, 58, 425, C_EDGE);
    lk_line(188, 68, 188, 229, C_EDGE);
    lk_text("ENTER / ESC RESUME", 55, 68, C_GOLD);
    var _save_hint = cell.clear ? (pad >= 0 ? "Y SAVE AND EXIT" : "S SAVE AND EXIT") : "CONTINUE FROM LAST CLEAR";
    lk_text(_save_hint, 55, 82, cell.clear ? C_GOLD : C_MUTED);
    lk_text("Q RETURN TO TITLE", 55, 96, C_MUTED);
    lk_text("M " + (muted ? "UNMUTE" : "MUTE"), 55, 110, C_MUTED);
    lk_text(contracts[run_contract].name, 55, 127, contracts[run_contract].tint);
    lk_text("WEAPON UPGRADES", 55, 146, C_GOLD);
    var _hover = lk_pause_inventory(true, 84);
    var _boon_hover = lk_pause_inventory(false, 141);
    if (!is_undefined(_boon_hover)) _hover = _boon_hover;
    for (var _i = 0; _i < 2; _i++) {
        var _id = player.arms[_i];
        var _weapon = weapons[_id];
        var _rank = player.temper[_i];
        var _y = 159 + _i * 17;
        var _active = pointer_inside && pointer_x >= 54 && pointer_x <= 177
            && pointer_y >= _y && pointer_y <= _y + 14;
        lk_panel(54, _y, 177, _y + 14, _active, _weapon.color);
        var _name = string_length(_weapon.name) <= 15 ? _weapon.name : string_copy(_weapon.name, 1, 14) + ".";
        lk_text(string(_i + 1) + " " + _name, 57, _y + 2, _weapon.color);
        if (_rank > 0) lk_text_right("+" + string(_rank), 174, _y + 2, C_GOLD);
        var _fit = player.attachments[_i];
        if (_fit > 0) lk_rect(56, _y + 13, 72, _y + 13, fittings[_fit].tint);
        if (_active) {
            _hover = {label: _weapon.name + (_fit > 0 ? " / " + fittings[_fit].name : " / TEMPER " + string(_rank)),
                note: _fit > 0 ? fittings[_fit].note : lk_weapon_details(_id, _rank, true) + ".",
                tint: _weapon.color};
        }
    }
    var _fuse = lk_fusion_index();
    if (_fuse >= 0) {
        lk_text("FORGE RECIPE READY", 55, 197, C_LILAC);
        lk_text(weapons[LK_FUSION_FIRST + _fuse].name, 55, 209, C_PAPER);
    }
    lk_text("F11 SCREEN   F10 " + (integer_scaling ? "INT" : "FIT"), 55, 208, C_MUTED);
    lk_text(LK_VERSION, 55, 221, C_MUTED);
    lk_panel(199, 201, 427, 236);
    if (is_undefined(_hover)) {
        lk_text_center("HOVER OVER AN ITEM FOR DETAILS", 313, 211, C_MUTED);
    } else {
        lk_text_center(_hover.label, 313, 202, _hover.tint);
        lk_text_wrap(_hover.note, 313, 213, 36, C_PAPER);
    }
}

function lk_draw_overlay() {
    draw_set_alpha(.73);
    lk_rect(0, 0, 479, 269, C_INK);
    draw_set_alpha(1);
    if (mode == LK_MODE.Pause) {
        lk_draw_pause();
        return;
    }
    if (mode == LK_MODE.Boon) {
        lk_panel(49, 61, 431, 210, true, C_LILAC);
        var _heading = choose_relic ? "CLAIM A RELIC" : (cell.kind == LK_ROOM.SparkShrine ? "CHOOSE A SPARK BOON" : "CHOOSE A BOON");
        lk_text_center(_heading, 240, 77, C_PAPER, true);
        for (var _i = 0; _i < array_length(boon_options); _i++) {
            var _option = boon_options[_i];
            var _boon = choose_relic ? relic_catalog[_option] : boons[_option];
            var _rank = lk_reward_rank(choose_relic, _option);
            var _x = 61 + _i * 187;
            lk_panel(_x, 111, _x + 171, 178, _i == selected, _boon.tint);
            lk_text(_rank > 0 ? "RANK " + string(_rank + 1) : "NEW", _x + 7, 115, C_MUTED);
            lk_glow(_x + 86, 127, 18, _boon.tint, .36);
            lk_diamond(_x + 86, 127, 6, _boon.tint);
            lk_diamond(_x + 86, 127, 2, C_PAPER);
            lk_text_center(_boon.name, _x + 86, 137, _boon.tint);
            lk_text_wrap(lk_reward_note(_boon, _rank + 1), _x + 86, 151, 26, C_PAPER);
        }
        lk_text_center("A / D  SELECT     ENTER  TAKE", 240, 189, C_MUTED);
        return;
    }
    var _win = mode == LK_MODE.Won;
    var _color = _win ? C_GOLD : C_PINK;
    lk_panel(104, 55, 376, 217, true, _color);
    lk_text_center(_win ? "THE KEEP IS LIT" : "THE LANTERN FELL", 240, 77, _color, true);
    lk_ornament(147, 101, 333, C_EDGE);
    lk_text_center("DEPTH " + string(lk_run_depth()) + "  " + contracts[run_contract].name, 240, 112, C_PAPER);
    lk_text_center(string(rooms_cleared) + " ROOMS CLEARED   " + string(kills) + " DEFEATED", 240, 130, C_MUTED);
    lk_button("ENTER  NEW RUN", 155, 151, 325, true);
    lk_text_center("ESC  TITLE", 240, 190, C_MUTED);
}

function lk_text_wrap(_note, _x, _y, _limit, _color) {
    var _words = string_split(_note, " ");
    var _line = "";
    for (var _i = 0; _i < array_length(_words); _i++) {
        var _word = _words[_i];
        if (string_length(_line) + string_length(_word) + 1 > _limit) {
            lk_text_center(_line, _x, _y, _color);
            _line = _word;
            _y += 10;
        } else {
            _line += (_line == "" ? "" : " ") + _word;
        }
    }
    lk_text_center(_line, _x, _y, _color);
}

function lk_journal_count() {
    switch (journal_tab) {
        case 0: return array_length(weapons);
        case 1: return array_length(relic_catalog);
        case 2: return array_length(fusion_recipes);
        case 3: return array_length(discoveries);
    }
    return 1;
}

function lk_journal_step() {
    if (back_pressed || keyboard_check_pressed(ord("J"))) {
        mode = LK_MODE.Title;
        return;
    }
    if (swap_pressed || menu_vert) {
        journal_tab = (journal_tab + (menu_up ? 4 : 1)) mod 5;
        journal_item = 0;
        lk_sound(snd_click);
    }
    if (pointer_click && pointer_y >= 59 && pointer_y < 79 && pointer_x >= 47 && pointer_x < 434) {
        journal_tab = clamp(floor((pointer_x - 47) / 77), 0, 4);
        journal_item = 0;
        lk_sound(snd_click);
    }
    var _limit = lk_journal_count();
    if (menu_left || menu_right) journal_item = (journal_item + (menu_left ? _limit - 1 : 1)) mod _limit;
    if (!pointer_click || pointer_x < 49 || pointer_x >= 431 || journal_tab == 4) return;
    if (journal_tab == 0 && pointer_y >= 167 && pointer_y <= 188) {
        if (pointer_x >= 172 && pointer_x <= 308) journal_item = journal_item < 21 ? 21 : 0;
    } else if (journal_tab <= 1 && pointer_y >= 88 && pointer_y < 166) {
        var _item = 21 * floor(journal_item / 21) + 7 * floor((pointer_y - 88) / 26)
            + min(6, floor((pointer_x - 49) / 54));
        if (_item < _limit) journal_item = _item;
    } else if (journal_tab == 2 && pointer_y >= 88 && pointer_y < 193) {
        journal_item = 2 * floor((pointer_y - 88) / 35) + (pointer_x >= 240);
    } else if (journal_tab == 3 && pointer_y >= 88 && pointer_y < 167) {
        journal_item = 4 * floor((pointer_y - 88) / 20) + min(3, floor((pointer_x - 49) / 95));
    }
}

function lk_draw_journal_recipes() {
    for (var _i = 0; _i < array_length(fusion_recipes); _i++) {
        var _x = 49 + 193 * (_i mod 2);
        var _y = 88 + 35 * floor(_i / 2);
        var _result = LK_FUSION_FIRST + _i;
        var _tint = weapons[_result].color;
        var _pair = fusion_recipes[_i];
        lk_panel(_x, _y, _x + 187, _y + 31, _i == journal_item, _tint);
        lk_weapon_draw(_result, _x + 12, _y + 17, 18, .80);
        lk_text(weapons[_result].name, _x + 36, _y + 3, _tint);
        lk_text(weapons[_pair[0]].name, _x + 36, _y + 13, C_MUTED);
        lk_text("+ " + weapons[_pair[1]].name, _x + 36, _y + 22, C_MUTED);
    }
    var _found = discoveries[6 + journal_item];
    lk_text_center(lk_weapon_details(LK_FUSION_FIRST + journal_item), 240, 198, C_PAPER);
    lk_text_center("HOLD BOTH AT A FORGE. FUSE FOR 9G.", 240, 210, _found ? C_GOLD : C_MUTED);
}

function lk_draw_journal_discoveries() {
    for (var _i = 0; _i < array_length(discoveries); _i++) {
        var _x = 49 + 95 * (_i mod 4);
        var _y = 88 + floor(_i / 4) * 20;
        var _found = discoveries[_i];
        var _tint = _i >= 12 ? C_GOLD : (_i >= 6 ? C_LILAC : C_TEAL);
        lk_panel(_x, _y, _x + 91, _y + 16, _i == journal_item, _found ? _tint : C_MUTED);
        lk_diamond(_x + 11, _y + 8, 3, _found ? _tint : C_EDGE);
        lk_text(_i >= 12 ? "MASTERY" : (_i >= 6 ? "FUSION" : "ROUTE"), _x + 21, _y + 3, _found ? _tint : C_MUTED);
    }
    var _entry = discovery_catalog[journal_item];
    lk_text_center(_entry[0], 240, 174, discoveries[journal_item] ? C_GOLD : C_MUTED);
    lk_text_center(_entry[1], 240, 187, C_PAPER);
    var _unlock = [
        "NAIL DRIVER BLUEPRINT", "", "HOLLOW BELL BLUEPRINT", "",
        "CINDER THREAD BLUEPRINT / ALCHEMIST KIT", "GRAVEHOOK BLUEPRINT / TIDECALLER KIT",
        "FRUGAL FORGE MODIFIER", "SEEP FLASK BLUEPRINT / UNSTABLE ARSENAL MODIFIER", "",
        "COPPER KITE BLUEPRINT", "", "", "WARDEN'S NAIL DRIVER KIT / BRITTLE WARD MODIFIER",
        "SPLIT LANTERN BLUEPRINT / OUTRIDER KIT / DEEP OMEN MODIFIER", "SILTCASTER BLUEPRINT", ""
    ][journal_item];
    if (_unlock != "") lk_text_center(_unlock, 240, 203, discoveries[journal_item] ? C_GOLD : C_MUTED);
}

function lk_draw_journal() {
    draw_sprite(spr_cover, 0, 0, 0);
    draw_set_alpha(.81);
    lk_rect(0, 0, 479, 269, C_INK);
    draw_set_alpha(1);
    lk_panel(35, 18, 445, 250, true);
    lk_text_center("KEEPER'S JOURNAL", 240, 29, C_PAPER, true);
    var _tabs = ["ARMORY", "RELICS", "RECIPES", "SECRETS", "RECORDS"];
    for (var _i = 0; _i < array_length(_tabs); _i++) {
        var _x = 47 + _i * 77;
        lk_panel(_x, 58, _x + 74, 79, _i == journal_tab, C_GOLD);
        lk_text_center(_tabs[_i], _x + 37, 63, _i == journal_tab ? C_GOLD : C_MUTED);
    }
    if (journal_tab < 2) {
        var _arms = journal_tab == 0;
        var _flags = _arms ? weapon_found : relic_found;
        var _page = floor(journal_item / 21);
        var _start = _page * 21;
        var _count = 0;
        for (var _i = 0; _i < array_length(_flags); _i++) if (_flags[_i]) _count += 1;
        for (var _i = _start; _i < min(_start + 21, array_length(_flags)); _i++) {
            var _local = _i - _start;
            var _x = 49 + (_local mod 7) * 54;
            var _y = 88 + floor(_local / 7) * 26;
            var _tint = _arms ? weapons[_i].color : relic_catalog[_i].tint;
            lk_panel(_x, _y, _x + 49, _y + 22, _i == journal_item, _flags[_i] ? _tint : C_MUTED);
            if (_flags[_i]) {
                if (_arms) lk_weapon_draw(_i, _x + 19, _y + 12, 15, 1);
                else {
                    lk_diamond(_x + 24, _y + 11, 5, _tint);
                    lk_diamond(_x + 24, _y + 11, 2, C_PAPER);
                }
            } else {
                lk_diamond(_x + 24, _y + 11, 3, C_EDGE);
            }
        }
        var _label = _flags[journal_item] ? (_arms ? weapons[journal_item].name : relic_catalog[journal_item].name)
            : "UNDISCOVERED";
        var _hint = _arms && journal_item >= LK_FUSION_FIRST ? "COMBINE ITS INGREDIENTS AT A FORGE." : "LOOK FOR IT IN THE KEEP.";
        var _note = _flags[journal_item] ? (_arms ? lk_weapon_details(journal_item) : relic_catalog[journal_item].note) : _hint;
        if (_arms) {
            lk_panel(172, 167, 308, 188, false, C_EDGE);
            lk_text_center("<  PAGE " + string(_page + 1) + " / 2  >", 240, 172, C_GOLD);
        }
        lk_text_center(_label, 240, 199, C_PAPER);
        lk_text_center(_note, 240, 212, C_MUTED);
        lk_text_right(string(_count) + " / " + string(array_length(_flags)), 429, 232, C_GOLD);
    } else if (journal_tab == 2) lk_draw_journal_recipes();
    else if (journal_tab == 3) lk_draw_journal_discoveries();
    else {
        lk_text_center("RUNS STARTED   " + string(runs_started), 240, 100, C_PAPER);
        lk_text_center("DEEPEST STAGE  " + string(best_floor), 240, 126, C_PAPER);
        lk_text_center("CLEARS         " + string(wins), 240, 152, C_GOLD);
        lk_text_center("FOES DEFEATED  " + string(total_kills), 240, 178, C_PAPER);
    }
    lk_text("ESC BACK", 49, 232, C_MUTED);
    lk_text_center("TAB CHANGE SECTION", 240, 232, C_MUTED);
}
