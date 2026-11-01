extends Control

const CARD_SIZE := Vector2(180, 260)
const HOVER_OFFSET := 20.0
const HOVER_SCALE := 1.1

var bg: ColorRect
var border: ColorRect
var cost_bg: ColorRect
var cost_label: Label
var type_icon: Label
var name_label: Label
var desc_label: Label
var original_y: float = 0.0

func _ready() -> void:
    size = CARD_SIZE
    custom_minimum_size = CARD_SIZE  # ← ДОБАВИТЬ ЭТУ СТРОКУ
    original_y = position.y
    _build()

func _build() -> void:
    # Фон карты
    bg = ColorRect.new()
    bg.color = Color(0.15, 0.15, 0.2)
    bg.size = CARD_SIZE
    add_child(bg)
    
    # Рамка
    border = ColorRect.new()
    border.color = Color(0.5, 0.5, 0.6)
    border.size = Vector2(CARD_SIZE.x - 4, CARD_SIZE.y - 4)
    border.position = Vector2(2, 2)
    add_child(border)
    
    cost_label = Label.new()
    cost_label.text = "0"
    cost_label.size = Vector2(44, 44)
    cost_label.position = Vector2(8, 8)
    cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    cost_label.add_theme_font_size_override("font_size", 26)
    cost_label.add_theme_color_override("font_color", Color(0.1, 0.05, 0))
    add_child(cost_label)
    
    # Иконка типа (правый верхний угол)
    type_icon = Label.new()
    type_icon.text = "✦"
    type_icon.size = Vector2(40, 40)
    type_icon.position = Vector2(CARD_SIZE.x - 48, 8)
    type_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    type_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    type_icon.add_theme_font_size_override("font_size", 30)
    add_child(type_icon)
    
    # Название карты
    name_label = Label.new()
    name_label.text = "Название"
    name_label.size = Vector2(CARD_SIZE.x - 20, 40)
    name_label.position = Vector2(10, 60)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_font_size_override("font_size", 22)
    name_label.add_theme_color_override("font_color", Color(1, 1, 1))
    add_child(name_label)
    
    # Разделительная линия
    var divider = ColorRect.new()
    divider.color = Color(0.4, 0.4, 0.5)
    divider.size = Vector2(CARD_SIZE.x - 30, 2)
    divider.position = Vector2(10, 105)
    add_child(divider)
    
    # Описание карты
    desc_label = Label.new()
    desc_label.text = "Описание эффекта карты"
    desc_label.size = Vector2(CARD_SIZE.x - 30, 130)
    desc_label.position = Vector2(-10, 115)
    desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    desc_label.add_theme_font_size_override("font_size", 16)
    desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
    add_child(desc_label)

func fill(data: Dictionary) -> void:
    name_label.text = data.get("name", "Без названия")
    desc_label.text = data.get("description", "Нет описания")
    cost_label.text = str(data.get("cost", 0))
    
    var card_type: String = data.get("type", "")
    match card_type:
        "attack":
            bg.color = Color(0.35, 0.08, 0.08)
            border.color = Color(0.9, 0.2, 0.2)
            type_icon.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
            name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.85))
        "skill":
            bg.color = Color(0.08, 0.15, 0.35)
            border.color = Color(0.3, 0.6, 1)
            type_icon.add_theme_color_override("font_color", Color(0.6, 0.85, 1))
            name_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1))
        _:
            bg.color = Color(0.15, 0.15, 0.2)
            border.color = Color(0.5, 0.5, 0.6)
            type_icon.text = "✦"

var hover_tween: Tween

func hover_in() -> void:
    if hover_tween and hover_tween.is_running():
        hover_tween.kill()

    pivot_offset = size / 2.0

    hover_tween = create_tween()
    hover_tween.set_parallel(true)
    hover_tween.tween_property(
        self, "position:y", original_y - HOVER_OFFSET, 0.15
    )
    hover_tween.tween_property(
        self, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.15
    )

func hover_out() -> void:
    if hover_tween and hover_tween.is_running():
        hover_tween.kill()

    hover_tween = create_tween()
    hover_tween.set_parallel(true)
    hover_tween.tween_property(
        self, "position:y", original_y, 0.15
    )
    hover_tween.tween_property(
        self, "scale", Vector2.ONE, 0.15
    )
