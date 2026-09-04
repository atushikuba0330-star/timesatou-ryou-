extends Sprite2D

func _ready():
	$spearsparkexplosion.visible = false


func play_spark():

	frame = 0

	for i in range(hframes * vframes):

		frame = i

		await get_tree().create_timer(0.05).timeout



	# explosion開始
	$spearsparkexplosion.visible = true

	await $spearsparkexplosion.play_explosion()
