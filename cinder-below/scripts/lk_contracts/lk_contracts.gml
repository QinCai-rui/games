enum LK_CONTRACT { Delve, Iron, Arsenal, Daily, Endless }

#macro LK_CHECKPOINT "lantern_run_v1.dat"

function lk_contract_list() {
    return [
        {name: "THE MAIN DELVE", note: "EIGHT STAGES. CHOOSE YOUR ARMORY.", tint: C_GOLD},
        {name: "IRON TRIAL", note: "FASTER FOES. HALF ARMOR. WOUNDS STAY.", tint: C_PINK},
        {name: "ARSENAL RUN", note: "A NEW WEAPON PAIR AFTER EACH COMBAT.", tint: C_TEAL},
        {name: "DAILY CONTRACT", note: "ONE SHARED DUNGEON SEED EACH DAY.", tint: C_BLUE},
        {name: "ENDLESS KEEP", note: "EVERY CYCLE ADDS ELITES AND PRESSURE.", tint: C_LILAC}
    ];
}

function lk_date_seed() {
    var _now = date_current_datetime();
    return date_get_year(_now) * 10000 + date_get_month(_now) * 100 + date_get_day(_now);
}

function lk_run_depth() {
    return run_cycle * array_length(stage_names) + depth_no + 1;
}

function lk_contract_setup() {
    run_contract = chosen_contract;
    run_cycle = 0;
    run_seed = run_contract == LK_CONTRACT.Daily ? lk_date_seed() : irandom_range(1000, 1800000000);
    if (run_contract == LK_CONTRACT.Daily) random_set_seed(run_seed);
    if (run_contract == LK_CONTRACT.Iron) {
        player.max_armor = max(1, ceil(player.max_armor * .50));
        player.armor = player.max_armor;
    }
}

function lk_contract_record() {
    var _depth = lk_run_depth();
    contract_best[run_contract] = max(contract_best[run_contract], _depth);
    if (run_contract == LK_CONTRACT.Delve) best_floor = max(best_floor, _depth);
    if (run_contract == LK_CONTRACT.Daily) {
        if (daily_record_date != run_seed) {
            daily_record_date = run_seed;
            daily_record_depth = 0;
        }
        daily_record_depth = max(daily_record_depth, _depth);
    }
}

function lk_contract_loot() {
    if (run_contract != LK_CONTRACT.Arsenal) return;
    var _tier = clamp(floor(depth_no / 3), 0, 3);
    player.arms[0] = irandom(array_length(weapons) - 1);
    player.arms[1] = (player.arms[0] + irandom_range(1, array_length(weapons) - 1)) mod array_length(weapons);
    player.temper[0] = _tier;
    player.temper[1] = _tier;
    player.energy = min(player.max_energy, player.energy + 17);
    weapon_found[player.arms[0]] = true;
    weapon_found[player.arms[1]] = true;
    lk_save();
    lk_floater(player.px, player.py - 24, "ARSENAL ROTATED", C_TEAL);
}

function lk_contract_open(_return) {
    contract_from = _return;
    contract_cursor = chosen_contract;
    mode = LK_MODE.Contract;
    lk_sound(snd_click);
}

function lk_contract_available(_index) {
    return _index != LK_CONTRACT.Endless || wins > 0;
}

function lk_contract_step() {
    if (back_pressed) {
        mode = contract_from;
        return;
    }
    var _count = array_length(contracts);
    if (menu_left || menu_up) contract_cursor = (contract_cursor + _count - 1) mod _count;
    if (menu_right || menu_down) contract_cursor = (contract_cursor + 1) mod _count;
    if (pointer_click && pointer_x >= 49 && pointer_x <= 432) {
        if (pointer_y >= 57 && pointer_y < 203) contract_cursor = clamp(floor((pointer_y - 57) / 29), 0, _count - 1);
        else if (pointer_x >= 168 && pointer_x <= 312 && pointer_y >= 219 && pointer_y <= 243) accept_pressed = true;
    }
    if (!accept_pressed) return;
    if (!lk_contract_available(contract_cursor)) {
        lk_sound(snd_click, .65);
        return;
    }
    chosen_contract = contract_cursor;
    mode = LK_MODE.Select;
    lk_sound(snd_click);
}

function lk_draw_contracts() {
    draw_sprite(spr_cover, 0, 0, 0);
    draw_set_alpha(.83);
    lk_rect(0, 0, 479, 269, C_INK);
    draw_set_alpha(1);
    lk_ornament(61, 29, 419, C_EDGE);
    lk_text_center("CHOOSE A CONTRACT", 240, 38, C_PAPER, true);
    for (var _i = 0; _i < array_length(contracts); _i++) {
        var _cy = 57 + _i * 29;
        var _card = contracts[_i];
        var _active = _i == contract_cursor;
        var _unlocked = lk_contract_available(_i);
        lk_panel(49, _cy, 432, _cy + 25, _active, _card.tint);
        lk_diamond(58, _cy + 12, 2, _unlocked ? _card.tint : C_MUTED);
        lk_text(_card.name, 68, _cy + 3, _unlocked ? _card.tint : C_MUTED);
        var _best = _i == LK_CONTRACT.Daily
            ? (daily_record_date == lk_date_seed() ? daily_record_depth : 0)
            : contract_best[_i];
        if (_best > 0) lk_text_right("BEST " + string(_best), 424, _cy + 3, C_MUTED);
        lk_text(_unlocked ? _card.note : "CLEAR THE KEEP TO UNLOCK.", 68, _cy + 14, C_PAPER);
    }
    var _locked = !lk_contract_available(contract_cursor);
    lk_button(_locked ? "LOCKED" : "CHOOSE KEEPER", 168, 219, 312, !_locked);
    lk_text("ESC BACK", 49, 226, C_MUTED);
    lk_text_right("W/S SELECT", 432, 226, C_MUTED);
}

function lk_save_checkpoint() {
    if (!cell.clear) return false;
    var _target = player.target;
    player.target = undefined;
    var _record = {
        version: 1, keeper: hero_id, contract: run_contract, cycle: run_cycle,
        seed: run_seed, stage_index: depth_no, grid: dungeon, current: cell_index,
        body: player, timer: world_tick, clears: rooms_cleared, defeated: kills
    };
    var _json = json_stringify(_record);
    player.target = _target;
    var _buffer = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _json);
    var _temporary = LK_CHECKPOINT + ".next";
    if (file_exists(_temporary)) file_delete(_temporary);
    buffer_save(_buffer, _temporary);
    buffer_delete(_buffer);
    if (!file_exists(_temporary)) return false;

    // Keep the previous checkpoint recoverable until its replacement is in place.
    var _previous = LK_CHECKPOINT + ".previous";
    if (file_exists(LK_CHECKPOINT)) {
        if (file_exists(_previous)) file_delete(_previous);
        file_rename(LK_CHECKPOINT, _previous);
        if (file_exists(LK_CHECKPOINT)) {
            file_delete(_temporary);
            return false;
        }
    }
    file_rename(_temporary, LK_CHECKPOINT);
    if (!file_exists(LK_CHECKPOINT)) {
        if (file_exists(_previous)) file_rename(_previous, LK_CHECKPOINT);
        return false;
    }
    if (file_exists(_previous)) file_delete(_previous);
    checkpoint_available = true;
    return true;
}

function lk_load_checkpoint() {
    var _source = LK_CHECKPOINT;
    if (!file_exists(_source)) _source += ".previous";
    if (!file_exists(_source)) return false;
    var _buffer = buffer_load(_source);
    if (_buffer < 0) return false;
    var _json = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    var _saved = undefined;
    var _stage = undefined;
    try {
        _saved = json_parse(_json);
        if (!is_struct(_saved) || _saved.version != 1 || !is_array(_saved.grid) || !is_struct(_saved.body)) return false;
        // Older desktop checkpoints used the built-in name "depth".
        _stage = variable_struct_exists(_saved, "stage_index") ? _saved.stage_index : variable_struct_get(_saved, "depth");
        if (!is_real(_stage) || _stage != floor(_stage) || _stage < 0 || _stage >= array_length(stage_names)) return false;
        if (_saved.current < 0 || _saved.current >= array_length(_saved.grid) || !_saved.grid[_saved.current].clear
            || _saved.keeper < 0 || _saved.keeper >= array_length(heroes)
            || _saved.contract < 0 || _saved.contract >= array_length(contracts)) return false;
    } catch (_error) {
        return false;
    }
    hero_id = _saved.keeper;
    run_contract = _saved.contract;
    chosen_contract = run_contract;
    run_cycle = _saved.cycle;
    run_seed = _saved.seed;
    depth_no = _stage;
    floor_no = lk_stage_biome(depth_no);
    dungeon = _saved.grid;
    player = _saved.body;
    if (!variable_struct_exists(player, "move_pace")) player.move_pace = variable_struct_get(player, "speed");
    player.target = undefined;
    var _x = player.px;
    var _y = player.py;
    world_tick = _saved.timer;
    rooms_cleared = _saved.clears;
    kills = _saved.defeated;
    choose_relic = false;
    lk_enter_room(_saved.current, -1);
    player.px = _x;
    player.py = _y;
    mode = LK_MODE.Play;
    file_delete(_source);
    checkpoint_available = false;
    lk_sound(snd_gate);
    return true;
}
