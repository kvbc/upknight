extends Control

func _ready ():
	visible = false
	Signals.dead.connect(func ():
		visible = true	
	)
	$Button.pressed.connect(func ():
		Signals.restart.emit()	
		visible = false
	)
