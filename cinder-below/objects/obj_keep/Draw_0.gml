draw_clear(C_INK);
if (mode == LK_MODE.Title || mode == LK_MODE.Select) {
    lk_draw_menu();
} else if (mode == LK_MODE.Contract) {
    lk_draw_contracts();
} else if (mode == LK_MODE.Journal) {
    lk_draw_journal();
} else if (mode == LK_MODE.Map) {
    lk_draw_stage_map();
} else {
    lk_draw_game();
    if (mode != LK_MODE.Play) lk_draw_overlay();
}
