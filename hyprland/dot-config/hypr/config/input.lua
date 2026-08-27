hl.config({
  input = {
    kb_layout  = "us",
    follow_mouse = 1,
    sensitivity = 0,
    accel_profile = "flat",

    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,

    touchpad = {
      natural_scroll        = true,
      tap_to_click          = true,
      drag_lock             = true,
      disable_while_typing  = true,
      clickfinger_behavior  = true,
      middle_button_emulation = true,
    },
  },

  misc = {
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})

hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})