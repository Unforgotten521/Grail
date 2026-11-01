extends Control
## Только отображение карты и передача нажатий в map.gd.

signal node_pressed(index: int)

const NODE_SIZE := Vector2(54, 54)

var map_nodes: Array[Dictionary] = []
var connections: Array[Dictionary] = []
var current_node := -1
var buttons: Array[Button] = []


func update_map(new_nodes: Array[Dictionary], new_connections: Array[Dictionary], selected_node: int) -> void:
    map_nodes = new_nodes
    connections = new_connections
    current_node = selected_node
    _rebuild_buttons()
    queue_redraw()


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
        button.add_theme_font_size_override("font_size", 20)
        button.add_theme_color_override("font_color", Color.WHITE)
        button.pressed.connect(_on_button_pressed.bind(i))
        add_child(button)
        buttons.append(button)

    _refresh_button_states()


func _draw() -> void:
    for link in connections:
        var from_index := int(link["from"])
        var to_index := int(link["to"])
        if from_index >= map_nodes.size() or to_index >= map_nodes.size():
            continue
        var a: Vector2 = map_nodes[from_index]["pos"]
        var b: Vector2 = map_nodes[to_index]["pos"]
        draw_line(a, b, Color(0.48, 0.43, 0.36, 0.8), 4.0, true)


func _refresh_button_states() -> void:
    for i in range(buttons.size()):
        var available := _is_available(i)
        var visited := bool(map_nodes[i].get("visited", false))
        buttons[i].disabled = not available or visited
        if visited:
            buttons[i].text = "•"
            buttons[i].modulate = Color(0.65, 0.65, 0.65, 0.8)
        else:
            buttons[i].modulate = Color.WHITE if available else Color(0.48, 0.48, 0.48, 0.65)


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
