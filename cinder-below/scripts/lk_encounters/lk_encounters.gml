function lk_is_waystation(_kind) {
    return _kind == LK_ROOM.Armory || _kind == LK_ROOM.SupplyPost || _kind == LK_ROOM.TemperRelay;
}

function lk_stage_waystation() {
    if (depth_no < 2 || !lk_standard_contract()) return -1;
    // Each run sees all three stops before any repeats, in a seed-based order.
    var _step = run_seed mod 2 == 0 ? 1 : 2;
    var _index = (run_seed + (depth_no - 2) * _step) mod 3;
    return [LK_ROOM.Armory, LK_ROOM.SupplyPost, LK_ROOM.TemperRelay][_index];
}

function lk_waystation_offer(_index) {
    var _offer = {kind: "waystation", index: _index, px: 181 + _index * 118, py: 137,
        label: "", detail: "", caption: "", tint: C_GOLD, icon: LK_LOOT.Coin, value: 10};
    if (cell.kind == LK_ROOM.Armory) {
        var _first = cell.stock;
        var _weapon = _index == 0 ? _first :
            lk_weapon_stock(LK_STOCK.Cache, cell.seed * 13, _first, lk_armory_group(_first));
        var _rank = cell.stock_temper;
        _offer.icon = LK_LOOT.Weapon;
        _offer.value = _weapon;
        _offer.tint = weapons[_weapon].color;
        _offer.caption = weapons[_weapon].name + (_rank > 0 ? " +" + string(_rank) : "");
        _offer.label = "TAKE " + _offer.caption;
        _offer.detail = lk_weapon_details(_weapon, _rank, true);
    } else if (cell.kind == LK_ROOM.SupplyPost && _index == 0) {
        _offer.icon = LK_LOOT.Energy;
        _offer.value = 35;
        _offer.tint = C_BLUE;
        _offer.caption = "+35 ENERGY";
        _offer.label = "TAKE ENERGY";
        _offer.detail = player.energy >= player.max_energy ? "ENERGY ALREADY FULL" : "RESTORE UP TO 35 ENERGY";
    } else if (cell.kind == LK_ROOM.TemperRelay && _index == 0) {
        _offer.icon = LK_LOOT.Weapon;
        _offer.value = player.arms[player.slot];
        _offer.caption = "MOVE 1 TEMPER";
        _offer.label = "MOVE 1 TEMPER";
        _offer.detail = player.temper[player.slot] >= 3 ? "ACTIVE WEAPON AT MAX TEMPER"
            : (player.temper[1 - player.slot] == 0 ? "OTHER WEAPON HAS NO TEMPER"
            : "SLOT " + string(2 - player.slot) + " TO SLOT " + string(1 + player.slot));
    } else {
        _offer.caption = "+" + string(_offer.value) + " GOLD";
        _offer.label = "TAKE " + string(_offer.value) + " GOLD";
        _offer.detail = "USE AT A SHOP OR FORGE";
    }
    return _offer;
}

function lk_claim_waystation(_index) {
    if (!lk_is_waystation(cell.kind) || cell.opened) return false;
    var _offer = lk_waystation_offer(_index);
    var _slot = player.slot;
    if (cell.kind == LK_ROOM.Armory) {
        lk_drop(LK_LOOT.Weapon, _offer.px, _offer.py + 13, player.arms[_slot],
            player.temper[_slot], player.attachments[_slot]);
        lk_equip_weapon(_slot, _offer.value, cell.stock_temper);
    } else if (cell.kind == LK_ROOM.TemperRelay && _index == 0) {
        var _source = 1 - _slot;
        if (player.temper[_source] == 0 || player.temper[_slot] >= 3) return false;
        player.temper[_source] -= 1;
        player.temper[_slot] += 1;
    } else if (_offer.icon == LK_LOOT.Energy) {
        if (player.energy >= player.max_energy) return false;
        player.energy = min(player.max_energy, player.energy + _offer.value);
    } else {
        player.coins += _offer.value;
    }
    cell.opened = true;
    lk_unstable_roll();
    lk_sparks(_offer.px, _offer.py - 8, _offer.tint, 22, 1.6);
    return true;
}

function lk_rupture_room() {
    return cell.kind == LK_ROOM.Fight && cell.encounter == LK_FIGHT.Rupture;
}

function lk_deal_alternate_encounters(_variant) {
    var _first = _variant == 1 ? LK_FIGHT.IndexGuard : LK_FIGHT.IntakeWatch;
    var _high = 4 + irandom(1);
    var _low = irandom(1);
    var _bag = [];
    for (var _i = 0; _i < 6; _i++) {
        if (_i != _high && _i != _low) array_push(_bag, _i);
    }
    for (var _i = 1; _i < array_length(dungeon); _i++) {
        var _room = dungeon[_i];
        if (_room.kind != LK_ROOM.Fight) continue;
        switch (lk_route_role(_room)) {
            case LK_ROUTE_ROOM.High: _room.encounter = _first + _high; break;
            case LK_ROUTE_ROOM.Low: _room.encounter = _first + _low; break;
            default:
                // Longer contracts can use every template before the deck repeats.
                if (array_length(_bag) == 0) _bag = [0, 1, 2, 3, 4, 5];
                var _deal = irandom(array_length(_bag) - 1);
                _room.encounter = _first + _bag[_deal];
                array_delete(_bag, _deal, 1);
                break;
        }
    }
}

function lk_deal_encounters() {
    var _variant = lk_route_variant();
    if (_variant > 0) {
        lk_deal_alternate_encounters(_variant);
        return;
    }
    var _bag = [];
    var _layouts = [];
    var _return_to_roots = depth_no == 0 && run_contract == LK_CONTRACT.Delve && delves_started > 1;
    var _opening = LK_FIGHT.Ambush;
    var _low = LK_FIGHT.Swarm;
    if (_return_to_roots) {
        // Draw from alternating pairs so back-to-back Delves open differently.
        _opening = delves_started mod 2 == 0 ? choose(LK_FIGHT.Crossfire, LK_FIGHT.BroodNest)
            : choose(LK_FIGHT.Ambush, LK_FIGHT.ShieldLine);
        if (_opening != LK_FIGHT.Ambush && run_seed mod 2 == 0) _low = LK_FIGHT.Ambush;
    }
    var _first_depth = [0, 1, 1, 1, 1, 0, 0, 1, 2, 3, 4, 6, 6];
    if (_return_to_roots) {
        _first_depth[LK_FIGHT.Crossfire] = 0;
        _first_depth[LK_FIGHT.Rupture] = 0;
    }
    for (var _id = 0; _id < array_length(_first_depth); _id++) {
        if (depth_no >= _first_depth[_id] && _id != LK_FIGHT.EliteHunt && _id != _low) array_push(_bag, _id);
        if (_id < 10) array_push(_layouts, _id);
    }
    var _showcase = [
        _return_to_roots ? [_opening] : [LK_FIGHT.Ambush, LK_FIGHT.ShieldLine],
        [LK_FIGHT.TwinSeals], [LK_FIGHT.RelayGuard], [LK_FIGHT.HeatWorks],
        [LK_FIGHT.ThreadedCrossing], [],
        [LK_FIGHT.ShatteredColonnade, LK_FIGHT.ThreadedCrossing, LK_FIGHT.FloodPulse],
        [LK_FIGHT.HeatWorks, LK_FIGHT.ShatteredColonnade]
    ][depth_no];
    // Rotate between firing lines, objectives, ground hazards and support enemies.
    var _family = [0, 0, 0, 2, 0, 0, 1, 1, 3, 2, 3, 0, 2];
    var _played = [0, 0, 0, 0];
    var _previous = -1;
    var _index = 0;
    for (var _i = 1; _i < array_length(dungeon); _i++) {
        var _room = dungeon[_i];
        if (_room.kind != LK_ROOM.Fight) continue;
        var _role = lk_route_role(_room);
        if (_role == LK_ROUTE_ROOM.High || _role == LK_ROUTE_ROOM.Low) {
            _room.encounter = _role == LK_ROUTE_ROOM.High ? LK_FIGHT.EliteHunt : _low;
            continue;
        }
        var _deal = 0;
        if (_index < array_length(_showcase)) {
            while (_bag[_deal] != _showcase[_index]) _deal += 1;
        } else {
            var _best = 100;
            var _start = irandom(array_length(_bag) - 1);
            for (var _j = 0; _j < array_length(_bag); _j++) {
                var _candidate = (_start + _j) mod array_length(_bag);
                var _group = _family[_bag[_candidate]];
                var _score = _played[_group] + (_group == _previous ? 10 : 0);
                if (_score >= _best) continue;
                _deal = _candidate;
                _best = _score;
            }
        }
        _room.encounter = _bag[_deal];
        _previous = _family[_room.encounter];
        _played[_previous] += 1;
        array_delete(_bag, _deal, 1);
        var _layout = irandom(array_length(_layouts) - 1);
        _room.layout = _layouts[_layout];
        array_delete(_layouts, _layout, 1);
        _index += 1;
    }
}

function lk_furnish_objective_room(_room) {
    if (_room.encounter >= LK_FIGHT.IndexGuard) {
        var _pattern = (_room.encounter - LK_FIGHT.IndexGuard) mod 2;
        if (_room.encounter < LK_FIGHT.IntakeWatch) {
            if (_pattern == 0) {
                // Parallel shelves give ranged enemies cover on both sides of the aisle.
                for (var _i = 0; _i < 3; _i++) {
                    lk_add_prop(_room, 184 + _i * 56, 112, _i == 1 ? 2 : 1);
                    lk_add_prop(_room, 184 + _i * 56, 174, _i == 1 ? 1 : 2);
                }
            } else {
                // The central wall can be breached at either end.
                lk_add_prop(_room, 240, 104, 2);
                lk_add_prop(_room, 240, 127, 1);
                lk_add_prop(_room, 240, 159, 1);
                lk_add_prop(_room, 240, 182, 2);
                lk_add_prop(_room, 150, 111, 2);
                lk_add_prop(_room, 330, 175, 2);
            }
        } else if (_pattern == 0) {
            lk_add_prop(_room, 141, 141, 1);
            lk_add_prop(_room, 339, 141, 1);
            lk_add_prop(_room, 186, 111, 0);
            lk_add_prop(_room, 294, 175, 0);
        } else {
            lk_add_prop(_room, 201, 106, 1);
            lk_add_prop(_room, 279, 180, 1);
            lk_add_prop(_room, 172, 180, 2);
            lk_add_prop(_room, 308, 106, 2);
        }
        return true;
    }
    switch (_room.encounter) {
        case LK_FIGHT.ShieldLine:
            lk_add_prop(_room, 240, 97, 1);
            lk_add_prop(_room, 240, 189, 1);
            return true;
        case LK_FIGHT.BroodNest:
            lk_add_prop(_room, 176, 156, 1);
            lk_add_prop(_room, 304, 130, 1);
            lk_add_prop(_room, 153, 131, 2);
            lk_add_prop(_room, 327, 155, 2);
            return true;
        case LK_FIGHT.TwinSeals:
            lk_add_prop(_room, 162, 111, 1);
            lk_add_prop(_room, 318, 175, 1);
            lk_add_prop(_room, 202, 174, 1);
            lk_add_prop(_room, 278, 112, 1);
            return true;
        case LK_FIGHT.RelayGuard:
            lk_add_prop(_room, 193, 131, 1);
            lk_add_prop(_room, 287, 155, 1);
            lk_add_prop(_room, 219, 105, 0);
            lk_add_prop(_room, 261, 181, 0);
            return true;
        case LK_FIGHT.HeatWorks:
            lk_add_prop(_room, 161, 108, 1);
            lk_add_prop(_room, 319, 178, 1);
            lk_add_prop(_room, 189, 174, 2);
            lk_add_prop(_room, 291, 112, 2);
            return true;
        case LK_FIGHT.ThreadedCrossing:
            lk_add_prop(_room, 240, 113, 1);
            lk_add_prop(_room, 240, 173, 1);
            lk_add_prop(_room, 173, 178, 0);
            lk_add_prop(_room, 307, 108, 0);
            return true;
        case LK_FIGHT.ShatteredColonnade:
            for (var _i = 0; _i < 3; _i++) {
                lk_add_prop(_room, 184 + 53 * _i, 101, 1);
                lk_add_prop(_room, 190 + 53 * _i, 185, 1);
            }
            lk_add_prop(_room, 212, 134, 0);
            lk_add_prop(_room, 268, 152, 0);
            return true;
        case LK_FIGHT.FloodPulse:
            lk_add_prop(_room, 136, 139, 1);
            lk_add_prop(_room, 344, 147, 1);
            return true;
    }
    return false;
}

function lk_reset_room_objective() {
    room_seals = [];
    seals_left = 0;
    seal_wait = 0;
    seal_spawns = 0;
    if (cell.kind != LK_ROOM.Fight || cell.encounter != LK_FIGHT.TwinSeals) return;
    room_seals = [{px: 122, py: 104, used: cell.clear}, {px: 358, py: 182, used: cell.clear}];
    if (!cell.clear) {
        seals_left = array_length(room_seals);
        seal_wait = 150;
        seal_spawns = 4;
    }
}

function lk_seals_step() {
    if (seals_left == 0 || wave == 0 || seal_spawns == 0) return;
    seal_wait -= 1;
    if (seal_wait > 0) return;
    var _side = seal_spawns mod 2;
    if (room_seals[_side].used) _side = 1 - _side;
    var _seal = room_seals[_side];
    var _y = _seal.py + (player.py < _seal.py ? 23 : -23);
    lk_spawn(floor_no >= 2 ? LK_ENEMY.Leech : LK_ENEMY.Skulk, _seal.px, _y, false, true);
    seal_spawns -= 1;
    seal_wait = 145;
    lk_ring(_seal.px, _seal.py, C_LILAC, 26, 24);
}

function lk_spawn_alternate_wave() {
    var _lineups = [
        [LK_ENEMY.Bulwark, LK_ENEMY.Sentry, LK_ENEMY.Charger, LK_ENEMY.Spitter],
        [LK_ENEMY.Sentry, LK_ENEMY.Spitter, LK_ENEMY.BroodHusk, LK_ENEMY.Skulk],
        [LK_ENEMY.BroodHusk, LK_ENEMY.Bulwark, LK_ENEMY.Skulk, LK_ENEMY.Skulk, LK_ENEMY.Wisp],
        [LK_ENEMY.Charger, LK_ENEMY.Sentry, LK_ENEMY.Bellkeeper, LK_ENEMY.Bulwark, LK_ENEMY.Charger],
        [LK_ENEMY.Bulwark, LK_ENEMY.Sentry, LK_ENEMY.Cauteriser, LK_ENEMY.Sentry, LK_ENEMY.Bruiser],
        [LK_ENEMY.Fractureling, LK_ENEMY.Wisp, LK_ENEMY.Threadbinder, LK_ENEMY.Wisp, LK_ENEMY.Charger],
        [LK_ENEMY.Bruiser, LK_ENEMY.Harpoon, LK_ENEMY.Prism, LK_ENEMY.Harpoon, LK_ENEMY.Leech],
        [LK_ENEMY.Fractureling, LK_ENEMY.Leech, LK_ENEMY.Prism, LK_ENEMY.Wisp, LK_ENEMY.Prism],
        [LK_ENEMY.Bulwark, LK_ENEMY.Harpoon, LK_ENEMY.Bellkeeper, LK_ENEMY.Cauteriser, LK_ENEMY.Leech],
        [LK_ENEMY.Prism, LK_ENEMY.Harpoon, LK_ENEMY.Threadbinder, LK_ENEMY.Prism, LK_ENEMY.Wisp],
        [LK_ENEMY.Bulwark, LK_ENEMY.Prism, LK_ENEMY.Bellkeeper, LK_ENEMY.Harpoon, LK_ENEMY.Fractureling, LK_ENEMY.Bruiser],
        [LK_ENEMY.Fractureling, LK_ENEMY.Prism, LK_ENEMY.Cauteriser, LK_ENEMY.Harpoon, LK_ENEMY.Cauteriser, LK_ENEMY.Prism]
    ];
    var _index = cell.encounter - LK_FIGHT.IndexGuard;
    var _enemies = _lineups[_index];
    var _side = player.px <= 240 ? 1 : -1;
    var _far_y = player.py < KEEP_MID_Y ? 184 : 100;
    var _near_y = 284 - _far_y;
    var _rows = [KEEP_MID_Y, _far_y, _near_y, _near_y, _far_y, KEEP_MID_Y];
    var _offsets = [61, 131, 128, -105, -103, -38];
    var _high = lk_route_role(cell) == LK_ROUTE_ROOM.High;
    for (var _i = 0; _i < array_length(_enemies); _i++) {
        var _x = 240 + _offsets[_i] * _side;
        var _y = _rows[_i];
        if (point_distance(player.px, player.py, _x, _y) < 53 || !is_undefined(lk_prop_at(_x, _y, 15))) _x = -1;
        lk_spawn(_enemies[_i], _x, _y, (_high && _i == 0) || _i < min(run_cycle, 2));
    }
    lk_sound(snd_gate, 1.12);
    return true;
}

function lk_spawn_objective_wave() {
    if (wave == 2 && lk_moss_reinforcements()) {
        // Fresh firing angles after the first group breaks. The low route stays a single fight.
        var _line = (cell.seed mod 2 == 0) ? 1 : -1;
        var _support = depth_no == 0 ? LK_ENEMY.Spitter : LK_ENEMY.Wisp;
        var _group = [LK_ENEMY.Sentry, _support, LK_ENEMY.Charger, LK_ENEMY.Skulk];
        if (cell.encounter == LK_FIGHT.Crossfire || cell.encounter == LK_FIGHT.ShieldLine) {
            _group = [LK_ENEMY.Spitter, LK_ENEMY.Charger, _support, LK_ENEMY.Charger];
        } else if (cell.encounter == LK_FIGHT.EliteHunt || cell.encounter == LK_FIGHT.BroodNest) {
            _group = [LK_ENEMY.Wisp, LK_ENEMY.Spitter, LK_ENEMY.Skulk, depth_no == 0 ? LK_ENEMY.Charger : LK_ENEMY.Bruiser];
        }
        var _col = [112, 368, 190, 290];
        var _row = [-52, 52, 35, -35];
        for (var _i = 0; _i < array_length(_group); _i++) {
            var _x = _col[_i];
            var _y = KEEP_MID_Y + _row[_i] * _line;
            if (point_distance(_x, _y, player.px, player.py) < 70 || !is_undefined(lk_prop_at(_x, _y, 14))) _x = -1;
            var _elite = _i < min(run_cycle, 2) || (lk_has_modifier(LK_OMEN.Deep) && depth_no > 0 && _i == 0);
            var _foe = lk_spawn(_group[_i], _x, _y, _elite);
            _foe.cool = 12 + _i * 7;
        }
        lk_sound(snd_gate, 1.12);
        return true;
    }
    if (cell.encounter >= LK_FIGHT.IndexGuard) return lk_spawn_alternate_wave();
    var _ranged = [LK_ENEMY.Spitter, LK_ENEMY.Sentry, LK_ENEMY.Wisp, LK_ENEMY.Prism, LK_ENEMY.Harpoon][floor_no];
    var _pursuer = [LK_ENEMY.Skulk, LK_ENEMY.Charger, LK_ENEMY.Leech, LK_ENEMY.Prism, LK_ENEMY.Bruiser][floor_no];
    var _side = player.px <= 240 ? 1 : -1;
    var _far_y = player.py < KEEP_MID_Y ? 181 : 104;
    var _near_y = 285 - _far_y;
    switch (cell.encounter) {
        case LK_FIGHT.ShieldLine:
            lk_spawn(LK_ENEMY.Bulwark, 240 + _side * 38, KEEP_MID_Y);
            lk_spawn(_ranged, 240 + _side * 93, 109);
            lk_spawn(_ranged, 240 + _side * 93, 176);
            lk_spawn(_pursuer, 150, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 330, _far_y, run_cycle >= 2);
            break;
        case LK_FIGHT.BroodNest:
            lk_spawn(LK_ENEMY.BroodHusk, 240, KEEP_MID_Y);
            lk_spawn(LK_ENEMY.Sentry, 240 + _side * 136, _near_y);
            lk_spawn(_pursuer, 137, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 343, _far_y, run_cycle >= 2);
            if (floor_no >= 2) lk_spawn(_ranged, 240, _near_y);
            break;
        case LK_FIGHT.TwinSeals:
            lk_spawn(_ranged, 105, 186);
            lk_spawn(_ranged, 375, 102);
            lk_spawn(_pursuer, 240, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 240 + _side * 93, _near_y == 104 ? 98 : 196, run_cycle >= 2);
            break;
        case LK_FIGHT.RelayGuard:
            lk_spawn(LK_ENEMY.Bellkeeper, 240 + _side * 28, KEEP_MID_Y);
            lk_spawn(LK_ENEMY.Sentry, 240 + _side * 106, 103);
            lk_spawn(LK_ENEMY.Sentry, 240 + _side * 106, 182, run_cycle >= 2);
            lk_spawn(_pursuer, 123, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 357, _far_y);
            break;
        case LK_FIGHT.HeatWorks:
            lk_spawn(LK_ENEMY.Cauteriser, 240 + _side * 122, KEEP_MID_Y);
            lk_spawn(LK_ENEMY.Bulwark, 240 + _side * 53, KEEP_MID_Y);
            lk_spawn(_pursuer, 121, _far_y, run_cycle >= 1);
            lk_spawn(_ranged, 359, _far_y, run_cycle >= 2);
            break;
        case LK_FIGHT.ThreadedCrossing:
            lk_spawn(LK_ENEMY.Threadbinder, 240 + _side * 50, KEEP_MID_Y);
            lk_spawn(LK_ENEMY.Sentry, 104, 115);
            lk_spawn(_ranged, 376, 171, run_cycle >= 2);
            lk_spawn(floor_no >= 3 ? LK_ENEMY.Fractureling : _pursuer, 152, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 328, _far_y);
            break;
        case LK_FIGHT.ShatteredColonnade:
            lk_spawn(LK_ENEMY.Fractureling, 147, KEEP_MID_Y, run_cycle >= 1);
            lk_spawn(LK_ENEMY.Fractureling, 333, KEEP_MID_Y, run_cycle >= 2);
            lk_spawn(LK_ENEMY.Harpoon, 103, _far_y);
            lk_spawn(LK_ENEMY.Harpoon, 377, _far_y);
            lk_spawn(LK_ENEMY.Prism, 240, KEEP_MID_Y);
            break;
        case LK_FIGHT.FloodPulse:
            lk_spawn(LK_ENEMY.Harpoon, 96, _far_y);
            lk_spawn(LK_ENEMY.Prism, 380, _far_y, run_cycle >= 2);
            lk_spawn(LK_ENEMY.Fractureling, 274, _far_y, run_cycle >= 1);
            lk_spawn(_pursuer, 204, _near_y);
            lk_spawn(_pursuer, 306, _near_y);
            break;
        default: return false;
    }
    lk_sound(snd_gate, 1.12);
    return true;
}

function lk_brood_step(_enemy) {
    if (_enemy.attack < 3 && _enemy.cool <= 0) {
        if (_enemy.tell == 0) {
            _enemy.tell = 36;
            lk_ring(_enemy.px, _enemy.py, C_MINT, 39, _enemy.tell);
            lk_charge_sound(_enemy);
        } else if (_enemy.tell == 1) {
            var _x = _enemy.px + (_enemy.attack mod 2 == 0 ? -25 : 25);
            var _y = _enemy.py + (_enemy.attack == 1 ? 25 : -25);
            lk_spawn(floor_no >= 2 ? LK_ENEMY.Leech : LK_ENEMY.Skulk, _x, _y, false, true);
            _enemy.attack += 1;
            _enemy.cool = 135;
            lk_sound(snd_gate, .83);
        }
        _enemy.tell -= 1;
    }
}

function lk_bulwark_guarding(_enemy) {
    return _enemy.dash == 0 && _enemy.cool <= 0;
}

function lk_spawn_hunt_bulwark() {
    // Take the inside edge of a side pillar, leaving the central lane to the other elite.
    var _x = player.px < 240 ? 143 : 337;
    var _y = player.py <= KEEP_MID_Y ? 190 : 99;
    if (point_distance(player.px, player.py, _x, _y) < 72) _x = 480 - _x;
    var _guard = lk_spawn(LK_ENEMY.Bulwark, _x, _y, true);
    _guard.hunt_facing = _guard.angle;
}

function lk_bulwark_facing(_enemy) {
    return variable_struct_exists(_enemy, "hunt_facing") ? _enemy.hunt_facing : _enemy.angle;
}

function lk_bulwark_blocks(_enemy, _shot) {
    if (_enemy.kind != LK_ENEMY.Bulwark || !lk_bulwark_guarding(_enemy) || _shot.kind == LK_SHOT.Wraith) return false;
    if (_shot.kind == LK_SHOT.Pierce) return false;
    return abs(angle_difference(lk_bulwark_facing(_enemy), _shot.angle + 180)) <= 64;
}

function lk_hunt_bulwark_step(_guard) {
    if (_guard.tell > 0) {
        _guard.tell -= 1;
        if (_guard.tell == 0) {
            var _aim = _guard.angle;
            lk_shot(false, _guard.px + lengthdir_x(_guard.radius, _aim), _guard.py + lengthdir_y(_guard.radius, _aim),
                _aim, lk_enemy_shot_speed(4.5), 2, C_PINK);
            // The plate drops on recoil. Even head-on shots can hurt it while it reloads.
            _guard.cool = 22;
            lk_sound(snd_harpoon);
        }
    } else if (_guard.cool <= 0 && lk_line_clear(_guard.px, _guard.py, player.px, player.py, 1.5)) {
        _guard.tell = 36;
        _guard.angle = lk_lock_ahead(_guard, lk_enemy_shot_speed(4.5), _guard.tell);
        lk_charge_sound(_guard);
    }
}

function lk_bulwark_step(_enemy, _toward, _range) {
    if (_enemy.dash > 0) {
        lk_enemy_walk(_enemy, 3.25, _enemy.angle);
        _enemy.dash -= 1;
    } else if (_enemy.tell > 0) {
        _enemy.tell -= 1;
        if (_enemy.tell == 0) {
            _enemy.dash = 16;
            _enemy.cool = 57;
        }
    } else {
        _enemy.angle -= clamp(angle_difference(_enemy.angle, _toward), -1.15, 1.15);
        if (_enemy.cool <= 0 && _range < 84) {
            _enemy.tell = 30;
            lk_charge_sound(_enemy);
        } else if (_range > 43) {
            lk_enemy_walk(_enemy, .80, _toward);
        }
    }
}

function lk_stationary_enemy(_kind) {
    return _kind == LK_ENEMY.BroodHusk || _kind == LK_ENEMY.FurnaceAnchor;
}

function lk_support_step(_e, _toward, _range) {
    var _kind = _e.kind;
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        if (_kind == LK_ENEMY.Bellkeeper) {
            for (var _i = 0; _i < array_length(enemies); _i++) {
                var _ally = enemies[_i];
                if (_ally.kind >= LK_ENEMY.Bulwark || !_ally.alive || _ally.tell > 0 || _ally.emerge > 0) continue;
                if (point_distance(_ally.px, _ally.py, _e.px, _e.py) > 108) continue;
                _ally.cool = min(_ally.cool, 3 + _i * 4);
                lk_ring(_ally.px, _ally.py, C_GOLD, 19, 19);
            }
            lk_ring(_e.px, _e.py, C_GOLD, 108, 22);
            lk_sound(snd_gate, 1.25);
        } else if (_kind == LK_ENEMY.Threadbinder && _e.attack == 1) {
            lk_enemy_burst(_e, 3, _e.angle, 18, 2.8, C_LILAC);
            lk_sound(snd_fire, 1.23);
            _e.attack = 0;
            _e.cool = 41;
            return;
        }
        _e.cool = _kind == LK_ENEMY.Bellkeeper ? 127 : 152;
        return;
    }
    if (_e.cool > 0) {
        if (_range < 62) lk_enemy_walk(_e, .88, _toward + 145);
        else if (_range > 126) lk_enemy_walk(_e, .82, _toward);
        return;
    }
    if (_kind == LK_ENEMY.Bellkeeper) {
        _e.tell = 37;
        lk_ring(_e.px, _e.py, C_GOLD, 49, _e.tell);
    } else if (_kind == LK_ENEMY.Cauteriser) {
        _e.tell = 43;
        var _x = clamp(player.px + move_x * 39, KEEP_LEFT + 11, KEEP_RIGHT - 11);
        var _y = clamp(player.py + move_y * 39, KEEP_TOP + 11, KEEP_BOTTOM - 11);
        lk_field(_x, _y, 0, _e.tell, 1, 28, C_PINK, true);
    } else {
        var _left = undefined;
        var _right = undefined;
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _ally = enemies[_i];
            if (_ally == _e || !_ally.alive || _ally.emerge > 0) continue;
            if (is_undefined(_left) || _ally.px < _left.px) _left = _ally;
            if (is_undefined(_right) || _ally.px > _right.px) _right = _ally;
        }
        if (is_undefined(_left)) {
            _e.tell = 23;
            _e.angle = lk_lead(_e, 2.8);
            _e.attack = 1;
        } else {
            if (_left == _right) _right = _e;
            _e.tell = 43;
            lk_lane(_left.px, _left.py, _right.px, _right.py, 5, _e.tell, 24, 2, C_LILAC, _e, _left, _right);
            lk_ring(_left.px, _left.py, C_LILAC, 21, _e.tell);
            lk_ring(_right.px, _right.py, C_LILAC, 21, _e.tell);
        }
    }
    lk_charge_sound(_e);
}

function lk_fracture(_e, _angle) {
    for (var _side = -1; _side <= 1; _side += 2) {
        for (var _turn = 0; _turn < 4; _turn++) {
            var _a = _angle + _side * (58 + _turn * 40);
            var _x = _e.px + lengthdir_x(15, _a);
            var _y = _e.py + lengthdir_y(15, _a);
            if (!lk_keep_bounds(_x, _y, 7, false) || !is_undefined(lk_prop_at(_x, _y, 7))) continue;
            var _shard = lk_spawn(LK_ENEMY.Skulk, _x, _y, false, true, .65);
            _shard.emerge = 15;
            _shard.color = C_BLUE;
            _shard.angle = _a;
            _shard.dash = 9;
            break;
        }
    }
}

function lk_rupture_vent(_side) {
    return _side == 0 ? {px: 153, py: 174} : {px: 327, py: 112};
}

function lk_alternate_room_hazards(_archive, _pattern) {
    if (_archive && _pattern == 0) {
        var _x = hazard_side == 0 ? 151 : 329;
        lk_field(_x, 112, 1, 42, 1, 26, C_LILAC, true);
        lk_field(480 - _x, 174, 1, 42, 1, 26, C_LILAC, true);
    } else if (_archive) {
        var _x = hazard_side == 0 ? 192 : 288;
        lk_lane(_x, KEEP_TOP, _x, KEEP_BOTTOM, 8, 44, 27, 1, C_LILAC);
    } else if (_pattern == 0) {
        for (var _i = hazard_side; _i < 3; _i += 2) {
            var _y = 87 + _i * 56;
            lk_lane(KEEP_LEFT, _y, KEEP_RIGHT, _y, 16, 51, 42, 2, C_BLUE);
        }
    } else {
        for (var _i = hazard_side; _i < 4; _i += 2) {
            var _x = 109 + _i * 87;
            lk_lane(_x, KEEP_TOP, _x, KEEP_BOTTOM, 9, 36 + _i * 9, 43, 2, C_TEAL);
        }
    }
    hazard_side = 1 - hazard_side;
    hazard_wait = _archive ? 157 : 133;
}

function lk_room_hazard_step() {
    if (cell.clear) return;
    var _alternate = cell.kind == LK_ROOM.Fight && cell.encounter >= LK_FIGHT.IndexGuard;
    var _machinery = cell.kind == LK_ROOM.Gauntlet && depth_no == 4 && lk_route_mark_id() == 3;
    if (_alternate || _machinery) {
        if (wave > 0) {
            hazard_wait -= 1;
            if (hazard_wait <= 0) {
                var _pattern = _machinery ? wave mod 2 : (cell.encounter - LK_FIGHT.IndexGuard) mod 2;
                lk_alternate_room_hazards(_alternate && cell.encounter < LK_FIGHT.IntakeWatch, _pattern);
            }
        }
        return;
    }
    var _rupture = lk_rupture_room();
    var _flood = cell.kind == LK_ROOM.Fight && cell.encounter == LK_FIGHT.FloodPulse && wave > 0;
    if (!_rupture && !_flood && cell.kind != LK_ROOM.Gauntlet) return;
    hazard_wait -= 1;
    if (hazard_wait > 0) return;
    if (_rupture) {
        var _vent = lk_rupture_vent(hazard_side);
        lk_field(_vent.px, _vent.py, 1, 36, 1, 17, lk_theme_tint(floor_no), true);
        hazard_side = 1 - hazard_side;
        hazard_wait = 160;
    } else if (_flood) {
        for (var _i = 0; _i < 3; _i++) {
            if (_i mod 2 != hazard_side) continue;
            var _y = 87 + _i * 56;
            lk_lane(KEEP_LEFT, _y, KEEP_RIGHT, _y, 27, 58, 38, 2, C_BLUE);
        }
        hazard_side = 1 - hazard_side;
        hazard_wait = 174;
    } else {
        lk_gauntlet_hazards();
        hazard_wait = 190 - min(floor_no, 3) * 11 - min(run_cycle, 4) * 6;
    }
}

function lk_gauntlet_hazards() {
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

function lk_bomb_trail(_angle, _count, _radius, _color, _windup = 32) {
    var _spacing = _radius * 2 + 12;
    var _dx = lengthdir_x(_spacing, _angle);
    var _dy = lengthdir_y(_spacing, _angle);
    var _half = (_count - 1) * .5;
    var _margin_x = 8 + abs(_dx) * _half;
    var _margin_y = 8 + abs(_dy) * _half;
    // Shift the whole trail at walls so the marked blasts don't bunch up.
    var _x = clamp(player.px, KEEP_LEFT + _margin_x, KEEP_RIGHT - _margin_x);
    var _y = clamp(player.py, KEEP_TOP + _margin_y, KEEP_BOTTOM - _margin_y);
    for (var _i = 0; _i < _count; _i++) {
        lk_field(_x + (_i - _half) * _dx, _y + (_i - _half) * _dy,
            1, _windup + _i * 12, 2, _radius, _color, true);
    }
}

function lk_sanctum_pattern(_e, _phase_two) {
    var _attack = _e.attack mod 3;
    var _px = player.px + move_x * 24;
    var _py = player.py + move_y * 24;
    switch (floor_no) {
        case 0:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 13, _e.angle + (_e.attack mod 2 == 0 ? 63 : -63), 2.35, C_GOLD);
            } else if (_attack == 1) {
                lk_enemy_burst(_e, 1, _e.angle, 0, 3.4, C_MINT, LK_SHOT.ThornSeed, 2);
                lk_enemy_burst(_e, 4, _e.angle, 24, 2.6, C_PINK);
            } else {
                lk_bomb_trail(_e.angle + 90, 3, 18, C_MINT, 28);
            }
            break;
        case 1:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 15, _e.angle + 20, 2.12, C_PINK);
            } else if (_attack == 1) {
                lk_bomb_trail(_e.angle, 4, 17, C_GOLD);
            } else {
                lk_enemy_burst(_e, 9, _e.angle, 7, 3.45, C_PINK);
                lk_enemy_burst(_e, 9, _e.angle + 180, 14, 2.46, C_GOLD, LK_SHOT.Blast);
            }
            break;
        case 2:
            if (_attack == 0) {
                lk_enemy_open_ring(_e, 15, _e.angle - 20, 1.95, C_LILAC);
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
            if (_phase_two && (_attack == 1 || !lk_standard_contract())) {
                lk_enemy_burst(_e, 5, _e.angle, 16, 3.7, C_PINK, LK_SHOT.Blast);
            }
            break;
    }
}

function lk_boss_ability(_e) {
    if (_e.guardian != LK_GUARDIAN.Original) return lk_guardian_ability(_e);
    if (depth_no == 0 && _e.transition > 0) return "STAGGERED";
    if (_e.transition > 0) return _e.final_phase == 1 ? "FURNACE ANCHORS" : "ANCHOR OVERLOAD";
    if (_e.tell <= 0) return "";
    if (floor_no == 4) {
        return ["GOLDEN RUPTURE", "CINDER HALO", "ROYAL VOLLEY", "CROWN PRISM", "SOVEREIGN CHARGE"]
            [_e.attack mod (3 + _e.final_phase)];
    }
    if (floor_no == 3) {
        return ["GLASS SURGE", "FEN QUAKES", "GILDED CROSSFIRE", "SHATTER RING"][_e.attack mod 4];
    }
    var _moves = [
        ["MOSS CHARGE", "THORN FAN", "ROOT TRAP", "ROOT RING"],
        ["SEED HALO", "THORN SALVO", "ROOT ERUPTION"],
        ["RIVET MINES", "SHRAPNEL RING", "TIN VOLLEY"],
        ["FURNACE HALO", "COAL SEAMS", "BELLFIRE"],
        ["VEIL STEP", "PRISM BOUNCE", "VEIL SIGILS"],
        ["PALE HALO", "REGENT'S STEP", "HOLLOW SIGIL"]
    ];
    var _set = _moves[depth_no];
    return _set[_e.attack mod lk_boss_rotation(_e)];
}

function lk_boss_rotation(_e) {
    return depth_no == 0 && _e.enraged ? 4 : 3;
}

function lk_crown_anchors() {
    var _count = 0;
    for (var _i = 0; _i < array_length(enemies); _i++) {
        if (enemies[_i].kind == LK_ENEMY.FurnaceAnchor && enemies[_i].alive) _count += 1;
    }
    return _count;
}

function lk_crown_damage(_e, _power) {
    // Give each threshold its setup step even if several shots land simultaneously.
    var _limit = _e.final_phase == 0 ? floor(_e.max_hp * .69) : floor(_e.max_hp * .34);
    if (_e.final_phase == 2 && _e.transition == 0) return _power;
    if (_e.transition > 0) _limit = _e.final_phase == 1 ? _limit + 1 : 1;
    return min(_power, max(0, _e.hp - _limit));
}

function lk_anchor_step(_e) {
    if (_e.tell == 0 && _e.cool <= 0) {
        var _end_x = _e.px < 240 ? KEEP_RIGHT - 8 : KEEP_LEFT + 8;
        var _end_y = clamp(player.py + move_y * 28, KEEP_TOP + 14, KEEP_BOTTOM - 14);
        _e.tell = 49;
        _e.cool = 163;
        lk_lane(_e.px, _e.py, _end_x, _end_y, 8, _e.tell, 30, 2, C_GOLD, _e);
        lk_ring(_e.px, _e.py, C_GOLD, 29, _e.tell);
        lk_charge_sound(_e);
    }
}

function lk_crown_attack(_e) {
    if (_e.transition > 0) {
        _e.transition -= 1;
        return;
    }
    var _phase = _e.hp > floor(_e.max_hp * .69) ? 0 : (_e.hp > floor(_e.max_hp * .34) ? 1 : 2);
    if (_phase != _e.final_phase) {
        _e.final_phase = _phase;
        _e.attack = 0;
        _e.dash = 0;
        _e.echo = 0;
        _e.tell = 0;
        _e.transition = _phase == 1 ? 30 : 46;
        _e.cool = 41;
        _e.angle = lk_lead(_e, 3.4);
        banner = _phase == 1 ? "BREAK FURNACE ANCHORS" : "THE CROWN SHATTERS";
        banner_time = 98;
        lk_ring(_e.px, _e.py, _phase == 1 ? C_GOLD : C_PINK, 96, 37);
        lk_sound(snd_gate, _phase == 1 ? .73 : .59);
        shaking = 10;
        if (_phase == 1) {
            lk_spawn(LK_ENEMY.FurnaceAnchor, 92, 141, false, true);
            lk_spawn(LK_ENEMY.FurnaceAnchor, 388, 145, false, true);
        } else {
            for (var _i = 0; _i < array_length(enemies); _i++) {
                var _anchor = enemies[_i];
                if (_anchor.kind != LK_ENEMY.FurnaceAnchor || !_anchor.alive) continue;
                _anchor.alive = false;
                var _end_y = _anchor.px < 240 ? 192 : 94;
                var _end_x = _anchor.px < 240 ? 412 : 68;
                lk_lane(_anchor.px, _anchor.py, _end_x, _end_y, 11, 45, 36, 2, C_PINK);
                lk_sparks(_anchor.px, _anchor.py - 7, C_GOLD, 20, 2);
            }
            lk_spawn(LK_ENEMY.Prism, 392, 93);
        }
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
        if ((_e.attack - 1) mod (3 + _phase) == 3) {
            // Sweep across the locked aim in five beats, including the opening pair.
            if (_e.echo mod 6 == 0) {
                var _sweep = (_e.echo / 6 - 2) * 32;
                lk_enemy_burst(_e, 2, _e.angle + _sweep, 14, 2.23, C_LILAC, LK_SHOT.Ricochet);
            }
        } else if (_e.echo == 0) {
            lk_enemy_open_ring(_e, 12, _e.angle + 22, 2.18, C_LILAC);
        }
    }
    if (_e.tell > 0) {
        if (_e.tell != 1) return;
        var _slot = _e.attack mod (3 + _phase);
        switch (_slot) {
            case 0:
                lk_bomb_trail(_e.angle + 90, _phase == 0 ? 3 : 4, 17, C_GOLD);
                break;
            case 1:
                lk_enemy_open_ring(_e, 15, _e.angle, 2.26, C_PINK);
                _e.echo = _phase > 0 ? 18 : 24;
                break;
            case 2:
                lk_enemy_burst(_e, 8, _e.angle, 11, 3.45, C_GOLD, LK_SHOT.Blast);
                lk_enemy_burst(_e, 7, _e.angle + 175, 11, 2.92, C_PINK);
                break;
            case 3:
                lk_enemy_burst(_e, 2, _e.angle + 64, 14, 2.23, C_LILAC, LK_SHOT.Ricochet);
                _e.echo = 24;
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
        lk_slow_enemy(_e, 106);
        var _a = point_direction(player.px, player.py, _e.px, _e.py);
        lk_enemy_damage(_e, ceil(7 * player.damage_scale), _a, true);
        if (_e.kind != LK_ENEMY.Boss && !lk_stationary_enemy(_e.kind)) {
            lk_move(_e, lengthdir_x(19, _a), lengthdir_y(19, _a), _e.radius);
        }
    }
}
