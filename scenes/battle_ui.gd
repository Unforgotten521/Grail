class_name BattleUI
extends Control

signal back_pressed
signal end_turn_pressed

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

func _build_ui() -> void:
    # Кнопка "В меню" (правый верхний угол)
    back_button = Button.new()
    back_button.text = "В меню"
    back_button.size = Vector2(150, 50)
    back_button.position = Vector2(1750, 20)
    add_child(back_button)

    # Кнопка "Завершить ход" (справа по центру)
    end_turn_button = Button.new()
    end_turn_button.text = "Завершить ход"
    end_turn_button.size = Vector2(200, 60)
    end_turn_button.position = Vector2(1680, 510)
    add_child(end_turn_button)

    # HP игрока (левый нижний угол)
    player_hp_label = Label.new()
    player_hp_label.size = Vector2(350, 50)
    player_hp_label.position = Vector2(50, 880)
    player_hp_label.add_theme_font_size_override("font_size", 24)
    add_child(player_hp_label)

    # Энергия игрока (обновляется при розыгрыше карт и в начале хода)
    energy_label = Label.new()
    energy_label.text = "Энергия: 3/3"
    energy_label.size = Vector2(300, 50)
    energy_label.position = Vector2(50, 820)
    energy_label.add_theme_font_size_override("font_size", 28)
    energy_label.add_theme_color_override("font_color", Color(0.55, 0.75, 1.0))
    add_child(energy_label)

    # HP врага (правый верхний угол)
    enemy_hp_label = Label.new()
    enemy_hp_label.size = Vector2(380, 50)
    enemy_hp_label.position = Vector2(1520, 80)
    enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    enemy_hp_label.add_theme_font_size_override("font_size", 24)
    add_child(enemy_hp_label)

    # Намерение врага (над манекеном)
    intention_label = Label.new()
    intention_label.size = Vector2(400, 50)
    intention_label.position = Vector2(760, 100)
    intention_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intention_label.add_theme_font_size_override("font_size", 28)
    add_child(intention_label)

    # Лог боя (слева по центру)
    log_label = Label.new()
    log_label.size = Vector2(600, 50)
    log_label.position = Vector2(100, 515)
    log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    log_label.add_theme_font_size_override("font_size", 32)
    add_child(log_label)

    # Контейнер карт игрока
    hand_container = HBoxContainer.new()
    hand_container.size = Vector2(1200, 280)
    hand_container.position = Vector2(480, 720)
    hand_container.add_theme_constant_override("separation", 15)
    add_child(hand_container)

    # Манекен
    enemy_sprite = ColorRect.new()
    enemy_sprite.color = Color(0.5, 0.5, 0.5)
    enemy_sprite.size = Vector2(160, 240)
    enemy_sprite.position = Vector2(880, 420)
    add_child(enemy_sprite)

    _build_deck_view()

func _build_deck_view() -> void:
    # Кнопка колоды в правом нижнем углу
    deck_button = Button.new()
    deck_button.text = "Колода: 12"
    deck_button.position = Vector2(1690, 950)
    deck_button.size = Vector2(190, 60)
    deck_button.add_theme_font_size_override("font_size", 20)
    add_child(deck_button)

    # Окно просмотра карт. Оно скрыто до нажатия кнопки.
    deck_panel = PanelContainer.new()
    deck_panel.position = Vector2(1310, 555)
    deck_panel.size = Vector2(560, 365)
    deck_panel.visible = false
    deck_panel.z_index = 10
    add_child(deck_panel)

    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 8)
    deck_panel.add_child(content)

    var header := HBoxContainer.new()
    content.add_child(header)

    var title := Label.new()
    title.text = "Карты в колоде"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_size_override("font_size", 22)
    header.add_child(title)

    var close_button := Button.new()
    close_button.text = "Закрыть"
    close_button.pressed.connect(func(): deck_panel.hide())
    header.add_child(close_button)

    deck_count_label = Label.new()
    deck_count_label.text = "Осталось карт: 0"
    content.add_child(deck_count_label)

    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(520, 280)
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
        var empty_label := Label.new()
        empty_label.text = "Колода пуста. Сброс перемешается при следующем доборе, если в нём есть карты."
        empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        deck_cards_list.add_child(empty_label)
        return

    # Показываем каждую карту, которая сейчас физически лежит в колоде.
    for card_data in deck_manager.deck:
        var row := PanelContainer.new()
        row.custom_minimum_size = Vector2(500, 54)
        deck_cards_list.add_child(row)

        var row_content := VBoxContainer.new()
        row.add_child(row_content)

        var card_name := Label.new()
        var details := "Стоимость: %s" % str(card_data.get("cost", 0))
        if int(card_data.get("damage", 0)) > 0:
            details += "  |  Урон: %s" % str(card_data.get("damage", 0))
        if int(card_data.get("block", 0)) > 0:
            details += "  |  Блок: %s" % str(card_data.get("block", 0))
        card_name.text = "%s — %s" % [card_data.get("name", "Без названия"), details]
        row_content.add_child(card_name)

        var description := Label.new()
        description.text = str(card_data.get("description", ""))
        description.add_theme_font_size_override("font_size", 13)
        row_content.add_child(description)

func update_player_hp(current: int, max_hp: int) -> void:
    var text = "Игрок: %d/%d HP" % [current, max_hp]
    if player_stats and player_stats.block > 0:
        text += " | Блок: %d" % player_stats.block
    player_hp_label.text = text

func update_enemy_hp(current: int, max_hp: int) -> void:
    var name = enemy.enemy_name if enemy else "Враг"
    var text = "%s: %d/%d HP" % [name, current, max_hp]
    if enemy_stats and enemy_stats.block > 0:
        text += " | Блок: %d" % enemy_stats.block
    enemy_hp_label.text = text

func update_energy(current: int, maximum: int) -> void:
    if is_instance_valid(energy_label):
        energy_label.text = "Энергия: %d/%d" % [current, maximum]

func update_intention(text: String) -> void:
    intention_label.text = "⚠ " + text

func update_log(text: String) -> void:
    log_label.text = text
    print(text)

func set_end_turn_enabled(enabled: bool) -> void:
    end_turn_button.disabled = not enabled

func get_hand_container() -> Control:
    return hand_container
