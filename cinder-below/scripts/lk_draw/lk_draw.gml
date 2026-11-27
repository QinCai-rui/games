function lk_rect(_x1, _y1, _x2, _y2, _color) {
    draw_set_color(_color);
    draw_rectangle(floor(_x1), floor(_y1), floor(_x2) + 1, floor(_y2) + 1, false);
}

function lk_line(_x1, _y1, _x2, _y2, _color) {
    draw_set_color(_color);
    draw_line(floor(_x1), floor(_y1), floor(_x2), floor(_y2));
}

function lk_border(_x1, _y1, _x2, _y2, _color) {
    draw_set_color(_color);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
}

function lk_diamond(_x, _y, _r, _color) {
    draw_set_color(_color);
    draw_triangle(_x, _y - _r, _x - _r, _y, _x + _r, _y, false);
    draw_triangle(_x, _y + _r, _x - _r, _y, _x + _r, _y, false);
}

function lk_actor(_index, _frame, _x, _y, _face = 1, _scale = 1, _color = c_white, _alpha = 1, _boss = false) {
    var _sprite = spr_actors;
    if (_boss) _sprite = spr_boss_motion;
    else if (_index >= 17) {
        _sprite = spr_final_keepers;
        _index -= 17;
    } else if (_index >= 14) {
        _sprite = spr_late_enemies;
        _index -= 14;
    } else if (_index >= 8) {
        _sprite = spr_expansion;
        _index -= 8;
    }
    lk_actor_cell(_sprite, _index, _frame, _x, _y, _face, _scale, _color, _alpha, _boss);
}

function lk_actor_cell(_sprite, _index, _frame, _x, _y, _face, _scale, _color, _alpha, _boss = false) {
    var _size = _boss ? 48 : 32;
    var _anchor = _boss ? 40 : 26;
    _x = round(_x) - _size * .5 * _face * _scale;
    _y = round(_y) - _anchor * _scale;
    draw_sprite_part_ext(_sprite, 0, _index * _size, _frame * _size,
        _size, _size, _x, _y, _face * _scale, _scale, _color, _alpha);
}

function lk_hero_sprite(_id, _frame, _x, _y, _face = 1, _scale = 1, _color = c_white, _alpha = 1) {
    var _actor = _id < 3 ? _id : (_id < 6 ? _id + 5 : _id + 11);
    lk_actor(_actor, _frame, _x, _y, _face, _scale, _color, _alpha);
}

function lk_shadow(_x, _y, _radius) {
    draw_set_alpha(.42);
    draw_set_color(C_INK);
    draw_ellipse(round(_x - _radius), round(_y - 3), round(_x + _radius), round(_y + 3), false);
    draw_set_alpha(1);
}

function lk_glow(_x, _y, _radius, _color, _strength) {
    draw_set_color(_color);
    for (var _i = 4; _i > 0; _i--) {
        draw_set_alpha(_strength * .14);
        draw_circle(round(_x), round(_y), ceil(_radius * _i / 4), false);
    }
    draw_set_alpha(1);
}

function lk_flame(_x, _y, _seed, _color) {
    var _frame = floor(world_tick / 5 + _seed) mod 4;
    lk_glow(_x, _y + 2, 15, _color, .32);
    var _fade = merge_color(_color, C_PANEL, .28);
    lk_rect(_x - 2, _y - 2, _x + 2, _y + 2, _fade);
    lk_rect(_x - 1, _y - 4 - (_frame mod 3), _x + 1, _y + 1, _color);
    lk_rect(_x - 1, _y - 2, _x, _y + 1, C_PAPER);
    lk_rect(_x + (_frame mod 3) - 1, _y - 8 - _frame, _x + (_frame mod 3) - 1, _y - 8 - _frame, _color);
}

function lk_draw_gate_icon(_role, _x, _y, _color, _dir) {
    switch (_role) {
        case LK_ROUTE_ROOM.High:
            lk_line(_x - 2, _y + 2, _x + 3, _y - 3, _color);
            lk_line(_x - 3, _y, _x, _y + 3, _color);
            break;
        case LK_ROUTE_ROOM.Fork:
        case LK_ROUTE_ROOM.Low:
            var _dx = [1, 0, -1, 0][_dir];
            var _dy = [0, 1, 0, -1][_dir];
            lk_line(_x - _dx + 3 * _dy, _y - _dy - 3 * _dx, _x + 2 * _dx, _y + 2 * _dy, _color);
            lk_line(_x + 2 * _dx, _y + 2 * _dy, _x - _dx - 3 * _dy, _y - _dy + 3 * _dx, _color);
            break;
        case LK_ROUTE_ROOM.Shortcut:
        case LK_ROUTE_ROOM.Toll:
            lk_border(_x - 2, _y - 3, _x + 2, _y + 3, _color);
            lk_line(_x, _y - 1, _x, _y + 1, _color);
            break;
        case LK_ROUTE_ROOM.Trial:
            lk_line(_x - 3, _y + 3, _x + 3, _y - 3, _color);
            lk_line(_x - 3, _y - 3, _x + 3, _y + 3, _color);
            break;
        case LK_ROUTE_ROOM.CircuitReward:
            lk_border(_x - 3, _y - 2, _x + 3, _y + 2, _color);
            lk_diamond(_x, _y, 1, _color);
            break;
        default: lk_diamond(_x, _y, 3, _color);
    }
}

function lk_draw_gate(_dir, _xx, _yy) {
    if (cell.exits[_dir] < 0) return;
    var _x = _xx + [432, 240, 47, 240][_dir];
    var _y = _yy + [144, 229, 144, 53][_dir];
    var _open = lk_door_open(_dir);
    var _other = dungeon[cell.exits[_dir]];
    var _accent = _open ? lk_route_room_color(_other) : C_PINK;
    var _rim = [ $606968, $64505E, $695674, $706C4D, $674756][floor_no];
    if (_dir mod 2 == 1) {
        lk_rect(_x - 21, _y - 14, _x + 21, _y + 8, C_INK);
        lk_rect(_x - 19, _y - 14, _x + 19, _y + 6, _rim);
        lk_rect(_x - 15, _y - 11, _x + 15, _y + 12, C_DEEP);
        if (_open) {
            for (var _i = 0; _i < 3; _i++) lk_rect(_x - 14, _y - 8 + _i * 7, _x + 14, _y - 7 + _i * 7, C_EDGE);
        } else {
            lk_rect(_x - 14, _y - 6, _x + 14, _y + 5, C_EDGE);
            for (var _i = -12; _i <= 12; _i += 6) lk_rect(_x + _i, _y - 7, _x + _i + 2, _y + 7, _rim);
            lk_rect(_x - 3, _y - 3, _x + 3, _y + 2, C_INK);
        }
        lk_rect(_x - 19, _y + 7, _x - 16, _y + 9, _accent);
        lk_rect(_x + 16, _y + 7, _x + 19, _y + 9, _accent);
    } else {
        var _left = _dir == 2;
        var _sign = _left ? 1 : -1;
        lk_rect(_x - 12, _y - 18, _x + 10, _y + 19, _rim);
        lk_rect(_x - 13, _y - 14, _x + 11, _y + 14, C_INK);
        lk_rect(_x - 13, _y - 12, _x + 11, _y + 12, C_DEEP);
        if (!_open) {
            for (var _i = -9; _i <= 9; _i += 6) lk_rect(_x - 10, _y + _i, _x + 9, _y + _i + 2, _rim);
        } else {
            lk_line(_x - 12, _y - 11, _x + 11, _y - 11, C_EDGE);
            lk_line(_x - 12, _y + 11, _x + 11, _y + 11, C_EDGE);
        }
        var _edge = _x + _sign * 10;
        lk_rect(_edge - 2, _y - 15, _edge + 2, _y - 13, _accent);
        lk_rect(_edge - 2, _y + 13, _edge + 2, _y + 15, _accent);
    }
    var _role = lk_route_role(_other);
    if (_role != LK_ROUTE_ROOM.None) lk_rect(_x - 4, _y - 4, _x + 4, _y + 4, C_INK);
    lk_draw_gate_icon(_role, _x, _y, _open || _role == LK_ROUTE_ROOM.None ? _accent : C_MUTED, _dir);
}

function lk_weapon_draw(_id, _x, _y, _angle, _scale = 1, _frame = 0) {
    var _atlas = spr_weapons;
    var _column = _id;
    if (_id >= LK_ARM.Nail) {
        _atlas = spr_forged_arms;
        _column = _id - LK_ARM.Nail;
    } else if (_id >= 16) {
        _atlas = spr_extended_weapons;
        _column = _id - 16;
    }
    // The sprite grip is at (5, 8) in each 24-by-16 frame.
    var _flip = dcos(_angle) < -.05 ? -1 : 1;
    var _dx = lengthdir_x(5 * _scale, _angle) + lengthdir_x(8 * _scale * _flip, _angle - 90);
    var _dy = lengthdir_y(5 * _scale, _angle) + lengthdir_y(8 * _scale * _flip, _angle - 90);
    draw_sprite_general(_atlas, 0, _column * 24, _frame * 16, 24, 16, _x - _dx, _y - _dy,
        _scale, _scale * _flip, _angle, c_white, c_white, c_white, c_white, 1);
}

enum LK_ITEM_ART { Fitting, Reliquary, Inscription, Spindle }

function lk_item_sprite(_item, _x, _y, _color = c_white) {
    draw_sprite_part_ext(spr_forged_items, 0, _item * 16, 0, 16, 16,
        round(_x) - 8, round(_y) - 8, 1, 1, _color, 1);
}

function lk_prop_draw(_p, _x, _y) {
    lk_shadow(_x, _y + 1, _p.radius);
    if (_p.kind == 1) {
        var _base = [ $514B4E, $55414D, $5E5264, $605B44, $4C4257][floor_no];
        lk_rect(_x - 10, _y - 4, _x + 10, _y, C_INK);
        lk_rect(_x - 8, _y - 21, _x + 8, _y - 2, _base);
        lk_rect(_x - 6, _y - 22, _x + 7, _y - 19, merge_color(_base, C_PAPER, .21));
        lk_rect(_x - 10, _y - 24, _x + 10, _y - 22, _base);
        lk_rect(_x - 6, _y - 17, _x - 6, _y - 5, merge_color(_base, C_PAPER, .27));
        lk_rect(_x + 4, _y - 18, _x + 7, _y - 4, C_PANEL);
        lk_rect(_x - 9, _y - 4, _x + 9, _y - 2, merge_color(_base, C_PAPER, .16));
        lk_diamond(_x, _y - 11, 2, floor_no == 0 ? $888968 : $976874);
    } else if (_p.kind == 0) {
        lk_rect(_x - 7, _y - 13, _x + 7, _y, $272233);
        lk_rect(_x - 6, _y - 12, _x + 6, _y - 2, $49577C);
        lk_rect(_x - 6, _y - 12, _x + 6, _y - 11, $6B809F);
        lk_rect(_x - 5, _y - 9, _x + 5, _y - 9, $334264);
        lk_rect(_x - 5, _y - 4, _x + 5, _y - 4, $334264);
        lk_line(_x - 5, _y - 10, _x + 5, _y - 3, $6B809F);
        lk_rect(_x - 7, _y - 11, _x - 6, _y - 2, $34435D);
    } else {
        lk_rect(_x - 5, _y - 11, _x + 5, _y - 2, $382B43);
        lk_rect(_x - 4, _y - 10, _x + 3, _y - 3, $806654);
        lk_rect(_x - 5, _y - 8, _x + 5, _y - 5, $AC8E69);
        lk_rect(_x - 3, _y - 10, _x - 2, _y - 3, $B7AD82);
        lk_rect(_x - 3, _y - 12, _x + 3, _y - 11, $625E53);
    }
}

function lk_chest(_x, _y, _open) {
    lk_shadow(_x, _y + 2, 16);
    lk_rect(_x - 15, _y - 12, _x + 15, _y + 1, C_INK);
    lk_rect(_x - 13, _y - 10, _x + 13, _y - 1, $47547B);
    lk_rect(_x - 12, _y - 9, _x + 12, _y - 7, $5F618E);
    lk_rect(_x - 13, _y - 4, _x + 13, _y - 3, $344264);
    lk_rect(_x - 15, _y - 13, _x + 15, _y - 10, $6B8FBA);
    var _lid_y = _open ? -27 : -19;
    lk_rect(_x - 13, _y + _lid_y, _x + 13, _y + _lid_y + 7, C_INK);
    lk_rect(_x - 12, _y + _lid_y + 1, _x + 12, _y + _lid_y + 6, $4B83B0);
    lk_rect(_x - 10, _y + _lid_y + 1, _x - 8, _y + _lid_y + 7, C_GOLD);
    lk_rect(_x + 8, _y + _lid_y + 1, _x + 10, _y + _lid_y + 7, C_GOLD);
    lk_diamond(_x, _y - 10, 4, C_GOLD);
    lk_diamond(_x, _y - 10, 2, C_INK);
}

function lk_room_setpiece(_xx, _yy) {
    var _x = 240 + _xx;
    var _shrine = lk_is_shrine(cell.kind);
    if (cell.kind == LK_ROOM.Boss || _shrine || cell.kind == LK_ROOM.Landing) {
        var _cy = (cell.kind == LK_ROOM.Boss ? 113 : 137) + _yy;
        var _tone = lk_theme_tint(floor_no);
        draw_set_color(merge_color(_tone, C_PANEL, .69));
        draw_ellipse(_x - 45, _cy - 18, _x + 45, _cy + 18, true);
        draw_ellipse(_x - 41, _cy - 15, _x + 41, _cy + 15, true);
        lk_diamond(_x - 46, _cy, 3, merge_color(_tone, C_PANEL, .48));
        lk_diamond(_x + 46, _cy, 3, merge_color(_tone, C_PANEL, .48));
        if (cell.kind == LK_ROOM.Boss && cell.clear) lk_draw_portal(_x, _cy, _tone);
        if (_shrine) {
            lk_rect(_x - 13, _cy - 2, _x + 13, _cy + 3, C_DEEP);
            lk_rect(_x - 10, _cy - 16, _x + 10, _cy - 2, C_EDGE);
            lk_rect(_x - 12, _cy - 18, _x + 12, _cy - 15, C_MUTED);
            var _shrine_tint = cell.shrine_used ? C_MUTED : lk_room_color(cell.kind);
            lk_glow(_x, _cy - 22, 17, _shrine_tint, .36);
            lk_diamond(_x, _cy - 25 + dsin(world_tick * 4) * 2, 5, _shrine_tint);
        }
        if (cell.kind == LK_ROOM.Landing) {
            lk_rect(_x - 9, _cy - 2, _x + 9, _cy + 3, C_DEEP);
            lk_actor(7, floor(world_tick / 15) mod 2, _x, _cy - 4);
            lk_glow(_x, _cy - 15, 16, C_GOLD, .33);
        }
    }
    if (cell.kind == LK_ROOM.Cache) lk_chest(_x, 137 + _yy, cell.opened);
    if (cell.kind == LK_ROOM.Forge) lk_draw_forge(_xx, _yy);
    if (lk_is_waystation(cell.kind)) lk_draw_waystation(_xx, _yy);
    if (cell.kind == LK_ROOM.Duel) {
        var _cy = 137 + _yy;
        draw_set_color(merge_color(C_PINK, C_EDGE, .63));
        draw_ellipse(_x - 68, _cy - 36, _x + 68, _cy + 36, true);
        draw_ellipse(_x - 63, _cy - 32, _x + 63, _cy + 32, true);
    }
    if (cell.kind == LK_ROOM.Relic) {
        var _cy = 137 + _yy;
        var _tone = cell.opened ? C_MUTED : C_LILAC;
        lk_shadow(_x, _cy + 1, 20);
        lk_rect(_x - 19, _cy - 3, _x + 19, _cy + 1, C_INK);
        lk_rect(_x - 14, _cy - 21, _x + 14, _cy - 3, C_EDGE);
        lk_rect(_x - 16, _cy - 23, _x + 16, _cy - 20, _tone);
        lk_rect(_x - 11, _cy - 19, _x + 11, _cy - 5, C_DEEP);
        lk_light(_x, _cy - 21, 28, _tone, cell.opened ? .09 : .41);
        if (!cell.opened) lk_item_sprite(LK_ITEM_ART.Reliquary, _x, _cy - 26 + dsin(world_tick * 5) * 2);
    }
    if (cell.kind == LK_ROOM.Shop) {
        lk_rect(146 + _xx, 104 + _yy, 335 + _xx, 110 + _yy, C_EDGE);
        lk_rect(147 + _xx, 104 + _yy, 335 + _xx, 105 + _yy, $6F809A);
        lk_actor(7, 0, _x, 105 + _yy);
        for (var _i = 0; _i < 3; _i++) {
            var _item = lk_shop_item(_i);
            var _ix = _item.px + _xx;
            var _iy = _item.py + _yy;
            lk_rect(_ix - 23, _iy - 3, _ix + 23, _iy + 3, C_DEEP);
            lk_rect(_ix - 22, _iy - 5, _ix + 22, _iy, C_EDGE);
            if (!cell.bought[_i]) {
                if (_i < 2) lk_loot_icon(_i == 0 ? LK_LOOT.Heart : LK_LOOT.Energy, _ix, _iy - 9, 0);
                else lk_weapon_draw(cell.stock, _ix - 4, _iy - 10, 20);
                lk_text_center(string(_item.price) + "G", _ix, _iy + 6, C_GOLD);
            }
        }
    }
}

function lk_draw_forge(_xx, _yy) {
    for (var _i = 0; _i < 3; _i++) {
        var _offer = lk_forge_offer(_i);
        var _x = _offer.px + _xx;
        var _y = _offer.py + _yy;
        var _tint = cell.opened || !_offer.usable ? C_MUTED : _offer.tint;
        lk_shadow(_x, _y, 17);
        lk_rect(_x - 15, _y - 13, _x + 15, _y, C_EDGE);
        lk_rect(_x - 18, _y - 16, _x + 18, _y - 13, _tint);
        lk_glow(_x, _y - 21, 22, _tint, cell.opened ? .11 : .37);
        if (_i == 0 || _i == 2 && _offer.usable) {
            var _weapon = _i == 0 ? player.arms[player.slot] : LK_FUSION_FIRST + lk_fusion_index();
            lk_weapon_draw(_weapon, _x - 6, _y - 20, 17, .92);
        } else if (_i == 1) {
            lk_item_sprite(LK_ITEM_ART.Fitting, _x, _y - 23, cell.opened ? C_MUTED : c_white);
        } else lk_diamond(_x, _y - 23, 5, _tint);
        lk_text_center(_offer.sign, _x, _y + 4, _tint);
    }
}

function lk_draw_route_marker(_xx, _yy) {
    var _mark = lk_route_marker();
    if (!is_undefined(_mark)) {
        var _x = _mark.px + _xx;
        var _y = _mark.py + _yy;
        var _tint = _mark.ready ? C_GOLD : C_MUTED;
        lk_glow(_x, _y, 22, _tint, _mark.ready ? .46 : .15);
        lk_rect(_x - 6, _y - 11, _x + 6, _y + 4, C_EDGE);
        var _item = _mark.mark == 3 || _mark.variant == 2 ? LK_ITEM_ART.Spindle : LK_ITEM_ART.Inscription;
        lk_item_sprite(_item, _x, _y - 9 - dsin(world_tick * 4) * 2, _mark.ready ? c_white : C_MUTED);
        lk_line(_x - 9, _y + 5, _x + 9, _y + 5, _tint);
    }
}

function lk_draw_waystation(_xx, _yy) {
    var _x = 240 + _xx;
    var _y = 137 + _yy;
    var _tint = cell.opened ? C_MUTED : lk_room_color(cell.kind);
    lk_shadow(_x, _y + 8, 70);
    lk_rect(_x - 75, _y - 5, _x + 75, _y + 6, C_DEEP);
    lk_line(_x - 75, _y + 5, _x + 75, _y + 5, C_EDGE);
    lk_ornament(_x - 55, _y - 38, _x + 55, _tint);
    lk_text_center(cell.opened ? "CLAIMED" : "CHOOSE ONE", _x, _y - 32, _tint);
    for (var _i = 0; _i < 2; _i++) {
        var _offer = lk_waystation_offer(_i);
        var _px = _offer.px + _xx;
        lk_rect(_px - 15, _y - 4, _px + 15, _y + 1, C_EDGE);
        lk_line(_px - 15, _y - 4, _px + 15, _y - 4, _tint);
        if (cell.opened) continue;
        lk_glow(_px, _y - 11, 16, _offer.tint, .35);
        lk_loot_icon(_offer.icon, _px, _y - 11, _offer.value);
        lk_text_center(_offer.caption, _px, _y + 8, _offer.tint);
    }
}

function lk_draw_rupture_vents(_xx, _yy) {
    if (!lk_rupture_room()) return;
    var _tint = merge_color(lk_theme_tint(floor_no), C_INK, cell.clear ? .72 : .42);
    for (var _i = 0; _i < 2; _i++) {
        var _vent = lk_rupture_vent(_i);
        var _x = _vent.px + _xx;
        var _y = _vent.py + _yy;
        draw_set_color(_tint);
        draw_ellipse(_x - 11, _y - 6, _x + 11, _y + 6, true);
        lk_line(_x - 7, _y - 2, _x - 2, _y + 2, _tint);
        lk_line(_x - 2, _y + 2, _x + 2, _y - 2, _tint);
        lk_line(_x + 2, _y - 2, _x + 7, _y + 2, _tint);
    }
}

function lk_loot_icon(_kind, _x, _y, _value) {
    switch (_kind) {
        case LK_LOOT.Coin:
            lk_rect(_x - 2, _y - 3, _x + 2, _y + 2, C_INK);
            lk_rect(_x - 1, _y - 2, _x + 1, _y + 1, C_GOLD);
            lk_rect(_x, _y - 1, _x, _y + 1, $4A82C2);
            break;
        case LK_LOOT.Energy:
            lk_diamond(_x, _y, 4, C_INK);
            lk_diamond(_x, _y, 3, C_BLUE);
            lk_rect(_x - 1, _y - 1, _x, _y - 1, C_PAPER);
            break;
        case LK_LOOT.Heart:
            lk_rect(_x - 4, _y - 3, _x - 1, _y, C_PINK);
            lk_rect(_x + 1, _y - 3, _x + 4, _y, C_PINK);
            lk_diamond(_x, _y + 1, 4, C_PINK);
            lk_rect(_x - 3, _y - 2, _x - 2, _y - 2, C_PAPER);
            break;
        case LK_LOOT.Weapon:
            lk_glow(_x, _y, 12, weapons[_value].color, .28);
            lk_weapon_draw(_value, _x - 4, _y + 1, 25);
            break;
    }
}

function lk_draw_loot(_xx, _yy) {
    for (var _i = 0; _i < array_length(cell.loot); _i++) {
        var _l = cell.loot[_i];
        if (!_l.alive) continue;
        var _x = round(_l.px + _xx);
        var _y = round(_l.py + _yy);
        lk_shadow(_x, _y, _l.kind == LK_LOOT.Weapon ? 9 : 3);
        var _bob = round(dsin(world_tick * 5 + _l.phase) * 2) + 4 + round(_l.wait / 5);
        lk_loot_icon(_l.kind, _x, _y - _bob, _l.value);
        if (_l.kind == LK_LOOT.Weapon && variable_struct_exists(_l, "fit") && _l.fit > 0) {
            lk_diamond(_x + 7, _y - _bob + 5, 2, fittings[_l.fit].tint);
        }
    }
}

function lk_draw_player(_x, _y) {
    lk_shadow(_x, _y + 1, 9);
    if (player.skill_time > 0 || player.dash_time > 0 || player.fury > 0) {
        lk_glow(_x, _y - 6, 21, heroes[hero_id].tint, .4);
        draw_set_color(heroes[hero_id].tint);
        draw_ellipse(_x - 12, _y - 4, _x + 12, _y + 4, true);
    }
    if (player.tide > 0) {
        var _r = (44 - player.tide) * 1.9;
        draw_set_alpha(.45 + player.tide / 140);
        draw_set_color(C_BLUE);
        draw_ellipse(_x - _r, _y - _r * .68, _x + _r, _y + _r * .68, true);
        lk_diamond(_x - _r, _y, 2, C_PAPER);
        lk_diamond(_x + _r, _y, 2, C_PAPER);
        draw_set_alpha(1);
    }
    var _skin = player.hurt > 3 && world_tick mod 6 < 3 ? C_PINK : c_white;
    var _body_frame = (player.kick >= 4 || player.skill_anim > 9) ? 3 : (player.moving ? 1 + floor(world_tick / 7) mod 2 : 0);
    lk_hero_sprite(hero_id, _body_frame, _x, _y, player.facing, 1, _skin);
    var _angle = player.aim;
    if (player.guard > 0) {
        lk_glow(_x, _y - 5, 23, C_BLUE, .35);
        for (var _i = -7; _i < 7; _i++) {
            var _a = _angle + _i * 12;
            var _b = _a + 12;
            lk_line(_x + lengthdir_x(20, _a), _y - 5 + lengthdir_y(16, _a),
                _x + lengthdir_x(20, _b), _y - 5 + lengthdir_y(16, _b), _i mod 2 == 0 ? C_BLUE : C_PAPER);
        }
    }
    var _kick = player.kick * .37;
    var _wx = _x + lengthdir_x(6 - _kick, _angle);
    var _wy = _y - 8 + lengthdir_y(5 - _kick, _angle);
    var _active = lk_active_weapon();
    var _frame = player.kick >= 5 ? 2 : (player.kick > 0 ? 1 : 0);
    lk_weapon_draw(_active, round(_wx), round(_wy), _angle, 1, _frame);
    var _charge_limit = lk_forged_charge_limit(_active);
    if (_charge_limit > 0 && variable_struct_exists(player, "forged_charge") && player.forged_charge > 0) {
        var _charge = player.forged_charge / _charge_limit;
        var _tint = weapons[_active].color;
        lk_glow(_wx + lengthdir_x(14, _angle), _wy + lengthdir_y(14, _angle), 4 + 8 * _charge, _tint, .55);
        lk_rect(_x - 8, _y - 22, _x + 8, _y - 20, C_INK);
        lk_rect(_x - 8, _y - 22, _x - 8 + 16 * _charge, _y - 20, _charge >= 1 ? C_PAPER : _tint);
    }
    var _kind = weapons[_active].kind;
    if (player.kick >= 5 && _kind != LK_SHOT.Blade && _kind != LK_SHOT.Briar && _kind != LK_SHOT.Crown) {
        gpu_set_blendmode(bm_add);
        lk_light(_wx + lengthdir_x(13, _angle), _wy + lengthdir_y(13, _angle),
            22, weapons[_active].color, .49 * (player.kick - 4) / 2, .82);
        gpu_set_blendmode(bm_normal);
    }
}

function lk_draw_seals(_xx, _yy) {
    for (var _i = 0; _i < array_length(room_seals); _i++) {
        var _seal = room_seals[_i];
        var _x = _seal.px + _xx;
        var _y = _seal.py + _yy;
        var _color = _seal.used ? C_MUTED : C_LILAC;
        lk_shadow(_x, _y + 1, 16);
        lk_diamond(_x, _y, 12, C_INK);
        lk_diamond(_x, _y, 10, _color);
        lk_diamond(_x, _y, 8, C_PANEL);
        if (!_seal.used) {
            var _lift = round(dsin(world_tick * 6) * 2);
            lk_glow(_x, _y - 4, 17, _color, .40);
            lk_line(_x - 4, _y + 1, _x + 4, _y + 1, _color);
            lk_diamond(_x, _y - 7 + _lift, 4, _color);
            lk_diamond(_x, _y - 7 + _lift, 1, C_PAPER);
        }
    }
}

function lk_draw_encounter_actor(_e, _x, _y, _frame, _tint, _alpha, _flinch) {
    var _column = _e.kind - LK_ENEMY.Bulwark;
    var _face = _e.facing;
    if (_e.kind == LK_ENEMY.Bulwark) {
        var _shield_angle = lk_bulwark_facing(_e);
        _face = dcos(_shield_angle) >= 0 ? 1 : -1;
        if (lk_bulwark_guarding(_e)) {
            _frame = 3;
            draw_set_alpha(_alpha);
            var _plate = variable_struct_exists(_e, "hunt_facing") ? C_GOLD : C_TEAL;
            for (var _i = -64; _i < 64; _i += 16) {
                var _a = _shield_angle + _i;
                lk_line(_x + lengthdir_x(17, _a), _y + lengthdir_y(17, _a),
                    _x + lengthdir_x(17, _a + 16), _y + lengthdir_y(17, _a + 16), _plate);
            }
            draw_set_alpha(1);
        } else if (_e.dash > 0) {
            _frame = 2;
        }
    }
    if (lk_stationary_enemy(_e.kind)) {
        _face = 1;
        _flinch = 0;
        if (_e.tell == 0 && _e.hit == 0 && _frame == 2) _frame = 0;
    }
    lk_actor_cell(spr_encounter_actors, _column, _frame, _x + _flinch, _y, _face, 1, _tint, _alpha);
    if (_e.kind == LK_ENEMY.BroodHusk) {
        draw_set_alpha(_alpha);
        for (var _i = 0; _i < 3; _i++) {
            lk_diamond(_x - 6 + _i * 6, _y - 32, 2, _i < _e.attack ? C_EDGE : C_MINT);
        }
        draw_set_alpha(1);
    }
}

function lk_draw_guardian_part(_part, _x, _y, _tint, _alpha) {
    var _index_panel = _part.guardian_owner.guardian == LK_GUARDIAN.Indexer;
    // The two guardian parts follow the seven enemy columns.
    var _column = _index_panel ? 7 : 8;
    var _frame = _part.hatching || _part.hit > 0 ? 3 : floor(world_tick / 14) mod 2;
    if (!_index_panel) {
        var _pulse = _part.hatching ? .6 + dsin(world_tick * 25) * .3 : .2;
        lk_glow(_x, _y - 8, 18, _part.color, _pulse * _alpha);
    }
    lk_actor_cell(spr_encounter_actors, _column, _frame, _x, _y, 1, 1, _tint, _alpha);
}

function lk_draw_regent_forecast(_e, _x, _y, _reflected) {
    var _spears = _e.attack mod 2 == 0;
    var _gap = _spears ? 11 : 18;
    var _count = _spears ? 3 : 5;
    var _aim = _reflected ? 180 - _e.angle : _e.angle;
    var _reach = _reflected ? (54 - _e.tell) * 4 : 180;
    var _color = _reflected ? C_LILAC : C_PINK;
    draw_set_alpha(_reflected ? .58 : .62);
    for (var _i = 0; _i < _count; _i++) {
        var _a = _aim + (_i - (_count - 1) / 2) * _gap;
        for (var _r = 12; _r < _reach; _r += 10) {
            var _dx = lengthdir_x(_r, _a);
            var _dy = lengthdir_y(_r, _a);
            var _world_x = (_reflected ? 480 - _e.px : _e.px) + _dx;
            if (!lk_keep_bounds(_world_x, _e.py - 5 + _dy, 0, false)) break;
            lk_line(_x + _dx, _y + _dy, _x + lengthdir_x(_r + 4, _a),
                _y + lengthdir_y(_r + 4, _a), _color);
        }
    }
    draw_set_alpha(1);
}

function lk_draw_alt_guardian(_e, _x, _y, _pose, _tint, _alpha, _flinch) {
    var _column = _e.guardian - LK_GUARDIAN.Indexer;
    if (_e.guardian == LK_GUARDIAN.Indexer) {
        draw_set_alpha((.35 + dsin(world_tick * 4) * .17) * _alpha);
        for (var _i = 0; _i < array_length(_e.guardian_parts); _i++) {
            var _part = _e.guardian_parts[_i];
            if (!_part.alive) continue;
            lk_line(_x, _y - 16, _x + _part.px - _e.px, _y + _part.py - _e.py - 13, C_GOLD);
        }
        draw_set_alpha(1);
    } else if (_e.guardian == LK_GUARDIAN.Split) {
        var _mirror_x = _x + 480 - _e.px * 2;
        lk_actor_cell(spr_alt_guardians, _column, _pose, _mirror_x, _y, -_e.facing, 1, C_LILAC, _alpha * .42, true);
        if (_e.tell > 0) {
            lk_draw_regent_forecast(_e, _mirror_x, _y - 5, true);
            if (_e.tell <= 28) lk_draw_regent_forecast(_e, _x, _y - 5, false);
        }
    }
    lk_actor_cell(spr_alt_guardians, _column, _pose, _x + _flinch, _y, _e.facing, 1, _tint, _alpha, true);
}

function lk_draw_enemy(_e, _x, _y) {
    lk_shadow(_x, _y + 1, _e.radius + 2);
    var _encounter_actor = _e.kind >= LK_ENEMY.Bulwark;
    if (_e.elite) {
        lk_glow(_x, _y - 7, _e.radius + 9, C_GOLD, .34);
        var _elite_x = _encounter_actor && _e.tell > 0 ? _x + 9 : _x;
        lk_diamond(_elite_x, _y - (_encounter_actor ? 36 : 28), 3, C_GOLD);
    }
    if (_e.emerge > 0) {
        draw_set_alpha(1 - _e.emerge / 26);
        lk_glow(_x, _y, _e.radius + 5, _e.color, .48);
    }
    var _firing = _e.kind == LK_ENEMY.Sentry && _e.echo > 0;
    var _frame = _e.tell > 0 || _e.dash > 0 || _firing ? 3 : 1 + ((floor(world_tick / 11) + _e.phase) mod 2);
    var _tint = _e.hit > 0 ? $A5D7FF : (_e.slow > 0 ? $F7D0AD : c_white);
    var _alpha = 1 - _e.emerge / 30;
    var _boss = _e.kind == LK_ENEMY.Boss;
    if (_e.tell > 0 && (!_boss || _e.guardian == LK_GUARDIAN.Original
        || ((_e.guardian == LK_GUARDIAN.Indexer || _e.guardian == LK_GUARDIAN.Matron) && _e.attack mod 2 == 0))) {
        var _aim = _e.angle;
        var _sniper = _e.kind == LK_ENEMY.Harpoon || (_e.kind == LK_ENEMY.Sentry && !variable_struct_exists(_e, "guardian_owner"))
            || variable_struct_exists(_e, "hunt_facing");
        var _rush = _e.kind == LK_ENEMY.Charger || (_boss && depth_no == 0 && _e.attack mod lk_boss_rotation(_e) == 0);
        var _length = _sniper ? 420 : (_boss ? 45 : 31);
        if (_rush) {
            var _slowed_steps = clamp(_e.slow - _e.tell, 0, LK_CHARGE_STEPS);
            _length = lk_enemy_pace(_e, LK_CHARGE_SPEED) * (LK_CHARGE_STEPS - .47 * _slowed_steps);
        }
        if (_e.kind == LK_ENEMY.Monk || _e.kind == LK_ENEMY.Wisp || _e.kind >= LK_ENEMY.BroodHusk) _length = 0;
        if (_e.kind == LK_ENEMY.Bulwark && !_sniper) _length = 55;
        if (_e.kind == LK_ENEMY.Threadbinder && _e.attack == 1) _length = 43;
        var _heat = 1 - clamp(_e.tell / 35, 0, 1);
        var _flare = .34 + _heat * .32;
        gpu_set_blendmode(bm_add);
        lk_light(_x, _y - 6, _e.radius * 2.5 + _heat * 6, C_PINK, _flare, .73);
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(.37 + _heat * .42);
        for (var _spot = 7; _spot < _length; _spot += 7) {
            if (_sniper || _rush) {
                var _px = _e.px + lengthdir_x(_spot, _aim);
                var _py = _e.py + lengthdir_y(_spot, _aim);
                var _clearance = _rush ? _e.radius : 1.5;
                if (!lk_keep_bounds(_px, _py, _clearance, false)) break;
                var _prop = lk_prop_at(_px, _py, _clearance);
                if (!is_undefined(_prop) && (_e.kind != LK_ENEMY.Sentry || _prop.hp < 0)) break;
            }
            lk_line(_x + lengthdir_x(_spot, _aim), _y + lengthdir_y(_spot, _aim),
                _x + lengthdir_x(_spot + 3, _aim), _y + lengthdir_y(_spot + 3, _aim), C_PINK);
        }
        draw_set_alpha(1);
        var _tell_height = _boss ? 42 : (_encounter_actor ? 35 : 24);
        if (_e.kind == LK_ENEMY.BroodHusk) _tell_height = 38;
        lk_diamond(round(_x), round(_y - _tell_height), 2 + (_heat > .65), C_PINK);
    }
    if (_boss) {
        lk_glow(_x, _y - 11, 25, _e.color, .30);
        var _pose = _e.hit > 0 ? 3 : (_e.tell > 0 || _e.dash > 0 || _e.transition > 0 ? 2 : (floor(world_tick / 9) mod 2));
        var _flinch = _e.hit > 0 ? -_e.facing * round(_e.hit / 2.6) : 0;
        if (_e.guardian == LK_GUARDIAN.Original) {
            lk_actor(depth_no, _pose, _x + _flinch, _y, _e.facing, 1, _tint, _alpha, true);
        } else {
            lk_draw_alt_guardian(_e, _x, _y, _pose, _tint, _alpha, _flinch);
        }
        var _braced = 1 - lk_guardian_open_health(_e) / (_e.max_hp * LK_GUARDIAN_OPENING);
        if (_braced > .25) {
            draw_set_alpha(_braced * .85);
            for (var _side = -1; _side <= 1; _side += 2) {
                lk_line(_x + 14 * _side, _y - 23, _x + 19 * _side, _y - 16, C_GOLD);
                lk_line(_x + 19 * _side, _y - 16, _x + 16 * _side, _y - 8, C_GOLD);
            }
            draw_set_alpha(1);
        }
        if (lk_ram_shell(_e)) {
            draw_set_color(C_GOLD);
            draw_ellipse(_x - 19, _y - 28, _x + 19, _y, true);
            for (var _i = -1; _i <= 1; _i++) lk_diamond(_x + 8 * _i, _y - 16, 3, _i + 1 < _e.shell_hits ? C_PAPER : C_EDGE);
        }
    } else if (variable_struct_exists(_e, "guardian_owner")) {
        lk_draw_guardian_part(_e, _x, _y, _tint, _alpha);
    } else {
        var _flinch = _e.hit > 0 ? -_e.facing * round(_e.hit / 3) : 0;
        if (_encounter_actor) {
            lk_draw_encounter_actor(_e, _x, _y, _frame, _tint, _alpha, _flinch);
        } else {
            lk_actor(_e.kind < LK_ENEMY.Boss ? 3 + _e.kind : 6 + _e.kind, _frame, _x + _flinch, _y, _e.facing, 1, _tint, _alpha);
        }
    }
    draw_set_alpha(1);
    if (!_boss && _e.hp < _e.max_hp && _e.emerge == 0) {
        var _ey = _y - (_encounter_actor ? 27 : 25);
        lk_rect(_x - 7, _ey, _x + 7, _ey + 1, C_DEEP);
        lk_rect(_x - 7, _ey, _x - 7 + 14 * _e.hp / _e.max_hp, _ey + 1, _e.color);
    }
}

function lk_draw_shots(_xx, _yy) {
    for (var _i = 0; _i < array_length(shots); _i++) {
        var _b = shots[_i];
        var _x = round(_b.px + _xx);
        var _y = round(_b.py + _yy - (_b.friendly ? 5 : 0));
        if (_b.kind == LK_SHOT.Orbit) {
            lk_glow(_x, _y, 12, C_GOLD, .45);
            lk_diamond(_x, _y, 5, C_GOLD);
            lk_diamond(_x, _y, 2, C_PAPER);
            continue;
        }
        if (_b.kind == LK_SHOT.Mortar) {
            var _lift = round(dsin(clamp(_b.age / 23, 0, 1) * 180) * 19);
            lk_shadow(_x, _y + 4, 3);
            lk_diamond(_x, _y - _lift, 5, _b.color);
            lk_diamond(_x, _y - _lift, 2, C_PAPER);
            continue;
        }
        if (_b.kind == LK_SHOT.Disc) {
            var _spin = _b.age * 22;
            lk_diamond(_x, _y, 5, _b.color);
            lk_line(_x + lengthdir_x(5, _spin), _y + lengthdir_y(5, _spin),
                _x + lengthdir_x(6, _spin + 150), _y + lengthdir_y(6, _spin + 150), C_PAPER);
            continue;
        }
        if (_b.kind == LK_SHOT.Vial) {
            var _arch = round(dsin(clamp(_b.age / 26, 0, 1) * 180) * 11);
            lk_diamond(_x, _y - _arch, 4, C_MINT);
            lk_rect(_x - 1, _y - 1 - _arch, _x, _y - 1 - _arch, C_PAPER);
            continue;
        }
        if (_b.kind == LK_SHOT.WispStar) {
            var _r = 4 + floor(_b.age / 9);
            for (var _i = -1; _i <= 1; _i++) {
                var _a = _b.angle + _i * 27;
                lk_line(_x, _y, _x + lengthdir_x(_r, _a), _y + lengthdir_y(_r, _a), _b.color);
            }
        } else if (_b.kind == LK_SHOT.ThornSeed && _b.age < 60) {
            var _tip = (_b.age mod 12) / 2 + 4;
            lk_line(_x + lengthdir_x(_tip, _b.angle + 90), _y + lengthdir_y(_tip, _b.angle + 90),
                _x + lengthdir_x(_tip, _b.angle - 90), _y + lengthdir_y(_tip, _b.angle - 90), _b.color);
        }
        var _tail = _b.friendly ? _b.speed + 3 : 3;
        var _tx = _x - lengthdir_x(_tail, _b.angle);
        var _ty = _y - lengthdir_y(_tail, _b.angle);
        draw_set_color(merge_color(_b.color, C_INK, .24));
        draw_line_width(_tx, _ty, _x, _y, _b.radius + 2);
        draw_set_color(_b.color);
        draw_line_width(_tx, _ty, _x, _y, max(1, _b.radius - 1));
        lk_diamond(_x, _y, _b.radius, _b.color);
        lk_rect(_x, _y - 1, _x + (_b.radius > 2), _y, C_PAPER);
    }
}

function lk_draw_effects(_xx, _yy) {
    for (var _i = 0; _i < array_length(particles); _i++) {
        var _p = particles[_i];
        var _x = _p.px + _xx;
        var _y = _p.py + _yy;
        var _ratio = _p.life / _p.max_life;
        draw_set_alpha(_ratio);
        switch (_p.kind) {
            case 0:
                var _size = floor(_p.size * _ratio);
                lk_rect(_x, _y, _x + _size, _y + _size, _p.color);
                break;
            case 1:
                var _r = _p.size * (1 - _ratio * .64);
                draw_set_color(_p.color);
                draw_ellipse(round(_x - _r), round(_y - _r * .56), round(_x + _r), round(_y + _r * .56), true);
                break;
            case 5:
                if (_p.foe >= LK_ENEMY.Bulwark) {
                    lk_diamond(_x - 4 - (1 - _ratio) * 8, _y + 2, max(1, round(5 * _ratio)), _p.color);
                    lk_diamond(_x + 4 + (1 - _ratio) * 8, _y + 1, max(1, round(4 * _ratio)), _p.color);
                    break;
                }
                var _big_foe = _p.foe == LK_ENEMY.Boss;
                var _down = _big_foe ? 4 : 3;
                var _index = _big_foe ? depth_no : (_p.foe < LK_ENEMY.Boss ? 3 + _p.foe : 6 + _p.foe);
                lk_actor(_index, _down, _x - _p.angle * (1 - _ratio) * 6, _y + (1 - _ratio) * 3, _p.angle,
                    _big_foe ? 1 : (.7 + _ratio * .3), _p.color, _ratio * .86, _big_foe);
                break;
            case 4:
                lk_arc_draw(_p, _xx, _yy);
                break;
            case 3:
                lk_hero_sprite(hero_id, 3, _x, _y, _p.angle, 1, C_PINK, _ratio * .42);
                break;
            case 2:
                var _r = _p.size * (.84 + (1 - _ratio) * .18);
                var _spin = _p.angle + 55 * (_ratio - .5);
                for (var _j = 0; _j < 12; _j++) {
                    var _a = _spin - 65 + _j * 10;
                    lk_line(_x + lengthdir_x(_r, _a), _y + lengthdir_y(_r * .75, _a),
                        _x + lengthdir_x(_r, _a + 10), _y + lengthdir_y(_r * .75, _a + 10), _p.color);
                }
                break;
        }
    }
    for (var _i = 0; _i < array_length(floaters); _i++) {
        var _f = floaters[_i];
        draw_set_alpha(min(1, _f.life / 16));
        lk_text_center(_f.label, _f.px + _xx + 1, _f.py + _yy + 1, C_INK);
        lk_text_center(_f.label, _f.px + _xx, _f.py + _yy, _f.color);
    }
    draw_set_alpha(1);
}

function lk_draw_game() {
    var _xx = round(dsin(world_tick * 163) * shaking * .47);
    var _yy = round(dcos(world_tick * 105) * shaking * .31);
    if (depth_no < 6) {
        draw_sprite_part(spr_arenas, 0, floor_no * 480, (depth_no mod 2) * 270, 480, 270, _xx, _yy);
    } else {
        var _sanctum = cell.kind == LK_ROOM.Boss || cell.kind == LK_ROOM.Gauntlet || cell.kind == LK_ROOM.Duel;
        draw_sprite_part(spr_late_arenas, 0, (floor_no - 3) * 480, _sanctum * 270, 480, 270, _xx, _yy);
    }
    lk_draw_room_lighting(_xx, _yy);
    lk_draw_border_detail(_xx, _yy);
    var _accent = [C_GOLD, C_PINK, C_LILAC, C_BLUE, C_GOLD][floor_no];
    for (var _i = 0; _i < 4; _i++) {
        lk_draw_gate(_i, _xx, _yy);
        lk_flame([80, 150, 330, 400][_i] + _xx, 46 + _yy, _i * 2, _accent);
    }
    for (var _i = 0; _i < 38; _i++) {
        var _x = 54 + ((cell.seed + _i * 137) mod 373);
        var _y = 64 + ((cell.seed * 3 + _i * 73) mod 154);
        var _shade = lk_theme_tint(floor_no);
        draw_set_alpha(.17);
        lk_rect(_x + _xx, _y + _yy, _x + _xx + (_i mod 3 == 0), _y + _yy, _shade);
    }
    draw_set_alpha(1);
    lk_room_setpiece(_xx, _yy);
    lk_draw_route_marker(_xx, _yy);
    lk_draw_rupture_vents(_xx, _yy);
    lk_draw_seals(_xx, _yy);
    for (var _i = 0; _i < array_length(fields); _i++) lk_field_draw(fields[_i], _xx, _yy);
    lk_draw_loot(_xx, _yy);
    var _depths = [{py: player.py, px: player.px, kind: 0, ref: player}];
    for (var _i = 0; _i < array_length(cell.props); _i++) {
        var _p = cell.props[_i];
        if (_p.alive) array_push(_depths, {py: _p.py, px: _p.px, kind: 1, ref: _p});
    }
    for (var _i = 0; _i < array_length(enemies); _i++) {
        var _e = enemies[_i];
        if (_e.alive) array_push(_depths, {py: _e.py, px: _e.px, kind: 2, ref: _e});
    }
    array_sort(_depths, function(_a, _b) { return _a.py - _b.py; });
    for (var _i = 0; _i < array_length(_depths); _i++) {
        var _p = _depths[_i];
        var _sx = round(_p.px + _xx);
        var _sy = round(_p.py + _yy);
        switch (_p.kind) {
            case 0: lk_draw_player(_sx, _sy); break;
            case 1: lk_prop_draw(_p.ref, _sx, _sy); break;
            case 2: lk_draw_enemy(_p.ref, _sx, _sy); break;
        }
    }
    lk_draw_shots(_xx, _yy);
    if (mode == LK_MODE.Play && boss_intro == 0) lk_draw_reticle(_xx, _yy);
    lk_draw_effects(_xx, _yy);
    lk_draw_ambient(_xx, _yy);
    draw_sprite(spr_vignette, 0, 0, 0);
    if (flash_screen > 0) {
        draw_set_alpha(flash_screen / 85);
        lk_rect(0, 32, 479, 244, C_PINK);
    }
    if (room_fade > 0) {
        draw_set_alpha(room_fade / 18);
        lk_rect(0, 31, 479, 244, C_INK);
    }
    draw_set_alpha(1);
    lk_draw_hud();
}

function lk_draw_reticle(_xx, _yy) {
    if (pointer_fire && lk_keep_bounds(pointer_x, pointer_y, 0, false)) {
        var _x = round(pointer_x);
        var _y = round(pointer_y);
        draw_set_alpha(.82);
        lk_line(_x - 8, _y, _x - 3, _y, C_PAPER);
        lk_line(_x + 3, _y, _x + 8, _y, C_PAPER);
        lk_line(_x, _y - 7, _x, _y - 3, C_PAPER);
        lk_line(_x, _y + 3, _x, _y + 7, C_PAPER);
        draw_set_alpha(1);
    } else if (fire_held && !is_undefined(player.target) && player.target.alive) {
        var _target = player.target;
        var _x = round(_target.px + _xx);
        var _y = round(_target.py + _yy - 9);
        var _r = _target.radius + 5;
        draw_set_alpha(.72);
        for (var _side = -1; _side <= 1; _side += 2) {
            for (var _side_y = -1; _side_y <= 1; _side_y += 2) {
                lk_line(_x + _r * _side, _y + _r * _side_y,
                    _x + (_r - 4) * _side, _y + _r * _side_y, C_TEAL);
                lk_line(_x + _r * _side, _y + _r * _side_y,
                    _x + _r * _side, _y + (_r - 4) * _side_y, C_TEAL);
            }
        }
        draw_set_alpha(1);
    }
}
