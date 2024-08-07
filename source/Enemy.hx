package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

using flixel.util.FlxSpriteUtil;

enum EnemyState
{
	IDLE;
	SWARMING;
	RUNNING;
}

class Enemy extends FlxSprite
{
	public static var SPEED:Float;

	// Calculated based on the game dimensions in the Main.hx FlxGame params.
	// Be sure it's roughly the following: sqrt((2x/3)^2+(2y/3)^2);x=width,y=height
	public var ACTIVE_RANGE:Float = 175;

	// Absurd sentinel values used here to ensure these are always overridden by inherited enemies
	public static var MAX_HEALTH:Int = 100;
	public static var TOUCH_DAMAGE:Int = 100;
	public static var EXPERIENCE:Int = 100;

	var name:String;

	var idleTimer:Float;
	var moveDirection:Float;

	public var enemyMaxHealth:Int;
	public var isActive:Bool = false;
	public var isAggressive:Bool = false;
	public var state:EnemyState;
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	public function new(x:Float, y:Float, name:String)
	{
		super(x, y);
		if (name != "preconfigured") // Only set values when another inherited class didn't already do it
		{
			setPropertiesForName(name);
			animation.add("idle", [0, 1], 6, false);
			drag.x = drag.y = 10;
			width = 10;
			height = 10;

			idleTimer = 0;
			playerPosition = FlxPoint.get();
		}
	}

	override public function update(elapsed:Float)
	{
		if (name != "preconfigured") // Only set values when another inherited class didn't already do it
		{
			if (!isActive)
				return;
			if (this.isFlickering())
				return;
			animation.play("idle");
		}
		super.update(elapsed);
	}

	public function onBeingInjured(point:FlxPoint, damage:Int = 1)
	{
		this.flicker();
		health -= damage;
	}

	public function onEnemyContact(point:FlxPoint)
	{
		// Placeholder for custom logic when contacting an enemy (damage agnostic)
		return;
	}

	public function onSeeingEnemyEntity(point:FlxPoint)
	{
		state = SWARMING;
		playerPosition = point;
	}

	public function onSeingAllyKilled(point:FlxPoint)
	{
		// No-op for most enemies
		return;
	}

	function setPropertiesForName(name:String)
	{
		var graphic = AssetPaths.not_available__png;
		this.name = name;
		switch (name)
		{
			case "miasma":
				graphic = AssetPaths.Miasma__png;
			case "fire_ant":
				graphic = AssetPaths.FireAnt__png;
			case "crab":
				graphic = AssetPaths.Crab__png;
			case "sand_creep":
				graphic = AssetPaths.SandCreep__png;
		}
		loadGraphic(graphic, true, 10, 10);
	}

	public function getTouchDamage()
	{
		return TOUCH_DAMAGE;
	}

	public function getExperience()
	{
		return EXPERIENCE;
	}
}
