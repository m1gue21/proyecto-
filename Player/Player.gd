extends KinematicBody2D

#constantes
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 120
##que es esto?-> lista accseso rapido
enum {
	MOVE,
	ROLL,
	ATTACK
}
#variables
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
onready var animationPlayer = $AnimationPlayer # se esta llamando un nodo de la escena
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	animationTree.active = true #hace q el animation tree funcione al empezar el juego y no antes 
	swordHitbox.knockback_vector = roll_vector
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)
	
	
func move_state(delta): #para mover a el jugador y animar sus movimientos
	var input_vector=Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")#mover derecha izquierda
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")#move arriba abajo
	input_vector = input_vector.normalized()# para  que el movimiento sea igual en todas las direcciones
	#para que el movimiento pare y no sea infinito
	
	if input_vector != Vector2.ZERO:#aca se trabajan las animaciones
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)#para que la animacion empiece con quieto
		animationTree.set("parameters/Run/blend_position", input_vector)##para que al moverse la animacion corra
		animationTree.set("parameters/Attack/blend_position", input_vector) ## direccion de la animacion de atacar
		animationTree.set("parameters/Roll/blend_position", input_vector)##direcion del roll
		animationState.travel("Run")#pata saber en q direccion queda la animacion/ la cruz del blend
		velocity = velocity.move_toward(input_vector * MAX_SPEED, FRICTION * delta) 
	else:
		animationState.travel("Idle")#para que cuando quedemos quieto esta animacion recuerde donde quedó
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	
	if Input.is_action_just_pressed("roll"):#esto genera un salto de move a attack o simplemente hace que se genere attack
		state=ROLL
	
	if Input.is_action_just_pressed("attack"):#esto genera un salto de move a attack o simplemente hace que se genere attack
		state=ATTACK

	move()

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state(delta): #en esta funcion se organiza lo referente a el ataque
	animationState.travel("Attack")
	velocity = Vector2.ZERO
	
func move():
	#herramienta magica de godot
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	state = MOVE ## para que al terminar la animaciion de roll, pasemos a el state move y poder movernos
	velocity = velocity * 0.8
func attack_animation_finished():#para que el ataque no sea infinito y al terminar haya una trancision a el state mover
	state = MOVE
