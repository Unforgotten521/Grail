extends SceneTree

func _initialize() -> void:
    call_deferred("_run_test")

func _run_test() -> void:
    var manager := DeckManager.new()
    root.add_child(manager)

    manager.hand_container = Control.new()
    root.add_child(manager.hand_container)

    manager.deck = [
        {"id": "card_1", "name": "Карта 1"},
        {"id": "card_2", "name": "Карта 2"}
    ]

    manager.discard = [
        {"id": "card_3", "name": "Карта 3"},
        {"id": "card_4", "name": "Карта 4"},
        {"id": "card_5", "name": "Карта 5"},
        {"id": "card_6", "name": "Карта 6"}
    ]

    manager.hand.clear()

    print("\n=== ТЕСТ ДОБОРА КАРТ ===")

    manager.draw_cards(5)

    _assert_equal("В руке 5 карт", manager.hand.size(), 5)
    _assert_equal("В сбросе 0 карт", manager.discard.size(), 0)
    _assert_equal("В колоде осталась 1 карта", manager.deck.size(), 1)

    var all_ids := {}
    for card in manager.hand:
        all_ids[card["id"]] = true
    for card in manager.deck:
        all_ids[card["id"]] = true

    _assert_equal("Все 6 карт сохранены", all_ids.size(), 6)

    print("=== ТЕСТ ЗАВЕРШЁН ===")
    quit()

func _assert_equal(test_name: String, actual: int, expected: int) -> void:
    if actual == expected:
        print("PASS: ", test_name)
    else:
        print("FAIL: ", test_name,
            " | ожидалось ", expected,
            ", получено ", actual)
