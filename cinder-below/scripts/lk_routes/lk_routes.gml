enum LK_ROUTE_ROOM { None, High, Low, Fork, Shortcut, Toll, Trial, CircuitReward }

#macro LK_SHORTCUT_COST 7
#macro LK_ARCHIVE_COST 9

function lk_route_progress() {
    if (!variable_struct_exists(player, "route_progress") || player.route_progress.cycle != run_cycle) {
        player.route_progress = {cycle: run_cycle, marks: [false, false, false], spindle: false, stage: -1, variant: 0};
    }
    return player.route_progress;
}

function lk_route_variant() {
    var _progress = lk_route_progress();
    return _progress.stage == depth_no ? _progress.variant : 0;
}

function lk_route_stage_name() {
    switch (lk_route_variant()) {
        case 1: return "BURIED ARCHIVE";
        case 2: return "DROWNED FURNACE";
    }
    return stage_names[depth_no];
}

function lk_route_tint() {
    switch (lk_route_variant()) {
        case 1: return make_color_rgb(166, 183, 133);
        case 2: return make_color_rgb(90, 181, 190);
    }
    return lk_theme_tint(floor_no);
}

function lk_route_role(_room) {
    return variable_struct_exists(_room, "route_role") ? _room.route_role : LK_ROUTE_ROOM.None;
}

function lk_route_join(_from, _dir, _to) {
    dungeon[_from].exits[_dir] = _to;
    dungeon[_to].exits[(_dir + 2) mod 4] = _from;
}

function lk_build_route_choices(_forward, _side) {
    var _priced = depth_no == 3 || depth_no == 5 || depth_no == 7;
    var _fork = lk_link_room(1, LK_ROOM.Passage, _side, true);
    var _middle = lk_link_room(_fork, _priced ? LK_ROOM.Passage : LK_ROOM.Fight, _forward, true);
    var _join = lk_link_room(_middle, LK_ROOM.Passage, _forward, true);
    lk_route_join(_join, (_side + 2) mod 4, 3);
    dungeon[2].route_role = LK_ROUTE_ROOM.High;
    dungeon[_fork].route_role = _priced ? LK_ROUTE_ROOM.Shortcut : LK_ROUTE_ROOM.Fork;
    dungeon[_join].route_role = dungeon[_fork].route_role;
    dungeon[_middle].route_role = _priced ? LK_ROUTE_ROOM.Toll : LK_ROUTE_ROOM.Low;
    if (_priced) dungeon[_middle].toll_paid = false;

    if (depth_no == 0) {
        for (var _i = 0; _i < 3; _i++) dungeon[_i + 1].route_mark = _i;
        // Both sides of the fork carry the same inscription.
        dungeon[_middle].route_mark = 1;
        return;
    }

    // The trial loops back to the main path through its reward room.
    var _station = lk_stage_waystation();
    var _duel = depth_no != 4 && (_station == LK_ROOM.SupplyPost || _station == LK_ROOM.Armory);
    var _trial_kind = _duel ? LK_ROOM.Duel : LK_ROOM.Gauntlet;
    var _outer = (_side + 2) mod 4;
    var _trial = lk_link_room(3, _trial_kind, _outer, true);
    var _reward = lk_link_room(_trial, LK_ROOM.Relic, _forward, true);
    // The far-side exit stays sealed until the trial is cleared.
    lk_route_join(_reward, _side, 4);
    dungeon[_trial].route_role = LK_ROUTE_ROOM.Trial;
    dungeon[_reward].route_role = LK_ROUTE_ROOM.CircuitReward;
    dungeon[_reward].route_trial = _trial;
    if (depth_no == 4) dungeon[_trial].route_mark = 3;
}

function lk_route_door_available(_dir) {
    var _next = cell.exits[_dir];
    return _next >= 0 && lk_route_entry_available(dungeon[_next]);
}

function lk_route_entry_available(_room) {
    switch (lk_route_role(_room)) {
        case LK_ROUTE_ROOM.Toll: return _room.toll_paid;
        case LK_ROUTE_ROOM.CircuitReward: return dungeon[_room.route_trial].clear;
    }
    return true;
}

function lk_route_door_hint(_dir) {
    var _next = cell.exits[_dir];
    if (_next < 0) return undefined;
    var _target = dungeon[_next];
    switch (lk_route_role(_target)) {
        case LK_ROUTE_ROOM.High:
            if (_target.clear) return "ELITE / CLEARED";
            if (variable_struct_exists(_target, "hunt_weapon")) return "ELITE / " + weapons[_target.hunt_weapon].name;
            var _variant = lk_route_variant();
            var _reward = _variant == 1 ? "FITTED WEAPON" : (_variant == 2 ? "+2 WEAPON" : "WEAPON");
            return "ELITE / " + _reward;
        case LK_ROUTE_ROOM.Fork:
        case LK_ROUTE_ROOM.Low:
            return "SIDE ROUTE";
        case LK_ROUTE_ROOM.Shortcut:
            var _passage = undefined;
            for (var _i = 0; _i < 4; _i++) {
                var _index = _target.exits[_i];
                if (_index < 0 || lk_route_role(dungeon[_index]) != LK_ROUTE_ROOM.Toll) continue;
                _passage = dungeon[_index];
                break;
            }
            return is_undefined(_passage) || !_passage.toll_paid ? "SHORTCUT / " + string(LK_SHORTCUT_COST) + "G" : "SHORTCUT / PAID";
        case LK_ROUTE_ROOM.Toll:
            return _target.toll_paid ? "SHORTCUT / PAID" : "SHORTCUT / " + string(LK_SHORTCUT_COST) + "G";
        case LK_ROUTE_ROOM.Trial:
            return variable_struct_exists(_target, "route_mark") ? "SLUICE TRIAL / SPINDLE" : "TRIAL / WEAPON + RELIC";
        case LK_ROUTE_ROOM.CircuitReward:
            return lk_route_door_available(_dir) ? "RELIQUARY" : "TRIAL REQUIRED";
    }
    return undefined;
}

function lk_route_room_name(_room) {
    if (_room.kind == LK_ROOM.Passage) {
        if (lk_route_role(_room) == LK_ROUTE_ROOM.Fork) return "SIDE PASSAGE";
        return "TOLL PASSAGE";
    }
    if (_room.kind == LK_ROOM.Gauntlet && variable_struct_exists(_room, "route_mark")) return "SLUICE MACHINERY";
    if (_room.kind != LK_ROOM.Fight) return "";
    var _template = _room.encounter - LK_FIGHT.IndexGuard;
    var _names = ["INDEX GUARD", "SCRIPTORIUM", "SEALED STACKS", "SCRIBE ESCORT", "TABLET WATCH", "BROKEN ALPHABET",
        "INTAKE WATCH", "BACKWASH", "SLUICE CREW", "SPILLWAY", "PUMP GUARD", "FLOODED FORGE"];
    if (_template < 0 || _template >= array_length(_names)) return "";
    return _names[_template];
}

function lk_route_archive_count() {
    var _marks = lk_route_progress().marks;
    return _marks[0] + _marks[1] + _marks[2];
}

function lk_route_mark_id() {
    if (variable_struct_exists(cell, "route_mark")) return cell.route_mark;
    // Older checkpoints retain their grid and receive clues in the original rooms.
    if (array_length(dungeon) > 2 && variable_struct_exists(dungeon[2], "route_role")) return -1;
    if (depth_no == 0 && cell.kind == LK_ROOM.Fight && cell_index >= 1 && cell_index <= 3) return cell_index - 1;
    if (depth_no == 4 && (cell.kind == LK_ROOM.Gauntlet || cell.kind == LK_ROOM.Duel)) return 3;
    return -1;
}

function lk_route_marker() {
    if (!cell.clear) return undefined;
    var _progress = lk_route_progress();
    var _mark = lk_route_mark_id();
    if (_mark >= 0 && _mark < 3 && !_progress.marks[_mark]) {
        return {px: 240, py: 119, label: "READ INSCRIPTION", detail: "THREE INSCRIPTIONS OPEN AN ARCHIVE AFTER STAGE 2",
            ready: true, mark: _mark, variant: 0};
    }
    if (_mark == 3 && !_progress.spindle) {
        return {px: 240, py: 119, label: "TAKE SLUICE SPINDLE", detail: "FITS THE SEALED SLUICE AFTER STAGE 6",
            ready: true, mark: _mark, variant: 0};
    }
    if (cell.kind != LK_ROOM.Boss) return undefined;
    if (depth_no == 1) {
        var _count = lk_route_archive_count();
        return {px: 179, py: 113, label: "OPEN BURIED ARCHIVE / " + string(LK_ARCHIVE_COST) + "G",
            detail: _count < 3 ? string(_count) + "/3 INSCRIPTIONS FROM STAGE 1" : "ALTERNATE DESCENT / STAGE 3",
            ready: _count == 3 && player.coins >= LK_ARCHIVE_COST, mark: -1, variant: 1};
    }
    if (depth_no == 5) {
        return {px: 301, py: 113, label: "OPEN DROWNED FURNACE",
            detail: _progress.spindle ? "ALTERNATE DESCENT / STAGE 7" : "NEEDS THE SPINDLE FROM STAGE 5 MACHINERY",
            ready: _progress.spindle, mark: -1, variant: 2};
    }
    return undefined;
}

function lk_route_nearby() {
    if (!cell.clear) return undefined;
    var _marker = lk_route_marker();
    if (!is_undefined(_marker) && point_distance(player.px, player.py, _marker.px, _marker.py) < 22) {
        _marker.kind = "route";
        _marker.toll = -1;
        return _marker;
    }
    var _door_x = [KEEP_RIGHT - 10, 240, KEEP_LEFT + 10, 240];
    var _door_y = [KEEP_MID_Y, KEEP_BOTTOM - 10, KEEP_MID_Y, KEEP_TOP + 10];
    for (var _dir = 0; _dir < 4; _dir++) {
        var _next = cell.exits[_dir];
        if (_next < 0 || lk_route_role(dungeon[_next]) != LK_ROUTE_ROOM.Toll || dungeon[_next].toll_paid) continue;
        var _x = _door_x[_dir];
        var _y = _door_y[_dir];
        if (point_distance(player.px, player.py, _x, _y) >= 28) continue;
        return {kind: "route", px: _x, py: _y, label: "OPEN SHORTCUT / " + string(LK_SHORTCUT_COST) + "G",
            detail: "BYPASS THE ELITE HUNT", ready: player.coins >= LK_SHORTCUT_COST, toll: _next, mark: -1, variant: 0};
    }
    return undefined;
}

function lk_route_interact(_action) {
    if (!_action.ready) {
        var _message = _action.detail;
        if (_action.toll >= 0) _message = "NEED " + string(LK_SHORTCUT_COST) + "G";
        else if (_action.variant == 1 && lk_route_archive_count() == 3) _message = "NEED " + string(LK_ARCHIVE_COST) + "G";
        lk_floater(_action.px, _action.py - 10, _message, C_PINK);
        return;
    }
    var _progress = lk_route_progress();
    if (_action.toll >= 0) {
        dungeon[_action.toll].toll_paid = true;
        player.coins -= LK_SHORTCUT_COST;
    } else if (_action.variant > 0) {
        if (_action.variant == 1) player.coins -= LK_ARCHIVE_COST;
        _progress.stage = depth_no + 1;
        _progress.variant = _action.variant;
        depth_no += 1;
        lk_portal_recover();
        lk_start_floor();
        lk_sound(snd_portal);
        return;
    } else {
        if (_action.mark == 3) _progress.spindle = true;
        else {
            _progress.marks[_action.mark] = true;
            lk_floater(_action.px, _action.py - 11, "INSCRIPTIONS " + string(lk_route_archive_count()) + "/3", C_GOLD);
        }
        lk_discover(_action.mark);
    }
    lk_sparks(_action.px, _action.py, C_GOLD, 14, 1.5);
    lk_sound(snd_gate);
    lk_save_checkpoint();
}

function lk_route_clear_reward() {
    var _variant = lk_route_variant();
    if (_variant == 0 || lk_route_role(cell) != LK_ROUTE_ROOM.High) return;
    var _pick = cell.seed mod 5;
    if (_variant == 1) {
        var _items = [[7, LK_FIT.Edge], [8, LK_FIT.Cold], [14, LK_FIT.Fuse],
            [18, LK_FIT.Rebound], [22, LK_FIT.Clock]];
        var _item = _items[_pick];
        lk_drop(LK_LOOT.Weapon, 240, 158, _item[0], 1, _item[1]);
    } else {
        var _pool = [9, 11, 17, 19, 21];
        lk_drop(LK_LOOT.Weapon, 240, 158, _pool[_pick], 2);
    }
}
