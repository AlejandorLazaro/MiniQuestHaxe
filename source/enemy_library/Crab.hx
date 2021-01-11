package enemy_library;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

using flixel.util.FlxSpriteUtil;

class Crab extends Enemy
{
	static inline var SPEED:Float = 60;

	override public function new(x:Float, y:Float)
	{
		super(x, y, "preconfigured");
		loadGraphic(AssetPaths.Crab__png, true, 10, 10);
		animation.add("idle", [0, 1], 6, false);
		drag.x = drag.y = 10;
		width = 10;
		height = 10;

		enemyMaxHealth = 2;
		health = enemyMaxHealth;

		state = IDLE; // Initially this enemy starts off idle
		idleTimer = 0;
		playerPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if (!isActive)
			return;
		if (this.isFlickering())
			return;
		else
		{
			animation.play("idle");
			idleBehavior(elapsed);
		}
		super.update(elapsed);
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
				moveDirection = FlxG.random.int(0, 8, [1, 7]) * 90;

				velocity.set(SPEED * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), moveDirection);
			}
			idleTimer = FlxG.random.int(1, 4);
		}
		else
			idleTimer -= elapsed;
	}
}
