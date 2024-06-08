#import "Basic";
#import "Math";
#import "String";

Window  :: #import "Window_Creation";
Input   :: #import "Input";
Simp    :: #import "Simp";
GetRect :: #import "GetRect_LeftHanded";

#import "Tween";

my_window: Window.Window_Type;
window_width  : s32 = 1280;
window_height : s32 = 900;

current_time: float64;
last\  _time: float64;

position_start: Vector2;
position_end:   Vector2;
position_tween: Vector2;

color_start: Vector4;
color_end:   Vector4;
color_tween: Vector4;

tween_kind:     Tween_Kind;
tween_timer:    float;
tween_duration: float;
should_update_tween: bool;

my_theme:              GetRect.Overall_Theme;
current_tween_kind:    s32;
my_font:               *Simp.Dynamic_Font;
tween_duration_slider: float;

TWEEN_NAMES :: #run enum_names(Tween_Kind);

main :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();

        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    my_window = Window.create_window(window_width, window_height, "Tween");

    Simp.set_render_target(my_window, .LEFT_HANDED);

    my_init_font();
    GetRect.ui_init();

    position_start = .{ 200                 , window_height / 2.0 };
    position_end   = .{ window_width - 200.0, window_height / 2.0 };
    position_tween = position_start;

    color_start    = .{ .1, .2, .8, 1 };
    color_end      = .{ .7, .4, .2, 1 };
    color_tween    = color_start;

    tween_timer    = 0.0;
    tween_duration = 1.5;
    tween_duration_slider = 1.5;

    quit := false;
    while !quit {
        current_time = seconds_since_init();
        dt := cast(float)(current_time - last_time);
        Clamp(*dt, 0, 0.1);
        last_time = current_time;

        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);

            if it.window == my_window {
                window_width  = it.width;
                window_height = it.height;
            }
        }

        for Input.events_this_frame {
            if it.type == .QUIT then quit = true;

            GetRect.getrect_handle_event(it);
        }

        for Input.input_button_states {
            key      := cast(Input.Key_Code) it_index;
            pressed  := it & .START;
            released := it & .END;
            down     := it & .DOWN;

            if key == .ESCAPE && pressed then quit = true;
        }

        draw_one_frame(dt);

        reset_temporary_storage();
        sleep_milliseconds(10);
    }
}

draw_one_frame :: (dt: float) {
    x, y, w, h := Window.get_dimensions(my_window, true);
    GetRect.ui_per_frame_update(my_window, w, h, current_time);

    tween_kind = xx current_tween_kind;

    if should_update_tween {
        tween_timer += dt;
    }

    if tween_timer > tween_duration {
        should_update_tween = false;
    }
    
    tween_ratio := tween_timer / tween_duration;
    Clamp(*tween_ratio, 0, 1);

    Tween(*position_tween, position_start, position_end, tween_ratio, tween_kind);
    Tween(*color_tween   , color_start   , color_end   , tween_ratio, tween_kind);

    Simp.clear_render_target(.1, .1, .1, 1);

    button_rect := GetRect.get_rect(50, 50, 200, 23);
    if GetRect.button(button_rect, "Play") {
        tween_timer    = 0.0;
        tween_duration = tween_duration_slider;
        should_update_tween = true;
    }

    slider_rect := GetRect.get_rect(button_rect.x, button_rect.y + button_rect.h + 7, 200, 23);
    GetRect.slider(slider_rect, *tween_duration_slider, 0.0, 3.0, 0.5, *my_theme.slider_theme, "Duration : ", " Sec");

    dropdow_rect := GetRect.get_rect(slider_rect.x, slider_rect.y + slider_rect.h + 7, 200, 23);
    GetRect.dropdown(dropdow_rect, TWEEN_NAMES, *current_tween_kind);

    Simp.set_shader_for_color(enable_blend = true);

    // Moving rectangle
    Simp.immediate_quad(position_tween.x - 50, position_tween.y - 50, position_tween.x + 50, position_tween.y + 50, .{ 1, 1, 1, 1 });

    // Color rectangle
    Simp.immediate_quad(800, 100, 1000, 300, color_tween);

    // Rotating rectangle
    {
        center := Vector2.{ 900, 700 };
        quad   := Vector2.[ center + .{ -100, -100 }, center + .{ -100, 100 }, center + .{ 100, 100 }, center + .{ 100, -100 } ];
        theta  := tween(0.0, TAU, tween_ratio, tween_kind);

        quad[0] = center + rotate(quad[0] - center, theta);
        quad[1] = center + rotate(quad[1] - center, theta);
        quad[2] = center + rotate(quad[2] - center, theta);
        quad[3] = center + rotate(quad[3] - center, theta);

        colors := Vector4.[ .{ 1, 1, 0, 1 }, .{ 0, 1, 1, 1 }, .{ 1, 0, 1, 1 }, .{ 1, 1, 1, 1 } ];

        Simp.immediate_quad(quad[0], quad[1], quad[2], quad[3], colors[0], colors[1], colors[2], colors[3]);
    }

    // Plot
    draw_plot();

    GetRect.draw_popups();

    Simp.swap_buffers(my_window);
}

draw_segment :: (a: Vector2, b: Vector2, color: Vector4, width: float) {
    ab     := normalize(b - a);
    perp   := Vector2.{ ab.y, -ab.x };
    normal := perp * (width / 2.0);
    quad   := Vector2.[ a - normal, a + normal, b + normal, b - normal ];

    Simp.immediate_quad(quad[0], quad[1], quad[2], quad[3], color);
}

draw_plot :: () #expand {
    tl := Vector2.{ 300, 100 };
    br := Vector2.{ tl.x + 400, tl.y + 100 };
    tr := Vector2.{ br.x, tl.y };
    bl := Vector2.{ tl.x, br.y };

    for cast(int) tl.x..cast(int) tr.x {
        a := Vector2.{ xx it, tl.y };
        b := Vector2.{ xx it, bl.y };

        ratio := (it - tl.x) / (tr.x - tl.x);
        color := tween(color_start, color_end, ratio, tween_kind);

        draw_segment(a, b, color, 1.0);
    }

    for 0..99 {
        a, b: Vector2;
        Tween(*a.x, tl.x, tr.x, it       / 100.0, .LINEAR);
        Tween(*b.x, tl.x, tr.x, (it + 1) / 100.0, .LINEAR);

        Tween(*a.y, tl.y, br.y, it       / 100.0, tween_kind);
        Tween(*b.y, tl.y, br.y, (it + 1) / 100.0, tween_kind);

        draw_segment(a, b, .{ 1, 1, 1, 1 }, 2.0);
    }

    p: Vector2;
    Tween(*p.x, tl.x, tr.x, `tween_ratio, .LINEAR);
    Tween(*p.y, tl.y, br.y, `tween_ratio, tween_kind);

    draw_segment(.{ p.x, min(p.y, tl.y) }, .{ p.x, max(p.y, bl.y) }, .{ .8, .8, .8, 1 }, 1.5);
    draw_segment(.{ tl.x, p.y }          , .{ tr.x, p.y }          , .{ .8, .8, .8, 1 }, 1.5);

    Simp.immediate_quad(p.x - 5, p.y - 5, p.x + 5, p.y + 5, .{ 1, 1, 1, 1 });
}

my_init_font :: () {
    pixel_height := window_height / 24;
    my_font = Simp.get_font_at_size(".", "OpenSans-BoldItalic.ttf", pixel_height);
    assert(my_font != null);
}
