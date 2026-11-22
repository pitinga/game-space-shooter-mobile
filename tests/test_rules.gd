extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	game.pointer(Vector2(2.0, 0.8))
	check(game.player_x <= 0.93, "nave limitada à direita")
	game.pointer(Vector2(-1.0, 0.8))
	check(game.player_x >= 0.07, "nave limitada à esquerda")
	game.player_x = 0.5
	game.fire()
	check(game.bullets.size() == 1, "disparo manual")
	game.enemies.append(Vector2(0.5, 0.79))
	game.tick(0.02)
	check(game.score == 10 and game.enemies.is_empty(), "tiro elimina inimigo")
	game.enemies.append(Vector2(0.1, 1.049))
	game.tick(0.02)
	check(game.lives == 2, "inimigo perdido desconta vida")
	game.reset()
	check(game.enemies.is_empty() and game.bullets.is_empty() and game.score == 0, "reinício limpo")
	finish()


func finish() -> void:
	print("Space Shooter: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
