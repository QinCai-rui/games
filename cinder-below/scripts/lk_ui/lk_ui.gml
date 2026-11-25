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
    lk_ornament(121, 28, 359, C_EDGE);
    lk_text_center("CHOOSE A KEEPER", 240, 40, C_PAPER, true);
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
    lk_text_center(_keeper.note, 240, 199, C_PAPER);
    lk_text_center(weapons[_keeper.arms[0]].name + "  /  " + weapons[_keeper.arms[1]].name, 240, 211, C_MUTED);
    lk_button("DESCEND", 167, 232, 313, true);
    if (checkpoint_available) lk_text_center("STARTING OVER REPLACES YOUR SAVE", 240, 257, C_GOLD);
    lk_text("ESC BACK", 36, 239, C_MUTED);
    lk_text("R CONTRACT", 36, 251, C_MUTED);
    lk_text_right(contracts[chosen_contract].name, 445, 240, contracts[chosen_contract].tint);
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

function lk_minimap() {
    var _bx = 420;
    var _by = 16;
    var _min_x = 0;
    var _max_x = 0;
    var _min_y = 0;
    var _max_y = 0;
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        var _node = dungeon[_i];
        _min_x = min(_min_x, _node.gx);
        _max_x = max(_max_x, _node.gx);
        _min_y = min(_min_y, _node.gy);
        _max_y = max(_max_y, _node.gy);
    }
    var _step = min(9, floor(23 / max(1, _max_y - _min_y)));
    _bx -= (_min_x + _max_x) * _step * .5;
    _by -= (_min_y + _max_y) * _step * .5;
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        var _node = dungeon[_i];
        if (!_node.visited) continue;
        var _x = round(_bx + _node.gx * _step);
        var _y = round(_by + _node.gy * _step);
        for (var _j = 0; _j < 4; _j++) {
            var _target = _node.exits[_j];
            if (_target < 0) continue;
            var _n = dungeon[_target];
            var _tx = round(_bx + _n.gx * _step);
            var _ty = round(_by + _n.gy * _step);
            lk_line(_x, _y, _tx, _ty, C_EDGE);
            if (!_n.visited) {
                var _hint = lk_is_waystation(_n.kind) || _n.kind == LK_ROOM.Duel ? lk_room_color(_n.kind) : C_EDGE;
                lk_rect(_tx - 1, _ty - 1, _tx + 1, _ty + 1, _hint);
            }
        }
    }
    for (var _i = 0; _i < array_length(dungeon); _i++) {
        var _n = dungeon[_i];
        if (!_n.visited) continue;
        var _x = round(_bx + _n.gx * _step);
        var _y = round(_by + _n.gy * _step);
        var _color = _n.kind == LK_ROOM.Fight || _n.kind == LK_ROOM.Landing
            ? (!_n.clear ? C_PINK : C_MUTED) : lk_room_color(_n.kind);
        if (_i == cell_index) _color = C_TEAL;
        lk_rect(_x - 2, _y - 2, _x + 2, _y + 2, _color);
        if (_i == cell_index) lk_rect(_x, _y, _x, _y, C_PAPER);
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
    lk_text_center(stage_names[depth_no], 250, 3, C_PAPER, true);
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
        lk_text(_backup ? "BACKUP PISTOL" : _w.name, _x + 12, 252, _backup ? C_GOLD : (_active ? C_PAPER : C_MUTED));
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
        lk_text_center(boss_names[depth_no], 240, 167, C_PAPER, true);
        lk_ornament(130, 184, 350, _tint);
        lk_text_center(boss_titles[depth_no], 240, 190, C_PAPER);
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
            lk_text_center(boss_names[depth_no], 132, 36, _boss.color);
            lk_rect(60, 48, 204, 51, C_PANEL);
            lk_rect(60, 48, 60 + floor(144 * max(0, _boss.hp / _boss.max_hp)), 50, _boss.color);
            var _ability = lk_boss_ability(_boss);
            if (_ability != "") {
                lk_rect(55, 54, 210, 66, C_INK);
                lk_text_center(_ability, 132, 54, C_GOLD);
            }
            break;
        }
    }
    if (banner_time > 0) {
        draw_set_alpha(min(1, banner_time / 20));
        var _w = max(104, string_length(banner) * 7 + 20);
        var _banner_x = _boss_room ? 346 : 134;
        lk_rect(_banner_x - _w / 2, 35, _banner_x + _w / 2, 52, C_INK);
        lk_line(_banner_x - _w / 2, 51, _banner_x + _w / 2, 51, C_EDGE);
        lk_text_center(banner, _banner_x, 38, cell.clear ? C_GOLD : C_PAPER, false);
        draw_set_alpha(1);
    }
    var _action = lk_interaction();
    if (!is_undefined(_action)) {
        var _text = (pad >= 0 ? "A" : "E") + "  " + _action.label;
        var _detail = variable_struct_exists(_action, "detail") ? _action.detail : "";
        var _w = max(string_length(_text), string_length(_detail)) * 6 + 14;
        var _height = _detail == "" ? 12 : 24;
        var _x = clamp(round(player.px), _w / 2 + 9, 471 - _w / 2);
        var _y = clamp(round(player.py) + 8, 57, 241 - _height);
        lk_rect(_x - _w / 2, _y, _x + _w / 2, _y + _height, C_INK);
        lk_text_center(_text, _x, _y + 1, C_GOLD);
        if (_detail != "") lk_text_center(_detail, _x, _y + 12, C_PAPER);
    }
    if (cell.kind == LK_ROOM.Landing && depth_no == 0 && world_tick < 520) {
        var _tip = pad >= 0 ? "LEFT STICK MOVE   RT FIRE   LB SKILL   X SWAP"
            : "WASD MOVE   SPACE AUTO-AIM   LMB AIM/FIRE   TAB SWAP";
        lk_text_center(_tip, 240, 198, C_PAPER);
    }
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
        lk_text(string(_i + 1) + " " + _weapon.name, 57, _y + 2, _weapon.color);
        if (_rank > 0) lk_text_right("+" + string(_rank), 174, _y + 2, C_GOLD);
        if (_active) {
            _hover = {label: _weapon.name + " / TEMPER " + string(_rank) + " OF 3",
                note: lk_weapon_details(_id, _rank, true) + ". FORGES ADD 20% BASE DAMAGE PER LEVEL.",
                tint: _weapon.color};
        }
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

function lk_journal_step() {
    if (back_pressed || keyboard_check_pressed(ord("J"))) {
        mode = LK_MODE.Title;
        return;
    }
    if (swap_pressed || menu_vert) {
        journal_tab = (journal_tab + 1) mod 3;
        journal_item = 0;
        lk_sound(snd_click);
    }
    if (pointer_click && pointer_y >= 59 && pointer_y < 79 && pointer_x >= 47 && pointer_x < 434) {
        journal_tab = clamp(floor((pointer_x - 47) / 129), 0, 2);
        journal_item = 0;
        lk_sound(snd_click);
    }
    var _limit = journal_tab == 0 ? array_length(weapons) : array_length(relic_catalog);
    if (menu_left || menu_right) journal_item = (journal_item + (menu_left ? _limit - 1 : 1)) mod _limit;
    if (journal_tab < 2 && pointer_click && pointer_y >= 88 && pointer_y < 193
        && pointer_x >= 49 && pointer_x < 433) {
        var _item = 6 * floor((pointer_y - 88) / 26) + floor((pointer_x - 49) / 64);
        if (_item < _limit) journal_item = _item;
    }
}

function lk_draw_journal() {
    draw_sprite(spr_cover, 0, 0, 0);
    draw_set_alpha(.81);
    lk_rect(0, 0, 479, 269, C_INK);
    draw_set_alpha(1);
    lk_panel(35, 18, 445, 250, true);
    lk_text_center("KEEPER'S JOURNAL", 240, 29, C_PAPER, true);
    var _tabs = ["ARMORY", "RELICS", "RECORDS"];
    for (var _i = 0; _i < 3; _i++) {
        var _x = 47 + _i * 129;
        lk_panel(_x, 58, _x + 124, 79, _i == journal_tab, C_GOLD);
        lk_text_center(_tabs[_i], _x + 62, 63, _i == journal_tab ? C_GOLD : C_MUTED);
    }
    if (journal_tab < 2) {
        var _arms = journal_tab == 0;
        var _flags = _arms ? weapon_found : relic_found;
        var _count = 0;
        for (var _i = 0; _i < array_length(_flags); _i++) {
            var _x = 49 + (_i mod 6) * 64;
            var _y = 88 + floor(_i / 6) * 26;
            var _tint = _arms ? weapons[_i].color : relic_catalog[_i].tint;
            lk_panel(_x, _y, _x + 59, _y + 22, _i == journal_item, _flags[_i] ? _tint : C_MUTED);
            if (_flags[_i]) {
                _count += 1;
                if (_arms) lk_weapon_draw(_i, _x + 24, _y + 12, 15, 1);
                else {
                    lk_diamond(_x + 30, _y + 11, 5, _tint);
                    lk_diamond(_x + 30, _y + 11, 2, C_PAPER);
                }
            } else {
                lk_diamond(_x + 30, _y + 11, 3, C_EDGE);
            }
        }
        var _label = _flags[journal_item] ? (_arms ? weapons[journal_item].name : relic_catalog[journal_item].name)
            : "UNDISCOVERED";
        var _note = _flags[journal_item] ? (_arms ? lk_weapon_details(journal_item) : relic_catalog[journal_item].note)
            : "LOOK FOR IT IN THE KEEP.";
        lk_text_center(_label, 240, 199, C_PAPER);
        lk_text_center(_note, 240, 212, C_MUTED);
        lk_text_right(string(_count) + " / " + string(array_length(_flags)), 429, 232, C_GOLD);
    } else {
        lk_text_center("RUNS STARTED   " + string(runs_started), 240, 100, C_PAPER);
        lk_text_center("DEEPEST STAGE  " + string(best_floor), 240, 126, C_PAPER);
        lk_text_center("CLEARS         " + string(wins), 240, 152, C_GOLD);
        lk_text_center("FOES DEFEATED  " + string(total_kills), 240, 178, C_PAPER);
    }
    lk_text("ESC BACK", 49, 232, C_MUTED);
    lk_text_center("TAB CHANGE SECTION", 240, 232, C_MUTED);
}
