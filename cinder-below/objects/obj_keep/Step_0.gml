tick += 1;
lk_display_input();
lk_input();
if (keyboard_check_pressed(ord("M"))) {
    muted = !muted;
    lk_save();
}
lk_music();

switch (mode) {
    case LK_MODE.Title:
        if (keyboard_check_pressed(ord("R")) || (pad >= 0 && gamepad_button_check_pressed(pad, gp_face2)) || (pointer_click
            && pointer_y >= 181 && pointer_y <= 205 && pointer_x >= 337 && pointer_x <= 449)) {
            lk_contract_open(LK_MODE.Title);
        } else if (checkpoint_available && (accept_pressed || keyboard_check_pressed(ord("C"))
            || (pad >= 0 && gamepad_button_check_pressed(pad, gp_face4))
            || (pointer_click && pointer_y >= 181 && pointer_y <= 205 && pointer_x >= 32 && pointer_x <= 177))) {
            if (lk_load_checkpoint()) use_alt_loadout = false;
            else lk_sound(snd_click, .64);
        } else if (keyboard_check_pressed(ord("J")) || (pointer_click
            && pointer_y >= 209 && pointer_y <= 232 && pointer_x >= 337 && pointer_x <= 449)) {
            mode = LK_MODE.Journal;
            lk_sound(snd_click);
        } else if ((!checkpoint_available && accept_pressed) || keyboard_check_pressed(ord("N"))
            || (checkpoint_available && pad >= 0 && gamepad_button_check_pressed(pad, gp_face3)) || (pointer_click
            && pointer_x >= 32 && pointer_x <= 177
            && (checkpoint_available ? pointer_y >= 209 && pointer_y <= 233 : pointer_y >= 181 && pointer_y <= 205))) {
            mode = LK_MODE.Select;
            lk_sound(snd_click);
        }
        break;
    case LK_MODE.Select:
        if (keyboard_check_pressed(ord("R")) || (pad >= 0 && gamepad_button_check_pressed(pad, gp_face2))
            || (pointer_click && pointer_x >= 33 && pointer_x <= 100 && pointer_y >= 250 && pointer_y < 265)) {
            lk_contract_open(LK_MODE.Select);
            break;
        }
        if (back_pressed || (pointer_click && pointer_x >= 33 && pointer_x <= 100 && pointer_y >= 235 && pointer_y < 250)) {
            mode = LK_MODE.Title;
            break;
        }
        if (lk_tour_skip_pressed() || (pointer_click && abs(pointer_x - 240) <= 72 && pointer_y >= 221 && pointer_y < 231)) {
            tour_next_run = !tour_next_run;
            lk_save();
        }
        var _previous_keeper = hero_id;
        if (menu_left || menu_right) {
            hero_id = (hero_id + (menu_left ? array_length(heroes) - 1 : 1)) mod array_length(heroes);
            lk_sound(snd_click);
        }
        if (menu_vert) {
            hero_id = (hero_id + 4) mod array_length(heroes);
            lk_sound(snd_click);
        }
        if (pointer_click) {
            if (pointer_y >= 69 && pointer_y < 198 && pointer_x >= 36 && pointer_x < 445) {
                var _column = clamp(floor((pointer_x - 36) / 103), 0, 3);
                var _row = pointer_y >= 134 ? 1 : 0;
                hero_id = _row * 4 + _column;
                lk_sound(snd_click);
            }
            if (pointer_y >= 232 && pointer_y <= 256 && pointer_x >= 167 && pointer_x <= 313) accept_pressed = true;
        }
        if (hero_id != _previous_keeper) use_alt_loadout = false;
        if ((swap_pressed || (pointer_click && pointer_y >= 232 && pointer_y <= 256 && pointer_x >= 321 && pointer_x <= 445))
            && lk_keeper_has_alt_kit(hero_id)) {
            use_alt_loadout = !use_alt_loadout;
            lk_sound(snd_click);
        }
        if (accept_pressed && lk_contract_available(chosen_contract)) lk_begin_run();
        break;
    case LK_MODE.Pause:
        if ((keyboard_check_pressed(ord("S")) || (pad >= 0 && gamepad_button_check_pressed(pad, gp_face4))) && cell.clear) {
            if (lk_save_checkpoint()) {
                lk_save();
                mode = LK_MODE.Title;
                lk_sound(snd_gate);
            } else {
                lk_sound(snd_click, .64);
            }
            break;
        }
        if (back_pressed || accept_pressed) mode = LK_MODE.Play;
        if (keyboard_check_pressed(ord("Q"))) {
            if (cell.clear) lk_save_checkpoint();
            mode = LK_MODE.Title;
        }
        break;
    case LK_MODE.Boon:
        if ((menu_left || menu_right) && array_length(boon_options) > 1) selected = 1 - selected;
        if (pointer_click) {
            var _layout = lk_reward_card_layout();
            for (var _i = 0; _i < array_length(_layout.cards); _i++) {
                var _x = _layout.cards[_i].x;
                if (point_in_rectangle(pointer_x, pointer_y, _x, _layout.top, _x + LK_CARD_WIDTH, LK_CARD_BOTTOM)) {
                    selected = _i;
                    accept_pressed = true;
                    break;
                }
            }
        }
        if (accept_pressed) {
            if (choose_relic) lk_take_relic(boon_options[selected]);
            else lk_take_boon(boon_options[selected]);
        }
        break;
    case LK_MODE.Dead:
    case LK_MODE.Won:
        if (accept_pressed) mode = LK_MODE.Select;
        if (back_pressed) mode = LK_MODE.Title;
        break;
    case LK_MODE.Contract:
        lk_contract_step();
        break;
    case LK_MODE.Journal:
        lk_journal_step();
        break;
    case LK_MODE.Play:
        if (back_pressed) {
            mode = LK_MODE.Pause;
            break;
        }
        if (lk_tour_active() && lk_tour_skip_pressed()) {
            player.tour.enabled = false;
            tour_skipped_seed = run_seed;
            tour_next_run = false;
            lk_save();
            if (cell.clear) lk_save_checkpoint();
        }
        lk_play_step();
        break;
}
