enum LK_FIT { None, Split, Dense, Cold, Return, Rebound, Edge, Fuse, Siphon, Clock, Hot }
enum LK_STOCK { Drop, Cache, Trial, Shop }

#macro LK_FUSION_FIRST 36
#macro LK_BLUEPRINT_FIRST 24

function lk_fittings() {
    return [
        {name: "", note: "", tint: C_MUTED},
        {name: "SPLIT COLLAR", note: "+2 PELLETS. WIDER SPREAD.", tint: C_GOLD},
        {name: "DENSE CORE", note: "+22% DAMAGE. +25% ATTACK DELAY.", tint: C_PINK},
        {name: "COLD WICK", note: "HITS SLOW. -18% DIRECT DAMAGE.", tint: C_BLUE},
        {name: "RETURN COIL", note: "DISCS RETURN FASTER AND HIT HARDER.", tint: C_LILAC},
        {name: "REBOUND LENS", note: "+1 BOUNCE. -15% SHOT SPEED.", tint: C_TEAL},
        {name: "WIDE EDGE", note: "+11 MELEE REACH. +20% ATTACK DELAY.", tint: C_MINT},
        {name: "QUICK FUSE", note: "BLASTS ARM FASTER. -25% BLAST RADIUS.", tint: C_GOLD},
        {name: "SIPHON PIN", note: "+3 ENERGY ON KILL. 12 ENERGY PER ROOM.", tint: C_BLUE},
        {name: "SENTRY CLOCK", note: "TURRET FIRES FASTER. DEPLOYS FOR LESS TIME.", tint: C_TEAL},
        {name: "HOT CHAMBER", note: "3 QUICK HITS BOOST DAMAGE. EXTRA ENERGY.", tint: C_PINK}
    ];
}

function lk_fusion_recipes() {
    return [[3, 9], [7, 14], [12, 5], [22, 11], [4, 18], [20, 21]];
}

function lk_fusion_index() {
    for (var _i = 0; _i < array_length(fusion_recipes); _i++) {
        var _pair = fusion_recipes[_i];
        if (array_contains(player.arms, _pair[0]) && array_contains(player.arms, _pair[1])) return _i;
    }
    return -1;
}

function lk_armory_group(_id) {
    var _kind = weapons[_id].kind;
    if (lk_is_blade(_kind) || _id == 25) return 0;
    if (array_contains([LK_SHOT.Blast, LK_SHOT.Vial, LK_SHOT.Mortar, LK_SHOT.Beacon], _kind)
        || _id == 29 || _id == 35 || _id == 39) return 2;
    return 1;
}

function lk_is_blade(_kind) {
    return _kind == LK_SHOT.Blade || _kind == LK_SHOT.Briar || _kind == LK_SHOT.Crown;
}

function lk_weapon_stock(_source, _seed = -1, _avoid = -1, _group = -1, _also_avoid = -1) {
    var _picks = [];
    var _basics = [2, 3, 4, 6, 7, 9, 10, 12, 14, 18, 24, 25, 27, 28, 29, 30, 34, 35];
    var _rare = [5, 8, 11, 13, 15, 16, 17, 19, 20, 21, 22, 23, 26, 31, 32, 33];
    // Older builds also offered most of these early. Bias the roll without excluding them.
    var _end = min(array_length(weapons), LK_FUSION_FIRST);
    for (var _id = 2; _id < _end; _id++) {
        if (_id == _avoid || _id == _also_avoid || lk_armory_group(_id) == _group) continue;
        var _early = array_contains(_basics, _id);
        var _unlocked = _source == LK_STOCK.Shop && run_contract != LK_CONTRACT.Daily && lk_blueprint_available(_id);
        var _weight = _early ? 4 : 1;
        if (_source == LK_STOCK.Trial) _weight = array_contains(_rare, _id) ? 5 : 2;
        else if (!_early && depth_no >= 3) _weight += 2;
        if (_source == LK_STOCK.Drop && _id >= 24 && (_id + depth_no) mod 3 == 0) _weight += 2;
        if (_unlocked) _weight += 8;
        repeat (_weight) array_push(_picks, _id);
    }
    if (array_length(_picks) == 0) return 2;
    var _index = _seed < 0 ? irandom(array_length(_picks) - 1) : _seed mod array_length(_picks);
    return _picks[_index];
}

function lk_trial_weapon() {
    var _weapon = lk_weapon_stock(LK_STOCK.Trial, -1, player.arms[0], -1, player.arms[1]);
    var _rank = clamp(1 + floor(depth_no / 3) + lk_has_modifier(LK_OMEN.Deep), 1, 3);
    lk_drop(LK_LOOT.Weapon, 240, 151, _weapon, _rank);
}

function lk_attachment_works(_id, _fit) {
    var _kind = weapons[_id].kind;
    switch (_fit) {
        case LK_FIT.Split: return _kind == LK_SHOT.Pellet || _kind == LK_SHOT.Buckshot || _kind == LK_SHOT.Ricochet;
        case LK_FIT.Cold: return lk_armory_group(_id) == 1 && _kind != LK_SHOT.Chain;
        case LK_FIT.Return: return _kind == LK_SHOT.Disc || _id == 27 || _id == 38;
        case LK_FIT.Rebound: return array_contains([LK_SHOT.Pellet, LK_SHOT.Pierce, LK_SHOT.Ricochet, LK_SHOT.Echo], _kind);
        case LK_FIT.Edge: return lk_is_blade(_kind);
        case LK_FIT.Fuse: return _kind == LK_SHOT.Mortar || _kind == LK_SHOT.Vial;
        case LK_FIT.Siphon: return weapons[_id].cost > 0;
        case LK_FIT.Clock: return _kind == LK_SHOT.Beacon;
        case LK_FIT.Hot: return weapons[_id].cost > 0 && lk_armory_group(_id) == 1;
    }
    return true;
}

function lk_armory_restore() {
    if (!variable_struct_exists(player, "attachments")) player.attachments = [0, 0];
    armory_source = undefined;
    armory_generation = [0, 0];
    armory_heat = [0, 0];
    armory_heat_until = [0, 0];
    armory_siphon = 0;
    armory_afterstroke = 0;
    armory_keyed_distance = 0;
    armory_still = 0;
    armory_guardfall = 0;
    armory_discharge = 0;
    player.forged_charge = 0;
}

function lk_equip_weapon(_slot, _id, _temper, _fit = LK_FIT.None) {
    player.arms[_slot] = _id;
    player.temper[_slot] = _temper;
    player.attachments[_slot] = _fit;
    armory_generation[_slot] += 1;
    armory_heat[_slot] = 0;
    armory_heat_until[_slot] = 0;
    player.forged_charge = 0;
    lk_remember_weapon(_id);
}

function lk_fitted_attachment(_id) {
    return player.arms[player.slot] == _id ? player.attachments[player.slot] : LK_FIT.None;
}

function lk_attachment_cost(_id, _cost) {
    if (lk_fitted_attachment(_id) == LK_FIT.Hot && armory_heat[player.slot] >= 3
        && armory_heat_until[player.slot] > world_tick) return _cost + 1;
    return _cost;
}

function lk_attachment_weapon(_id) {
    var _base = weapons[_id];
    var _fit = lk_fitted_attachment(_id);
    var _stats = {name: _base.name, damage: _base.damage, delay: _base.delay, cost: _base.cost,
        speed: _base.speed, count: _base.count, spread: _base.spread, color: _base.color, kind: _base.kind};
    switch (_fit) {
        case LK_FIT.Split:
            _stats.count += 2;
            _stats.spread = max(13, _stats.spread * 1.20);
            _stats.damage *= .84;
            break;
        case LK_FIT.Dense:
            _stats.damage *= 1.22;
            _stats.delay *= 1.25;
            break;
        case LK_FIT.Cold: _stats.damage *= .82; break;
        case LK_FIT.Rebound: _stats.speed *= .85; break;
        case LK_FIT.Edge: _stats.delay *= 1.20; break;
        case LK_FIT.Hot:
            if (armory_heat[player.slot] >= 3 && armory_heat_until[player.slot] > world_tick) _stats.damage *= 1.35;
            break;
    }
    if (!is_undefined(armory_source)) _stats.damage *= armory_source.scale;
    return _stats;
}

function lk_armory_melee_range(_id, _radius) {
    return _radius + (lk_fitted_attachment(_id) == LK_FIT.Edge ? 11 : 0);
}

function lk_armory_begin_attack(_id) {
    var _blade = lk_is_blade(weapons[_id].kind);
    var _keep = player.arms[player.slot] == _id;
    var _cost = lk_weapon_cost(_id);
    var _scale = 1;
    if (!_blade && armory_afterstroke > world_tick) {
        armory_afterstroke = 0;
        _scale += .24;
    }
    if (armory_keyed_distance >= 110) {
        armory_keyed_distance = 0;
        _scale += .24;
        lk_ring(player.px, player.py, C_GOLD, 24, 16);
    }
    if (armory_guardfall > world_tick) {
        armory_guardfall = 0;
        _scale += .28;
    }
    if (!player.charged_shot && _cost > 0 && player.energy < _cost * 2 && lk_boon_rank(LK_BOON.LastEmber)) _scale += .38;
    if ((_id == 24 || _id == 33) && armory_still >= 25 && lk_boon_rank(LK_BOON.Stillhand)) _scale += .24;
    armory_source = {id: _id, fit: lk_fitted_attachment(_id), slot: _keep ? player.slot : -1,
        generation: armory_generation[player.slot], hit: false, scale: _scale, melee: _blade};
}

function lk_armory_motion(_distance) {
    armory_still = _distance < .1 ? min(60, armory_still + 1) : 0;
    if (!cell.clear && lk_boon_rank(LK_BOON.KindledStep)) {
        armory_keyed_distance = min(110, armory_keyed_distance + _distance);
    }
}

function lk_armory_bullet(_shot) {
    if (is_undefined(armory_source) || !_shot.friendly) return;
    _shot.armory = armory_source;
    if (armory_source.fit == LK_FIT.Rebound) _shot.bounces += 1;
}

function lk_armory_field(_field) {
    if (is_undefined(armory_source) || _field.hostile) return;
    _field.armory = armory_source;
    if (armory_source.fit == LK_FIT.Fuse && (_field.kind == 0 || _field.kind == 1)) {
        _field.radius *= .75;
        var _reduction = min(_field.windup, 6);
        _field.windup -= _reduction;
        _field.life -= _reduction;
    }
    if (armory_source.fit == LK_FIT.Clock && _field.kind == 2) {
        _field.cadence = max(8, floor(_field.cadence * .67));
        _field.life -= 39;
        _field.duration -= 39;
    }
}

function lk_armory_attachment_is(_id) {
    return !is_undefined(armory_source) && armory_source.fit == _id;
}

function lk_armory_same_weapon(_first, _second) {
    if (is_undefined(_first) || is_undefined(_second)) return is_undefined(_first) && is_undefined(_second);
    return _first.id == _second.id && _first.slot == _second.slot && _first.fit == _second.fit
        && _first.generation == _second.generation;
}

function lk_armory_hit(_enemy, _damage, _angle) {
    var _source = armory_source;
    if (is_undefined(_source) || _damage <= 0) return;
    if (_source.melee && lk_boon_rank(LK_BOON.Afterstroke)) armory_afterstroke = world_tick + 100;
    if (_source.fit == LK_FIT.Cold) _enemy.slow = max(_enemy.slow, 48);
    if (_source.fit == LK_FIT.Hot && !_source.hit && _source.slot >= 0
        && _source.generation == armory_generation[_source.slot]) {
        var _slot = _source.slot;
        if (armory_heat_until[_slot] <= world_tick) armory_heat[_slot] = 0;
        armory_heat[_slot] = min(3, armory_heat[_slot] + 1);
        armory_heat_until[_slot] = world_tick + 107;
    }
    _source.hit = true;
    if (_enemy.kind != LK_ENEMY.Boss && !lk_stationary_enemy(_enemy.kind) && !variable_struct_exists(_enemy, "guardian_owner")
        && lk_boon_rank(LK_BOON.Crossdraft)
        && abs(angle_difference(point_direction(_enemy.px, _enemy.py, player.px, player.py), _angle + 180)) > 80) {
        lk_move(_enemy, lengthdir_x(8, _angle), lengthdir_y(8, _angle), _enemy.radius);
    }
    if ((_source.id == 11 || _source.id == 26 || _source.id == 39)
        && _enemy.slow > 0 && world_tick >= armory_discharge && lk_boon_rank(LK_BOON.ColdConductor)) {
        armory_discharge = world_tick + 34;
        armory_source = undefined;
        for (var _i = 0; _i < array_length(enemies); _i++) {
            var _near = enemies[_i];
            if (_near == _enemy || !_near.alive || _near.emerge > 9 || point_distance(_near.px, _near.py, _enemy.px, _enemy.py) > 56) continue;
            lk_ring(_near.px, _near.py, C_BLUE, 17, 14);
            lk_enemy_damage(_near, max(1, floor(_damage * .45)), _angle, true);
            break;
        }
        armory_source = _source;
    }
}

function lk_armory_kill() {
    if (lk_armory_attachment_is(LK_FIT.Siphon) && armory_siphon < 12) {
        armory_siphon += 3;
        player.energy = min(player.max_energy, player.energy + 3);
    }
}

function lk_fit_for_forge() {
    var _fits = [];
    var _current = player.attachments[player.slot];
    var _id = player.arms[player.slot];
    for (var _i = 1; _i < array_length(fittings); _i++) {
        if (_i != _current && lk_attachment_works(_id, _i)) array_push(_fits, _i);
    }
    return _fits[(cell.seed + _id * 17) mod array_length(_fits)];
}

function lk_forge_offer(_index) {
    var _fit = lk_fit_for_forge();
    var _fuse = lk_fusion_index();
    var _x = 157 + _index * 83;
    switch (_index) {
        case 0:
            return {kind: "forge", px: _x, py: 137, label: player.temper[player.slot] >= 3 ? "MAX TEMPER" :
                "TEMPER / " + string(lk_temper_cost()) + "G", detail: "+20% BASE DAMAGE", tint: C_GOLD,
                usable: player.temper[player.slot] < 3, sign: "TEMPER"};
        case 1:
            var _item = fittings[_fit];
            return {kind: "fitting", px: _x, py: 137, label: _item.name + " / " + string(lk_fit_price()) + "G",
                detail: _item.note, fit: _fit, tint: _item.tint, usable: true, sign: "ATTACH"};
    }
    var _name = _fuse < 0 ? "NO MATCHING RECIPE" : weapons[LK_FUSION_FIRST + _fuse].name + " / 9G";
    return {kind: "fusion", px: _x, py: 137, label: _name,
        detail: _fuse < 0 ? "CHECK RECIPES IN THE JOURNAL" : "COMBINE BOTH WEAPONS INTO ONE", tint: C_LILAC,
        usable: _fuse >= 0, sign: "FUSE"};
}

function lk_fit_price() {
    return 7 + floor(depth_no / 2);
}

function lk_claim_fit(_fit) {
    if (cell.opened || !lk_attachment_works(player.arms[player.slot], _fit)) return false;
    var _price = lk_fit_price();
    if (player.coins < _price) {
        lk_floater(player.px, player.py - 14, "NEED " + string(_price) + "G", C_PINK);
        return false;
    }
    player.coins -= _price;
    lk_equip_weapon(player.slot, player.arms[player.slot], player.temper[player.slot], _fit);
    cell.opened = true;
    lk_ring(player.px, player.py, fittings[_fit].tint, 32, 26);
    return true;
}

function lk_claim_fusion() {
    var _recipe = lk_fusion_index();
    if (_recipe < 0 || cell.opened) return false;
    if (player.coins < 9) {
        lk_floater(player.px, player.py - 14, "NEED 9G", C_PINK);
        return false;
    }
    player.coins -= 9;
    var _rank = floor((player.temper[0] + player.temper[1]) / 2);
    lk_equip_weapon(player.slot, LK_FUSION_FIRST + _recipe, _rank);
    lk_equip_weapon(1 - player.slot, 0, 0);
    cell.opened = true;
    lk_discover(6 + _recipe);
    lk_ring(player.px, player.py, C_LILAC, 48, 30);
    lk_sparks(player.px, player.py, C_GOLD, 24, 2);
    return true;
}
