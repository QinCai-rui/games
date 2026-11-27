enum LK_TOUR { Move, Fire, Swap, Skill, Fork, Inscription, Cache, Forge, Shrine, Shop, Stop, Guardian, Secrets, Combat }

function lk_tour_active() {
    return variable_struct_exists(player, "tour") && player.tour.enabled && tour_skipped_seed != run_seed;
}

function lk_tour_seen(_topic) {
    return (player.tour.seen & (1 << _topic)) != 0;
}

function lk_tour_record(_topic) {
    if (lk_tour_active()) player.tour.seen |= 1 << _topic;
}

function lk_tour_skip_pressed() {
    return keyboard_check_pressed(ord("H")) || (pad >= 0 && gamepad_button_check_pressed(pad, gp_face4));
}

function lk_tour_show(_topic) {
    if (!lk_tour_active() || lk_tour_seen(_topic)) return;
    tour_topic = _topic;
    tour_started = world_tick;
    lk_tour_record(_topic);
}

function lk_tour_enter() {
    tour_topic = -1;
    tour_room_started = world_tick;
    switch (cell.kind) {
        case LK_ROOM.Cache: if (!cell.opened) lk_tour_show(LK_TOUR.Cache); break;
        case LK_ROOM.Forge: if (!cell.opened) lk_tour_show(LK_TOUR.Forge); break;
        case LK_ROOM.Shop: lk_tour_show(LK_TOUR.Shop); break;
        case LK_ROOM.Shrine:
        case LK_ROOM.SparkShrine: if (!cell.shrine_used) lk_tour_show(LK_TOUR.Shrine); break;
        case LK_ROOM.Armory:
        case LK_ROOM.SupplyPost:
        case LK_ROOM.TemperRelay: if (!cell.opened) lk_tour_show(LK_TOUR.Stop); break;
    }
}

function lk_tour_clear() {
    if (!lk_tour_active()) return;
    if (cell.kind == LK_ROOM.Fight) {
        for (var _dir = 0; _dir < 4; _dir++) {
            var _next = cell.exits[_dir];
            if (_next >= 0 && lk_route_role(dungeon[_next]) == LK_ROUTE_ROOM.High
                && !lk_tour_seen(LK_TOUR.Fork)) {
                lk_tour_show(LK_TOUR.Fork);
                return;
            }
        }
        var _mark = lk_route_mark_id();
        if (_mark >= 0 && _mark < 3) lk_tour_show(LK_TOUR.Inscription);
    } else if (cell.kind == LK_ROOM.Boss) {
        if (depth_no == 0) {
            lk_tour_show(LK_TOUR.Guardian);
            tour_next_run = false;
            lk_save();
        } else if (depth_no == 1) {
            lk_tour_show(LK_TOUR.Secrets);
        }
    }
}

function lk_tour_prompt() {
    if (!lk_tour_active()) return "";
    if (cell.kind == LK_ROOM.Landing && depth_no == 0) {
        if (!lk_tour_seen(LK_TOUR.Move)) return pad >= 0 ? "MOVE WITH THE LEFT STICK." : "MOVE WITH WASD OR THE ARROW KEYS.";
        if (!lk_tour_seen(LK_TOUR.Fire)) return pad >= 0 ? "AIM WITH THE RIGHT STICK. RT ALSO FIRES." : "HOLD SPACE TO AUTO-AIM, OR CLICK TO AIM AND FIRE.";
        if (!lk_tour_seen(LK_TOUR.Swap)) return pad >= 0 ? "PRESS X TO SWAP WEAPONS." : "PRESS TAB TO SWAP WEAPONS.";
        for (var _dir = 0; _dir < 4; _dir++) {
            if (cell.exits[_dir] != 1) continue;
            return "FIRST FIGHT: TAKE THE " + ["EAST", "SOUTH", "WEST", "NORTH"][_dir] + " DOOR.";
        }
    }
    if (depth_no == 0 && !cell.clear && cell.kind == LK_ROOM.Fight
        && world_tick - tour_room_started < 510 && !lk_tour_seen(LK_TOUR.Skill)) {
        return pad >= 0 ? "LB: SKILL" : "Q: SKILL";
    }
    if (tour_topic < 0 || world_tick - tour_started >= 510) return "";
    var _second = world_tick - tour_started >= 240;
    switch (tour_topic) {
        case LK_TOUR.Fork: return _second ? "ARROW DOORS LEAD TO THE LOWER-DANGER ROUTE." : "SWORD DOORS LEAD TO ELITES AND A WEAPON REWARD.";
        case LK_TOUR.Inscription: return "READ THE INSCRIPTIONS TO FIND A SECRET ROUTE.";
        case LK_TOUR.Cache: return "CHOOSE ONE FOR YOUR ACTIVE SLOT.";
        case LK_TOUR.Forge: return "ONE UPGRADE PER FORGE.";
        case LK_TOUR.Shrine: return "PICK A BOON. IT STAYS WITH YOU FOR THIS RUN.";
        case LK_TOUR.Shop: return "SPEND GOLD ON HEALTH, ENERGY, OR A WEAPON.";
        case LK_TOUR.Stop: return "CHOOSE ONE OFFER BEFORE YOU LEAVE.";
        case LK_TOUR.Guardian:
            return _second ? "THE JOURNAL RECORDS DISCOVERIES BETWEEN RUNS." : "TAKE THE HEART, THEN USE THE PORTAL TO DESCEND.";
        case LK_TOUR.Secrets: return "THREE INSCRIPTIONS AND 9 GOLD OPEN THE ARCHIVE.";
    }
    return "";
}

function lk_draw_tour(_prompt) {
    var _skip_x = 24 + string_length(_prompt) * 6;
    draw_set_alpha(.80);
    lk_rect(9, 232, _skip_x + 70, 245, C_INK);
    draw_set_alpha(1);
    lk_text(_prompt, 14, 233, C_PAPER);
    lk_text(pad >= 0 ? "Y SKIP TOUR" : "H SKIP TOUR", _skip_x, 233, C_MUTED);
}
