#macro LK_WIDTH 480
#macro LK_HEIGHT 270

function lk_display_start() {
    gpu_set_texfilter(false);
    application_surface_draw_enable(false);
    display_set_gui_maximise(1, 1);

    // Leave room for the desktop and window decorations.
    var _screen_width = display_get_width();
    var _screen_height = display_get_height();
    var _fit = min(_screen_width / LK_WIDTH, _screen_height / LK_HEIGHT);
    var _zoom = _fit < 1 ? _fit : clamp(floor(_fit * .85), 1, 3);
    var _width = max(1, floor(LK_WIDTH * _zoom));
    var _height = max(1, floor(LK_HEIGHT * _zoom));
    window_set_rectangle(floor((_screen_width - _width) / 2), floor((_screen_height - _height) / 2), _width, _height);

    display_width = 0;
    display_height = 0;
    lk_display_layout();
}

function lk_display_layout() {
    var _width = max(1, window_get_width());
    var _height = max(1, window_get_height());
    if (_width == display_width && _height == display_height) return;

    var _scale = min(_width / LK_WIDTH, _height / LK_HEIGHT);
    if (integer_scaling && _scale >= 1) _scale = floor(_scale);

    display_width = _width;
    display_height = _height;
    display_view_width = max(1, round(LK_WIDTH * _scale));
    display_view_height = max(1, round(LK_HEIGHT * _scale));
    display_view_x = floor((_width - display_view_width) / 2);
    display_view_y = floor((_height - display_view_height) / 2);
}

function lk_display_input() {
    if (keyboard_check_pressed(vk_f10)) {
        integer_scaling = !integer_scaling;
        display_width = 0;
        ini_open("lantern_keep.ini");
        ini_write_real("settings", "integer_scaling", integer_scaling);
        ini_close();
    }
    lk_display_layout();

    // Rendering and hit tests use the same centered rectangle.
    pointer_x = (window_mouse_get_x() - display_view_x) * LK_WIDTH / display_view_width;
    pointer_y = (window_mouse_get_y() - display_view_y) * LK_HEIGHT / display_view_height;
    pointer_inside = pointer_x >= 0 && pointer_x < LK_WIDTH && pointer_y >= 0 && pointer_y < LK_HEIGHT;
    pointer_fire = pointer_inside && mouse_check_button(mb_left);
    pointer_click = pointer_inside && mouse_check_button_pressed(mb_left);
}

function lk_display_draw() {
    draw_clear(c_black);
    if (!surface_exists(application_surface)) return;

    lk_display_layout();
    gpu_set_texfilter(false);
    gpu_set_blendenable(false);
    draw_surface_stretched(application_surface, display_view_x, display_view_y, display_view_width, display_view_height);
    gpu_set_blendenable(true);
}
