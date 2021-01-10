package enemy_library;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class SandCreep extends Enemy
{
	static inline var SPEED:Float = 40;
	static inline var MAX_AGGRO_RANGE:Float = 65;

	var swarmTimer:Float;
	var runningTimer:Float;
	var everBeenInjured:Bool;

	override public function new(x:Float, y:Float)
	{
		super(x, y, "preconfigured");
		loadGraphic(AssetPaths.SandCreep__png, true, 10, 10);
		animation.add("idle", [0, 1], 6, false);
		drag.x = drag.y = 10;
		width = 10;
		height = 10;

		enemyMaxHealth = 2;
		health = enemyMaxHealth;

		state = IDLE; // Initially this enemy starts off idle
		everBeenInjured = false;
		idleTimer = 0;
		swarmTimer = 0;
		runningTimer = 0;
		playerPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if (state == SWARMING)
		{
			// Chase after the player until line of sight is lost
			animation.play("idle"); // Update this later when there's a unique animation for it
			swarmingBehavior(elapsed);
		}
		else if (state == RUNNING)
		{
			animation.play("idle");
			runningBehavior(elapsed);
		}
		else
		{
			animation.play("idle");
			idleBehavior(elapsed);
		}
		super.update(elapsed);
	}

	override public function onSeeingEnemyEntity(point:FlxPoint)
	{
		playerPosition = point;
		if (state != RUNNING && this.getMidpoint().distanceTo(playerPosition) < MAX_AGGRO_RANGE)
		{
			swarmTimer = FlxG.random.int(1, 2);
			state = SWARMING;
		}
	}

	override public function onBeingInjured(point:FlxPoint)
	{
		this.flicker();
		health--;
		everBeenInjured = true;
		state = RUNNING;
		runningTimer = FlxG.random.int(2, 3);
		var angleToAttacker = this.getMidpoint().angleBetween(point);
		velocity.set(SPEED * 2, 0);
		velocity.rotate(FlxPoint.weak(0, 0), -angleToAttacker);
	}

	override public function onEnemyContact(point:FlxPoint)
	{
		state = RUNNING;
		runningTimer = FlxG.random.int(1, 2);
		var angleToAttacker = this.getMidpoint().angleBetween(point);
		velocity.set(SPEED * 1.5, 0);
		velocity.rotate(FlxPoint.weak(0, 0), -angleToAttacker);
	}

	function idleBehavior(elapsed:Float)
	{
		if (idleTimer <= 0)
		{
			if (FlxG.random.bool(1))
			{
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				moveDirection = FlxG.random.int(0, 8) * 45;

				velocity.set(SPEED * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), moveDirection);
			}
			idleTimer = FlxG.random.int(1, 4);
		}
		else
			idleTimer -= elapsed;
	}

	function runningBehavior(elapsed:Float)
	{
		if (runningTimer > 0)
		{
			runningTimer -= elapsed;
		}
		else
		{
			state = IDLE;
		}
	}

	function swarmingBehavior(elapsed:Float)
	{
		if (swarmTimer > 0 && this.getMidpoint().distanceTo(playerPosition) < MAX_AGGRO_RANGE)
		{
			if (this.getPosition().distanceTo(playerPosition) > 3)
			{
				FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(SPEED * 0.5));
			}
			swarmTimer -= elapsed;
		}
		else
		{
			state = IDLE;
		}
	}
}
