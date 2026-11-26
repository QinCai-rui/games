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
            if (!lk_load_checkpoint()) lk_sound(snd_click, .64);
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
        if (keyboard_check_pressed(ord("R"))) {
            lk_contract_open(LK_MODE.Select);
            break;
        }
        if (back_pressed) {
            mode = LK_MODE.Title;
            break;
        }
        if (lk_tour_skip_pressed() || (pointer_click && abs(pointer_x - 240) <= 72 && pointer_y >= 221 && pointer_y < 231)) {
            tour_next_run = !tour_next_run;
            lk_save();
        }
        if (swap_pressed || (pointer_click && pointer_y >= 231 && pointer_y <= 254 && pointer_x >= 324)) {
            use_alt_loadout = !use_alt_loadout;
            lk_sound(snd_click);
        }
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
            if (pointer_y >= 231 && pointer_y < 258 && abs(pointer_x - 240) < 88) accept_pressed = true;
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
        if (pointer_click && pointer_y >= 111 && pointer_y <= 178) {
            if (pointer_x >= 61 && pointer_x <= 232) { selected = 0; accept_pressed = true; }
            if (array_length(boon_options) > 1 && pointer_x >= 248 && pointer_x <= 419) { selected = 1; accept_pressed = true; }
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
