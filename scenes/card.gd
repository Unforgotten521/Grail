
class_name Card
extends Control

signal clicked

var card_data: Dictionary = {}
var card_ui: Control

func _ready() -> void:
    custom_minimum_size = Vector2(180, 260)
    mouse_filter = Control.MOUSE_FILTER_STOP

    card_ui = preload("res://scenes/card_ui.gd").new()
    add_child(card_ui)

    # Внутренние элементы не должны перехватывать мышь.
    _set_mouse_filter_recursive(card_ui)

    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _set_mouse_filter_recursive(node: Node) -> void:
    if node is Control:
        node.mouse_filter = Control.MOUSE_FILTER_IGNORE

    for child in node.get_children():
        _set_mouse_filter_recursive(child)

func setup(data: Dictionary) -> void:
    card_data = data
    if is_instance_valid(card_ui):
        card_ui.fill(data)

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton \
    and event.button_index == MOUSE_BUTTON_LEFT \
    and event.pressed:
        clicked.emit()
        accept_event()

func _on_mouse_entered() -> void:
    if is_instance_valid(card_ui):
        card_ui.hover_in()

func _on_mouse_exited() -> void:
    if is_instance_valid(card_ui):
        card_ui.hover_out()
