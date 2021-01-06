package enemy_library;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class Miasma extends Enemy
{
	static inline var SPEED:Float = 60;

	var swarmTimer:Float;
	var everBeenEnraged:Bool;

	override public function new(x:Float, y:Float)
	{
		super(x, y, "preconfigured");
		loadGraphic(AssetPaths.Miasma__png, true, 10, 10);
		animation.add("idle", [0, 1], 6, false);
		drag.x = drag.y = 10;
		width = 10;
		height = 10;

		enemyMaxHealth = 2;
		health = enemyMaxHealth;

		state = IDLE; // Initially this enemy starts off idle
		everBeenEnraged = false;
		idleTimer = 0;
		swarmTimer = 0;
		playerPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if (this.isFlickering())
			return;
		else if (state == SWARMING)
		{
			// Chase after the player until line of sight is lost
			animation.play("idle"); // Update this later when there's a unique animation for it
			swarmingBehavior(elapsed);
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
		if (everBeenEnraged)
		{
			swarmTimer = FlxG.random.int(2, 4);
			state = SWARMING;
			playerPosition = point;
		}
	}

	override public function onSeingAllyKilled(point:FlxPoint)
	{
		everBeenEnraged = true;
		swarmTimer = FlxG.random.int(5, 8);
		state = SWARMING;
		playerPosition = point;
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
			if (this.getPosition().distanceTo(playerPosition) > 10)
			{
				FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(SPEED));
			}
			swarmTimer -= elapsed;
		}
		else
		{
			state = IDLE;
		}
	}
}
