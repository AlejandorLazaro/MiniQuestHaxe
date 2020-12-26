package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite
{
	static inline var SPEED:Float = 80;

	// These variables will be used to track the enemySprite's health
	var enemyMaxHealth:Int;

	var idleTimer:Float;
	var moveDirection:Float;
	var stepSound:FlxSound;

	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	public function new(x:Float, y:Float, name:String)
	{
		super(x, y);
		setPropertiesForName(name);
		animation.add("idle", [0, 1], 6, false);
		drag.x = drag.y = 10;
		width = 10;
		height = 10;

		idleTimer = 0;
		playerPosition = FlxPoint.get();
	}

	override public function update(elapsed:Float)
	{
		if (this.isFlickering())
			return;
		animation.play("idle");
		super.update(elapsed);
	}

	function setPropertiesForName(name:String)
	{
		var graphic = AssetPaths.not_available__png;
		switch (name)
		{
			case "miasma":
				graphic = AssetPaths.Miasma__png;
				enemyMaxHealth = 2;
			case "fire_ant":
				graphic = AssetPaths.FireAnt__png;
				enemyMaxHealth = 5;
			case "crab":
				graphic = AssetPaths.Crab__png;
				enemyMaxHealth = 2;
			case "sand_creep":
				graphic = AssetPaths.SandCreep__png;
				enemyMaxHealth = 3;
		}
		health = enemyMaxHealth;
		loadGraphic(graphic, true, 10, 10);
	}
}
