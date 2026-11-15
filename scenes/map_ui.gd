extends Control
## Визуальное представление карты. Генерация и переходы остаются в map.gd.

signal node_pressed(index: int)

const BG := Color("#10151b")
const GOLD := Color("#d8b46a")
const MUTED := Color("#aab4bf")
const NODE_SIZE := Vector2(58, 58)

var map_nodes: Array[Dictionary] = []
var connections: Array[Dictionary] = []
var current_node := -1
var buttons: Array[Button] = []

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_PASS

func update_map(new_nodes: Array[Dictionary], new_connections: Array[Dictionary], selected_node: int) -> void:
    map_nodes = new_nodes
    connections = new_connections
    current_node = selected_node
    _rebuild_buttons()
    queue_redraw()

func _panel_style(bg: Color, border: Color, radius: int = 12) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 9
    style.content_margin_bottom = 9
    return style

func _label(value: String, size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    return label

func _rebuild_buttons() -> void:
    for button in buttons:
        button.queue_free()
    buttons.clear()

    for i in range(map_nodes.size()):
        var data: Dictionary = map_nodes[i]
        var button := Button.new()
        button.text = _symbol_for(str(data["kind"]))
        button.tooltip_text = _name_for(str(data["kind"]))
        button.custom_minimum_size = NODE_SIZE
        button.size = NODE_SIZE
        button.position = data["pos"] - NODE_SIZE / 2.0
        button.add_theme_font_size_override("font_size", 19)
        button.add_theme_color_override("font_color", Color("#f1e8d6"))
        button.add_theme_color_override("font_hover_color", Color("#171b20"))
        button.add_theme_stylebox_override("normal", _node_style(str(data["kind"]), false))
        button.add_theme_stylebox_override("hover", _node_style(str(data["kind"]), true))
        button.add_theme_stylebox_override("pressed", _panel_style(Color("#b89555"), GOLD, 30))
        button.add_theme_stylebox_override("disabled", _panel_style(Color("#202830"), Color("#303a44"), 30))
        button.pressed.connect(_on_button_pressed.bind(i))
        add_child(button)
        buttons.append(button)

    _refresh_button_states()
    _build_chrome()

func _node_style(kind: String, hovered: bool) -> StyleBoxFlat:
    var fill := Color("#29343e")
    var edge := Color("#657382")
    match kind:
        "elite":
            fill = Color("#392a2a")
            edge = Color("#b96c62")
        "rest":
            fill = Color("#26382f")
            edge = Color("#79a887")
        "event":
            fill = Color("#302d3d")
            edge = Color("#9a8ac0")
        "boss":
            fill = Color("#432b2b")
            edge = GOLD
    if hovered:
        fill = Color("#d8b46a")
        edge = Color("#f0d59c")
    return _panel_style(fill, edge, 30)

func _build_chrome() -> void:
    for child in get_children():
        if child.name.begins_with("Chrome"):
            child.queue_free()

    var header := PanelContainer.new()
    header.name = "ChromeHeader"
    header.anchor_left = 0.5
    header.anchor_right = 0.5
    header.offset_left = -330
    header.offset_right = 330
    header.offset_top = 24
    header.offset_bottom = 104
    header.add_theme_stylebox_override("panel", _panel_style(Color("#1b242d"), Color("#46515d"), 14))
    header.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(header)

    var header_row := HBoxContainer.new()
    header_row.add_theme_constant_override("separation", 18)
    header.add_child(header_row)
    var title_box := VBoxContainer.new()
    title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header_row.add_child(title_box)
    title_box.add_child(_label("ПУТЬ К ГРААЛЮ", 21, Color("#eee6d5")))
    title_box.add_child(_label("Выбери следующий шаг", 13, MUTED))
    var chapter := _label("ГЛАВА I", 14, GOLD)
    chapter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    header_row.add_child(chapter)

    var legend := PanelContainer.new()
    legend.name = "ChromeLegend"
    legend.anchor_left = 1.0
    legend.anchor_right = 1.0
    legend.anchor_top = 0.5
    legend.anchor_bottom = 0.5
    legend.offset_left = -218
    legend.offset_top = -112
    legend.offset_right = -24
    legend.offset_bottom = 112
    legend.add_theme_stylebox_override("panel", _panel_style(Color("#171f27"), Color("#35414d"), 12))
    legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(legend)
    var legend_box := VBoxContainer.new()
    legend_box.add_theme_constant_override("separation", 11)
    legend.add_child(legend_box)
    legend_box.add_child(_label("ОБОЗНАЧЕНИЯ", 12, GOLD))
    legend_box.add_child(_legend_row("Б", "Обычный бой", Color("#657382")))
    legend_box.add_child(_legend_row("Э", "Элитный враг", Color("#b96c62")))
    legend_box.add_child(_legend_row("О", "Отдых", Color("#79a887")))
    legend_box.add_child(_legend_row("?", "Событие", Color("#9a8ac0")))
    legend_box.add_child(_legend_row("Б!", "Босс", GOLD))

    var footer := _label("СВЯЗАННЫЕ ПУТИ ПОКАЗЫВАЮТ ДОСТУПНЫЕ СЛЕДУЮЩИЕ ШАГИ", 11, Color("#788592"))
    footer.name = "ChromeFooter"
    footer.anchor_left = 0.5
    footer.anchor_right = 0.5
    footer.anchor_top = 1.0
    footer.anchor_bottom = 1.0
    footer.offset_left = -350
    footer.offset_top = -38
    footer.offset_right = 350
    footer.offset_bottom = -14
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(footer)

func _legend_row(symbol: String, description: String, color: Color) -> Control:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 9)
    var mark := Label.new()
    mark.text = symbol
    mark.custom_minimum_size.x = 28
    mark.add_theme_color_override("font_color", color)
    mark.add_theme_font_size_override("font_size", 15)
    row.add_child(mark)
    var desc := _label(description, 12, MUTED)
    row.add_child(desc)
    return row

func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    draw_rect(rect, BG, true)
    # Ненавязчивая текстура и боковые затемнения.
    for x in range(0, int(size.x), 96):
        draw_line(Vector2(x, 125), Vector2(x, size.y - 55), Color(0.35, 0.40, 0.45, 0.045), 1.0)
    for y in range(130, int(size.y) - 50, 96):
        draw_line(Vector2(24, y), Vector2(size.x - 24, y), Color(0.35, 0.40, 0.45, 0.035), 1.0)

    for link in connections:
        var from_index := int(link["from"])
        var to_index := int(link["to"])
        if from_index < 0 or to_index < 0 or from_index >= map_nodes.size() or to_index >= map_nodes.size():
            continue
        var a: Vector2 = map_nodes[from_index]["pos"]
        var b: Vector2 = map_nodes[to_index]["pos"]
        var active := from_index == current_node or (current_node == -1 and int(map_nodes[from_index]["row"]) == 0)
        var line_color := Color("#b08c54", 0.82) if active else Color("#58636e", 0.42)
        draw_line(a, b, line_color, 3.0 if active else 2.0, true)
        draw_circle((a + b) * 0.5, 3.0, Color("#d8b46a", 0.65) if active else Color("#77818b", 0.45))

func _refresh_button_states() -> void:
    for i in range(buttons.size()):
        var available := _is_available(i)
        var visited := bool(map_nodes[i].get("visited", false))
        buttons[i].disabled = not available or visited
        if visited:
            buttons[i].text = "✓"
            buttons[i].modulate = Color("#87918c")
        elif not available:
            buttons[i].modulate = Color(0.58, 0.62, 0.66, 0.68)
        else:
            buttons[i].modulate = Color.WHITE

func _is_available(index: int) -> bool:
    if current_node == -1:
        return int(map_nodes[index]["row"]) == 0
    for link in connections:
        if int(link["from"]) == current_node and int(link["to"]) == index:
            return true
    return false

func _on_button_pressed(index: int) -> void:
    node_pressed.emit(index)

func _symbol_for(kind: String) -> String:
    match kind:
        "battle": return "Б"
        "elite": return "Э"
        "rest": return "О"
        "event": return "?"
        "boss": return "Б!"
    return "·"

func _name_for(kind: String) -> String:
    match kind:
        "battle": return "Обычный бой"
        "elite": return "Элитный бой"
        "rest": return "Отдых"
        "event": return "Событие"
        "boss": return "Босс"
    return "Точка"
