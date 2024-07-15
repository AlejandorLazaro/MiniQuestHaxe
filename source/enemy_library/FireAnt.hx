package enemy_library;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class FireAnt extends Enemy
{
	static inline var SPEED:Float = 80;
	public static var MAX_HEALTH:Int = 10;
	public static var EXPERIENCE:Int = 10;
	public static var TOUCH_DAMAGE:Int = 5;

	var swarmTimer:Float;
	var isRunning:Bool;

	override public function new(x:Float, y:Float)
	{
		super(x, y, "preconfigured");
		loadGraphic(AssetPaths.FireAnt__png, true, 10, 10);
		animation.add("idle", [0, 1], 6, false);
		drag.x = drag.y = 10;
		setSize(6, 7);
		offset.set(2, 3);

		enemyMaxHealth = MAX_HEALTH;
		health = enemyMaxHealth;

		state = IDLE; // Initially this enemy starts off idle
		idleTimer = 0;
		swarmTimer = 0;
		playerPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if (!isActive)
			return;
		if (this.isFlickering())
			return;
		else if (state == SWARMING)
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
		if (isAggressive)
		{
			swarmTimer = FlxG.random.int(2, 4);
			state = SWARMING;
			playerPosition = point;
		}
		else if (isRunning)
		{
			state = RUNNING;
			playerPosition = point;
		}
	}

	override public function onBeingInjured(point:FlxPoint, damage:Int = 1)
	{
		super.onBeingInjured(point, damage);

		if (health <= 2)
		{
			isAggressive = false;
			isRunning = true;
			state = RUNNING;
		}
		else
			isAggressive = true;
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

	function swarmingBehavior(elapsed:Float)
	{
		if (swarmTimer > 0)
		{
			if (this.getPosition().distanceTo(playerPosition) > 2)
			{
				FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(SPEED));
			}
			else
			{
				state = IDLE;
			}
			swarmTimer -= elapsed;
		}
		else
		{
			state = IDLE;
		}
	}

	function runningBehavior(elapsed:Float)
	{
		if (this.getPosition().distanceTo(playerPosition) < 20)
		{
			// var runningAngle = -this.getPosition().angleBetween(playerPosition);
			FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(SPEED * .5));
			velocity.rotate(FlxPoint.weak(0, 0), -this.getPosition().angleBetween(playerPosition));
		}
		else
		{
			state = IDLE;
		}
	}

	override public function getTouchDamage()
	{
		return TOUCH_DAMAGE;
	}

	override public function getExperience()
	{
		return EXPERIENCE;
	}
}
