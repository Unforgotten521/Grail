extends Control

const BG := Color("#10151b")
const PANEL := Color("#1b242d")
const PANEL_EDGE := Color("#46515d")
const GOLD := Color("#d8b46a")
const MUTED := Color("#aab4bf")

func _ready() -> void:
    _build_menu()

func _style(bg: Color, border: Color, radius: int = 14) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = bg
    box.border_color = border
    box.set_border_width_all(1)
    box.set_corner_radius_all(radius)
    box.content_margin_left = 22
    box.content_margin_right = 22
    box.content_margin_top = 16
    box.content_margin_bottom = 16
    return box

func _label(value: String, size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    return label

func _build_menu() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var background := ColorRect.new()
    background.color = BG
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)

    var glow := ColorRect.new()
    glow.color = Color("#1b2830")
    glow.anchor_left = 0.5
    glow.anchor_right = 0.5
    glow.anchor_top = 0.5
    glow.anchor_bottom = 0.5
    glow.offset_left = -430
    glow.offset_top = -330
    glow.offset_right = 430
    glow.offset_bottom = 330
    glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(glow)

    var frame := PanelContainer.new()
    frame.anchor_left = 0.5
    frame.anchor_top = 0.5
    frame.anchor_right = 0.5
    frame.anchor_bottom = 0.5
    frame.offset_left = -250
    frame.offset_top = -250
    frame.offset_right = 250
    frame.offset_bottom = 250
    frame.add_theme_stylebox_override("panel", _style(PANEL, PANEL_EDGE, 22))
    add_child(frame)

    var content := VBoxContainer.new()
    content.alignment = BoxContainer.ALIGNMENT_CENTER
    content.add_theme_constant_override("separation", 18)
    frame.add_child(content)

    var emblem := _label("✦", 48, GOLD)
    emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(emblem)

    var eyebrow := _label("ПУТЬ СКВОЗЬ ТЬМУ", 13, MUTED)
    eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(eyebrow)

    var title := _label("ОСКВЕРНЁННЫЙ\nГРААЛЬ", 36, Color("#eee6d5"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.add_theme_constant_override("line_spacing", 5)
    content.add_child(title)

    var divider := ColorRect.new()
    divider.color = GOLD
    divider.custom_minimum_size = Vector2(100, 2)
    divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    content.add_child(divider)

    var subtitle := _label("Собери колоду. Пройди испытания.\nНайди то, что осталось от легенды.", 15, MUTED)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(subtitle)

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 10
    content.add_child(spacer)

    var new_game := Button.new()
    new_game.text = "НОВАЯ ИГРА"
    new_game.custom_minimum_size = Vector2(300, 56)
    new_game.add_theme_font_size_override("font_size", 18)
    new_game.add_theme_color_override("font_color", Color("#171b20"))
    new_game.add_theme_stylebox_override("normal", _style(GOLD, GOLD, 10))
    new_game.add_theme_stylebox_override("hover", _style(Color("#edca82"), Color("#edca82"), 10))
    new_game.add_theme_stylebox_override("pressed", _style(Color("#b89555"), Color("#b89555"), 10))
    new_game.pressed.connect(_on_new_game_pressed)
    content.add_child(new_game)

    var exit_button := Button.new()
    exit_button.text = "ВЫЙТИ"
    exit_button.custom_minimum_size = Vector2(300, 48)
    exit_button.add_theme_font_size_override("font_size", 15)
    exit_button.add_theme_color_override("font_color", MUTED)
    exit_button.add_theme_stylebox_override("normal", _style(Color("#222c35"), Color("#3b4753"), 10))
    exit_button.add_theme_stylebox_override("hover", _style(Color("#2b3742"), GOLD, 10))
    exit_button.pressed.connect(_on_exit_pressed)
    content.add_child(exit_button)

    var footer := _label("GRAIL  •  ПЕРВАЯ ГЛАВА", 11, Color("#697582"))
    footer.anchor_left = 0.5
    footer.anchor_right = 0.5
    footer.anchor_top = 1.0
    footer.anchor_bottom = 1.0
    footer.offset_left = -160
    footer.offset_top = -42
    footer.offset_right = 160
    footer.offset_bottom = -18
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(footer)

func _on_new_game_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_exit_pressed() -> void:
    get_tree().quit()
