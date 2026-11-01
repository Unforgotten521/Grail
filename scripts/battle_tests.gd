extends SceneTree

# Запуск из корня проекта:
# godot --headless --path . -s res://scripts/battle_tests.gd
# Если сохраняешь файл в другой папке, поправь путь в команде.

func _initialize() -> void:
    call_deferred("_run_tests")


func _run_tests() -> void:
    print("\n=== ПРОВЕРКИ БОЕВОЙ СИСТЕМЫ ===")
    _test_block_reduces_damage()
    _test_hp_never_below_zero()
    _test_dead_enemy_does_not_attack()
    print("=== ПРОВЕРКИ ЗАВЕРШЕНЫ ===\n")
    quit()


func _test_block_reduces_damage() -> void:
    var stats := CombatStats.new()
    root.add_child(stats)
    stats.max_hp = 50
    stats.current_hp = 50
    stats.add_block(5)
    stats.take_damage(6)
    _assert_equal("Защита 5 + удар 6 -> потеря 1 HP", stats.current_hp, 49)
    stats.free()


func _test_hp_never_below_zero() -> void:
    var stats := CombatStats.new()
    root.add_child(stats)
    stats.max_hp = 3
    stats.current_hp = 3
    stats.take_damage(10)
    _assert_equal("HP не опускается ниже нуля", stats.current_hp, 0)
    stats.free()


func _test_dead_enemy_does_not_attack() -> void:
    var player_stats := CombatStats.new()
    root.add_child(player_stats)
    player_stats.max_hp = 50
    player_stats.current_hp = 50

    var enemy := Enemy.new()
    enemy.enemy_name = "Тестовый враг"
    enemy.base_damage = 8
    root.add_child(enemy)

    var enemy_stats := CombatStats.new()
    enemy_stats.max_hp = 10
    enemy.add_child(enemy_stats)
    enemy_stats.current_hp = 0

    # Принудительно вызываем метод атаки после смерти:
    # сам Enemy должен заблокировать действие.
    enemy.current_intention = "Атака: 8"
    enemy.execute_intention(player_stats)
    _assert_equal("Мёртвый враг не наносит урон", player_stats.current_hp, 50)

    enemy.free()
    player_stats.free()


func _assert_equal(test_name: String, actual: int, expected: int) -> void:
    if actual == expected:
        print("PASS: ", test_name)
    else:
        print("FAIL: ", test_name, " | ожидалось ", expected, ", получено ", actual)
