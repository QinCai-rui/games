function lk_theme_tint(_biome) {
    return [C_TEAL, C_GOLD, C_LILAC, C_BLUE, C_PINK][_biome];
}

function lk_light(_x, _y, _radius, _color, _strength, _height = 1) {
    var _scale = _radius / 48;
    draw_sprite_ext(spr_radial, 0, round(_x - _radius), round(_y - _radius * _height),
        _scale, _scale * _height, 0, _color, _strength);
}

function lk_draw_room_lighting(_xx, _yy) {
    var _accent = [C_GOLD, C_PINK, C_LILAC, C_BLUE, C_GOLD][floor_no];
    gpu_set_blendmode(bm_add);
    for (var _i = 0; _i < 4; _i++) {
        var _x = [80, 150, 330, 400][_i] + _xx;
        var _wave = dsin(world_tick * 13 + _i * 65) * .065;
        lk_light(_x, 49 + _yy, 54 + 4 * dsin(world_tick * 3 + _i * 77), _accent, .38 + _wave, .78);
        lk_light(_x, 57 + _yy, 32, _accent, .12 + _wave * .75, .55);
    }
    if (cell.kind == LK_ROOM.Landing || cell.kind == LK_ROOM.Shrine) {
        var _shade = cell.kind == LK_ROOM.Landing ? C_GOLD : C_LILAC;
        lk_light(240 + _xx, 130 + _yy, 72, _shade, .19 + dsin(world_tick * 3) * .035, .62);
    }
    if (cell.kind == LK_ROOM.Boss) {
        var _shade = cell.clear ? _accent : C_PINK;
        lk_light(240 + _xx, 110 + _yy, 86, _shade, .14 + dsin(world_tick * 3) * .06, .77);
    }
    for (var _i = 0; _i < 4; _i++) {
        if (cell.exits[_i] < 0) continue;
        var _x = _xx + [432, 240, 48, 240][_i];
        var _y = _yy + [143, 228, 143, 55][_i];
        var _kind = dungeon[cell.exits[_i]].kind;
        var _tint = cell.clear ? lk_room_color(_kind) : C_PINK;
        lk_light(_x, _y, 27, _tint, .16, 1);
    }
    gpu_set_blendmode(bm_normal);
}

function lk_draw_border_detail(_xx, _yy) {
    for (var _i = 0; _i < 16; _i++) {
        var _seed = cell.seed + (_i + 1) * 71;
        var _x = 59 + (_seed * 43 mod 360);
        var _y = _i mod 2 == 0 ? 62 + (_seed mod 9) : 220 - (_seed mod 9);
        if (abs(_x - 240) < 30) continue;
        _x += _xx;
        _y += _yy;
        switch (floor_no) {
            case 0:
                // Ivy clings to the walls and small caps sit along the flagstones.
                var _branch = 3 + _seed mod 6;
                for (var _j = 0; _j < _branch; _j++) {
                    var _bend = round(dsin(_seed + _j * 24) * 2);
                    lk_rect(_x + _bend, _y - _j, _x + _bend + 1, _y - _j, $4A635D);
                    if ((_j + _seed) mod 4 == 0) {
                        lk_rect(_x + _bend - 2, _y - _j + 1, _x + _bend + 3, _y - _j + 1, $4D7567);
                        lk_rect(_x + _bend - 1, _y - _j, _x + _bend + 1, _y - _j, $6F8B73);
                    }
                }
                break;
            case 1:
                var _size = 3 + (_seed mod 6);
                lk_line(_x, _y, _x + _size, _y - 1, $43658A);
                lk_line(_x + _size, _y - 1, _x + _size + 3, _y - 4, $4068AD);
                if ((_i + floor(world_tick / 18)) mod 3 == 0) {
                    lk_rect(_x + _size, _y - 1, _x + _size + 1, _y - 1, $547ED1);
                }
                break;
            case 2:
                var _height = 3 + (_seed mod 8);
                lk_diamond(_x, _y - _height * .4, max(2, round(_height * .44)), $8B6691);
                lk_line(_x, _y - _height, _x, _y - 2, $9B83B3);
                lk_rect(_x, _y - _height, _x + 1, _y - _height + 1, $C7ADC9);
                break;
            case 3:
                if ((_i + floor(world_tick / 18)) mod 3 == 0) {
                    lk_line(_x - 4, _y, _x + 5, _y, $94774E);
                    lk_line(_x - 2, _y + 2, _x + 3, _y + 2, $735948);
                }
                break;
            case 4:
                lk_line(_x - 5, _y, _x + 6, _y, $5E6685);
                if ((_seed + floor(world_tick / 9)) mod 4 == 0) lk_rect(_x + 1, _y - 2, _x + 2, _y - 1, C_GOLD);
                break;
        }
    }
}

function lk_draw_ambient(_xx, _yy) {
    var _color = [C_MINT, C_GOLD, C_LILAC, C_BLUE, C_PINK][floor_no];
    for (var _i = 0; _i < 13; _i++) {
        var _seed = cell.seed + _i * 1027;
        var _speed = floor_no == 1 ? 1.28 : .60;
        var _phase = frac((world_tick * _speed + _seed) / (100 + (_seed mod 57)));
        var _x = 58 + (_seed * 11 mod 363) + dsin(_phase * 235 + _seed) * (3 + _i);
        var _y = 68 + (_seed * 3 mod 132) - _phase * (8 + floor_no * 3);
        draw_set_alpha(dsin(_phase * 180) * (floor_no == 1 ? .49 : .26));
        lk_rect(_x + _xx, _y + _yy, _x + _xx + (_i mod 4 == 0), _y + _yy, _color);
    }
    draw_set_alpha(1);
}

function lk_room_color(_kind) {
    switch (_kind) {
        case LK_ROOM.Cache: return C_GOLD;
        case LK_ROOM.Shop: return C_BLUE;
        case LK_ROOM.Shrine: return C_LILAC;
        case LK_ROOM.Boss: return C_PINK;
        case LK_ROOM.Gauntlet: return C_PINK;
        case LK_ROOM.Relic: return C_LILAC;
        case LK_ROOM.Forge: return C_GOLD;
    }
    return C_TEAL;
}

function lk_gate_release() {
    for (var _i = 0; _i < 4; _i++) {
        if (cell.exits[_i] < 0) continue;
        var _xx = [430, 240, 50, 240][_i];
        var _yy = [143, 224, 143, 58][_i];
        var _tint = lk_room_color(dungeon[cell.exits[_i]].kind);
        lk_sparks(_xx, _yy - 2, _tint, 10, 1.15);
        lk_ring(_xx, _yy, _tint, 16, 22);
    }
}

function lk_draw_portal(_x, _cy, _tone) {
    var _pulse = dsin(world_tick * 5) * 2;
    gpu_set_blendmode(bm_add);
    lk_light(_x, _cy - 14, 43, _tone, .63, .84);
    gpu_set_blendmode(bm_normal);
    var _ell = 11 + _pulse;
    for (var _i = 0; _i < 12; _i++) {
        var _a = _i * 30 + world_tick * 3;
        var _c = _i mod 3 == 0 ? C_PAPER : _tone;
        var _x1 = _x + dcos(_a) * _ell;
        var _y1 = _cy - 16 + dsin(_a) * 18;
        var _x2 = _x + dcos(_a + 14) * _ell;
        var _y2 = _cy - 16 + dsin(_a + 14) * 18;
        lk_line(_x1, _y1, _x2, _y2, _c);
    }
    draw_set_alpha(.55 + .15 * dsin(world_tick * 7));
    lk_diamond(_x, _cy - 16 + round(_pulse), 5, C_PAPER);
    draw_set_alpha(1);
}
