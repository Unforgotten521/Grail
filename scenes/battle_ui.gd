class_name BattleUI
extends Control

signal back_pressed
signal end_turn_pressed

const BG := Color("#11151b")
const PANEL := Color("#1c242d")
const PANEL_LIGHT := Color("#27323d")
const GOLD := Color("#d8b46a")
const MUTED := Color("#aab4bf")
const RED := Color("#d96c68")
const BLUE := Color("#75a9d8")

var back_button: Button
var end_turn_button: Button
var player_hp_label: Label
var enemy_hp_label: Label
var intention_label: Label
var log_label: Label
var energy_label: Label
var hand_container: HBoxContainer
var enemy_sprite: ColorRect

var deck_button: Button
var deck_panel: PanelContainer
var deck_count_label: Label
var deck_cards_list: VBoxContainer
var deck_manager: DeckManager

var player_stats: CombatStats
var enemy_stats: CombatStats
var enemy: Enemy

func _ready() -> void:
    _build_ui()
    back_button.pressed.connect(func(): back_pressed.emit())
    end_turn_button.pressed.connect(func(): end_turn_pressed.emit())
    deck_button.pressed.connect(_toggle_deck_panel)

func _panel_style(color: Color, border_color: Color = Color("#394653"), radius: int = 12) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = border_color
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
    var result := Label.new()
    result.text = text
    result.add_theme_font_size_override("font_size", font_size)
    result.add_theme_color_override("font_color", color)
    return result

func _build_ui() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_PASS

    var background := ColorRect.new()
    background.color = BG
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)

    # Верхняя панель: состояние обеих сторон боя.
    var top := PanelContainer.new()
    top.set_anchors_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 24
    top.offset_top = 18
    top.offset_right = -24
    top.offset_bottom = 112
    top.add_theme_stylebox_override("panel", _panel_style(BG, BG, 0))
    add_child(top)

    var top_row := HBoxContainer.new()
    top_row.add_theme_constant_override("separation", 24)
    top.add_child(top_row)

    var player_box := VBoxContainer.new()
    player_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    player_box.add_theme_constant_override("separation", 5)
    top_row.add_child(player_box)
    player_box.add_child(_label("ПУТНИК", 14, MUTED))
    player_hp_label = _label("50 / 50 HP", 24)
    player_box.add_child(player_hp_label)

    var center_title := VBoxContainer.new()
    center_title.alignment = BoxContainer.ALIGNMENT_CENTER
    center_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_title.add_child(_label("GRAIL  •  СРАЖЕНИЕ", 18, GOLD))
    var subtitle := _label("Испытай свою волю", 13, MUTED)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_title.add_child(subtitle)
    top_row.add_child(center_title)

    var enemy_box := VBoxContainer.new()
    enemy_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    enemy_box.alignment = BoxContainer.ALIGNMENT_END
    enemy_box.add_theme_constant_override("separation", 5)
    top_row.add_child(enemy_box)
    var enemy_caption := _label("ПРОТИВНИК", 14, MUTED)
    enemy_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    enemy_box.add_child(enemy_caption)
    enemy_hp_label = _label("Враг: 30 / 30 HP", 24)
    enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    enemy_box.add_child(enemy_hp_label)

    back_button = Button.new()
    back_button.text = "В меню"
    back_button.custom_minimum_size = Vector2(112, 38)
    back_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
    back_button.position = Vector2(24, 130)
    back_button.z_index = 5
    back_button.add_theme_stylebox_override("normal", _panel_style(PANEL_LIGHT))
    back_button.add_theme_font_size_override("font_size", 15)
    add_child(back_button)

    # Центральная арена.
    var arena := PanelContainer.new()
    arena.set_anchors_preset(Control.PRESET_FULL_RECT)
    # Ограничиваем фон арены по ширине, чтобы он не заходил на кнопку меню.
    arena.offset_left = 150
    arena.offset_top = 132
    arena.offset_right = -150
    arena.offset_bottom = -356
    arena.add_theme_stylebox_override("panel", _panel_style(Color("#141a21"), Color("#141a21"), 0))
    add_child(arena)

    var arena_content := Control.new()
    arena_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    arena_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    arena.add_child(arena_content)

    intention_label = _label("⚠ Ожидает действия", 20, GOLD)
    intention_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intention_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    intention_label.position = Vector2(-220, 24)
    intention_label.size = Vector2(440, 42)
    arena_content.add_child(intention_label)

    var enemy_frame := PanelContainer.new()
    enemy_frame.set_anchors_preset(Control.PRESET_CENTER)
    enemy_frame.position = Vector2(-96, -96)
    enemy_frame.size = Vector2(192, 192)
    enemy_frame.add_theme_stylebox_override("panel", _panel_style(Color("#242d37"), Color("#596575"), 16))
    arena_content.add_child(enemy_frame)

    var enemy_inner := VBoxContainer.new()
    enemy_inner.alignment = BoxContainer.ALIGNMENT_CENTER
    enemy_inner.add_theme_constant_override("separation", 8)
    enemy_frame.add_child(enemy_inner)

    var sigil := _label("✦", 82, Color("#c4a16b"))
    sigil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    enemy_inner.add_child(sigil)
    var enemy_name_label := _label("ВРАГ", 16, MUTED)
    enemy_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    enemy_inner.add_child(enemy_name_label)

    # Оставляем переменную для совместимости с существующим кодом.
    enemy_sprite = ColorRect.new()
    enemy_sprite.color = Color(0, 0, 0, 0)
    enemy_sprite.size = Vector2.ZERO

    var log_panel := PanelContainer.new()
    log_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    log_panel.position = Vector2(18, -124)
    log_panel.size = Vector2(420, 64)
    log_panel.add_theme_stylebox_override("panel", _panel_style(Color("#202a33"), Color("#394653"), 10))
    arena_content.add_child(log_panel)
    log_label = _label("Бой начался.", 15, Color("#d6dce2"))
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    log_panel.add_child(log_label)

    # Нижняя зона с рукой карт.
    var bottom := PanelContainer.new()
    bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    bottom.offset_left = 24
    bottom.offset_top = -390
    bottom.offset_right = -24
    bottom.offset_bottom = -24
    bottom.add_theme_stylebox_override("panel", _panel_style(BG, BG, 0))
    add_child(bottom)

    var bottom_layout := VBoxContainer.new()
    bottom_layout.add_theme_constant_override("separation", 8)
    bottom.add_child(bottom_layout)

    var controls_row := HBoxContainer.new()
    controls_row.add_theme_constant_override("separation", 12)
    bottom_layout.add_child(controls_row)

    energy_label = _label("ЭНЕРГИЯ   3 / 3", 18, BLUE)
    energy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    controls_row.add_child(energy_label)

    deck_button = Button.new()
    deck_button.text = "Колода: 12"
    deck_button.custom_minimum_size = Vector2(140, 38)
    deck_button.add_theme_font_size_override("font_size", 15)
    deck_button.add_theme_stylebox_override("normal", _panel_style(PANEL_LIGHT))
    controls_row.add_child(deck_button)

    end_turn_button = Button.new()
    end_turn_button.text = "Завершить ход  →"
    end_turn_button.custom_minimum_size = Vector2(190, 42)
    end_turn_button.add_theme_font_size_override("font_size", 16)
    end_turn_button.add_theme_color_override("font_color", Color("#171b20"))
    var end_style := _panel_style(GOLD, GOLD, 10)
    end_turn_button.add_theme_stylebox_override("normal", end_style)
    end_turn_button.add_theme_stylebox_override("hover", _panel_style(Color("#edca82"), Color("#edca82"), 10))
    end_turn_button.add_theme_stylebox_override("disabled", _panel_style(Color("#665b45"), Color("#665b45"), 10))
    controls_row.add_child(end_turn_button)

    hand_container = HBoxContainer.new()
    hand_container.alignment = BoxContainer.ALIGNMENT_CENTER
    hand_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hand_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hand_container.add_theme_constant_override("separation", 12)
    bottom_layout.add_child(hand_container)

    _build_deck_view()

func _build_deck_view() -> void:
    deck_panel = PanelContainer.new()
    deck_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    deck_panel.position = Vector2(-590, -430)
    deck_panel.size = Vector2(560, 390)
    deck_panel.visible = false
    deck_panel.z_index = 10
    deck_panel.add_theme_stylebox_override("panel", _panel_style(Color("#202a33"), Color("#657383"), 14))
    add_child(deck_panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    deck_panel.add_child(content)

    var header := HBoxContainer.new()
    content.add_child(header)
    var title := _label("Карты в колоде", 20, GOLD)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)

    var close_button := Button.new()
    close_button.text = "Закрыть"
    close_button.pressed.connect(func(): deck_panel.hide())
    header.add_child(close_button)

    deck_count_label = _label("Осталось карт: 0", 14, MUTED)
    content.add_child(deck_count_label)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(520, 300)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(scroll)

    deck_cards_list = VBoxContainer.new()
    deck_cards_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(deck_cards_list)

func set_deck_manager(manager: DeckManager) -> void:
    if deck_manager and deck_manager.deck_changed.is_connected(_refresh_deck_view):
        deck_manager.deck_changed.disconnect(_refresh_deck_view)
    deck_manager = manager
    if deck_manager:
        deck_manager.deck_changed.connect(_refresh_deck_view)
    _refresh_deck_view()

func _toggle_deck_panel() -> void:
    deck_panel.visible = not deck_panel.visible
    if deck_panel.visible:
        _refresh_deck_view()

func _refresh_deck_view() -> void:
    if not is_instance_valid(deck_button) or not is_instance_valid(deck_count_label):
        return
    var remaining: int = deck_manager.deck.size() if deck_manager else 0
    deck_button.text = "Колода: %d" % remaining
    deck_count_label.text = "Осталось карт: %d" % remaining

    for child in deck_cards_list.get_children():
        deck_cards_list.remove_child(child)
        child.queue_free()

    if deck_manager == null or deck_manager.deck.is_empty():
        var empty_label := _label("Колода пуста. Сброс перемешается при следующем доборе, если в нём есть карты.", 14, MUTED)
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        deck_cards_list.add_child(empty_label)
        return

    for card_data in deck_manager.deck:
        var row := PanelContainer.new()
        row.custom_minimum_size = Vector2(500, 54)
        row.add_theme_stylebox_override("panel", _panel_style(Color("#28333e"), Color("#394653"), 8))
        deck_cards_list.add_child(row)
        var row_content := VBoxContainer.new()
        row.add_child(row_content)
        var card_name := _label("", 15)
        var details := "Стоимость: %s" % str(card_data.get("cost", 0))
        if int(card_data.get("damage", 0)) > 0:
            details += "  |  Урон: %s" % str(card_data.get("damage", 0))
        if int(card_data.get("block", 0)) > 0:
            details += "  |  Блок: %s" % str(card_data.get("block", 0))
        card_name.text = "%s — %s" % [card_data.get("name", "Без названия"), details]
        row_content.add_child(card_name)
        var description := _label(str(card_data.get("description", "")), 13, MUTED)
        row_content.add_child(description)

func update_player_hp(current: int, max_hp: int) -> void:
    var text := "Путник   %d / %d HP" % [current, max_hp]
    if player_stats and player_stats.block > 0:
        text += "    ◈ %d" % player_stats.block
    player_hp_label.text = text

func update_enemy_hp(current: int, max_hp: int) -> void:
    var name := enemy.enemy_name if enemy else "Враг"
    var text := "%s   %d / %d HP" % [name, current, max_hp]
    if enemy_stats and enemy_stats.block > 0:
        text += "    ◈ %d" % enemy_stats.block
    enemy_hp_label.text = text

func update_energy(current: int, maximum: int) -> void:
    if is_instance_valid(energy_label):
        energy_label.text = "ЭНЕРГИЯ   %d / %d" % [current, maximum]

func update_intention(text: String) -> void:
    intention_label.text = "⚠  " + text

func update_log(text: String) -> void:
    log_label.text = text
    print(text)

func set_end_turn_enabled(enabled: bool) -> void:
    end_turn_button.disabled = not enabled

func get_hand_container() -> Control:
    return hand_container
