class_name DeckManager
extends Node

signal deck_changed
signal energy_changed(current: int, maximum: int)

const CARD_SCENE := preload("res://scenes/card.tscn")
const STARTING_ENERGY := 3
const STARTING_HAND_SIZE := 5

var hand_container: Control
var player_stats: CombatStats
var enemy_stats: CombatStats
var log_func: Callable

var deck: Array = []
var hand: Array = []
var discard: Array = []
var all_cards: Dictionary = {}

var max_energy: int = STARTING_ENERGY
var energy: int = STARTING_ENERGY
var can_play_cards: bool = true

func setup(container: Control, p_stats: CombatStats, e_stats: CombatStats, log: Callable) -> void:
    hand_container = container
    player_stats = p_stats
    enemy_stats = e_stats
    log_func = log

    load_cards_from_json()
    create_starting_deck()
    energy = max_energy
    can_play_cards = true
    draw_cards(STARTING_HAND_SIZE)
    energy_changed.emit(energy, max_energy)

func load_cards_from_json() -> void:
    var file := FileAccess.open("res://data/cards.json", FileAccess.READ)
    if file == null:
        push_error("Не найден res://data/cards.json")
        return

    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        push_error("Ошибка JSON в cards.json")
        return

    all_cards.clear()
    for card_data in json.data:
        all_cards[card_data["id"]] = card_data

func create_starting_deck() -> void:
    deck.clear()
    hand.clear()
    discard.clear()

    # Стартовая колода: 4 обычных удара, 4 тяжёлых удара и 4 защиты.
    _add_cards_to_deck("strike", 4)
    _add_cards_to_deck("heavy_strike", 4)
    _add_cards_to_deck("defend", 4)
    deck.shuffle()
    deck_changed.emit()

func _add_cards_to_deck(card_id: String, amount: int) -> void:
    if not all_cards.has(card_id):
        push_error("В cards.json не найдена карта: " + card_id)
        return

    for i in range(amount):
        deck.append(all_cards[card_id].duplicate(true))

func draw_cards(count: int) -> void:
    for i in range(count):
        if deck.is_empty():
            if discard.is_empty():
                break

            # Колода закончилась: возвращаем сброс и перемешиваем.
            deck.append_array(discard)
            discard.clear()
            deck.shuffle()

        if not deck.is_empty():
            hand.append(deck.pop_back())

    update_hand_display()

func play_card(index: int) -> void:
    if not can_play_cards:
        return

    if index < 0 or index >= hand.size():
        return

    var card: Dictionary = hand[index]
    var cost: int = int(card.get("cost", 0))

    if cost > energy:
        if log_func.is_valid():
            log_func.call("Недостаточно энергии! Нужно: %d, доступно: %d." % [cost, energy])
        return

    # Сначала тратим энергию, затем применяем эффект карты.
    energy -= cost
    energy_changed.emit(energy, max_energy)

    _apply_effects(card)
    hand.remove_at(index)
    discard.append(card)
    update_hand_display()

func _apply_effects(card: Dictionary) -> void:
    var damage: int = int(card.get("damage", 0))
    var block: int = int(card.get("block", 0))

    if damage > 0 and enemy_stats:
        enemy_stats.take_damage(damage)
        if log_func.is_valid():
            log_func.call("%s наносит %d урона!" % [card["name"], damage])

    if block > 0 and player_stats:
        player_stats.add_block(block)
        if log_func.is_valid():
            log_func.call("%s даёт %d блока!" % [card["name"], block])

func end_turn() -> void:
    can_play_cards = false
    discard.append_array(hand)
    hand.clear()
    draw_cards(STARTING_HAND_SIZE)

func start_player_turn() -> void:
    energy = max_energy
    can_play_cards = true
    energy_changed.emit(energy, max_energy)
    if log_func.is_valid():
        log_func.call("Ваша энергия восстановлена: %d/%d." % [energy, max_energy])

func update_hand_display() -> void:
    if hand_container == null:
        push_error("HandContainer не задан")
        return

    for child in hand_container.get_children():
        hand_container.remove_child(child)
        child.queue_free()

    for i in range(hand.size()):
        var card_data: Dictionary = hand[i]
        var card: Card = CARD_SCENE.instantiate()
        hand_container.add_child(card)
        card.setup(card_data)
        card.clicked.connect(_on_card_clicked.bind(i))

    # Обновляем счётчик и окно просмотра колоды.
    deck_changed.emit()

func _on_card_clicked(index: int) -> void:
    play_card(index)
