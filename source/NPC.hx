package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil;

enum NPCState
{
	IDLE;
	SWARMING;
	RUNNING;
}

class NPC extends FlxSprite
{
	static inline var SPEED:Float = 80;

	var name:String;

	// These variables will be used to track the enemySprite's health
	var enemyMaxHealth:Int;
	var idleTimer:Float;
	var moveDirection:Float;
	var startingOrigin:FlxPoint;

	public var state:NPCState;
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	public function new(x:Float, y:Float, name:String)
	{
		super(x, y);
		if (name != "preconfigured") // Only set values when another inherited class didn't already do it
		{
			setPropertiesForName(name);
			animation.add("idle", [0, 1], 2, false);
			drag.x = drag.y = 10;
			width = 10;
			height = 10;
			startingOrigin = new FlxPoint(x + origin.x, y + origin.y);
			idleTimer = 0;

			playerPosition = FlxPoint.get();
		}
	}

	override public function update(elapsed:Float)
	{
		if (name != "preconfigured") // Only set values when another inherited class didn't already do it
		{
			if (this.isFlickering())
				return;
			animation.play("idle");
			if (this.getMidpoint().distanceTo(startingOrigin) > 1)
			{
				FlxVelocity.moveTowardsPoint(this, startingOrigin, SPEED);
			}
			else
			{
				this.velocity.x = this.velocity.y = 0;
			}
		}
		super.update(elapsed);
	}

	function setPropertiesForName(name:String)
	{
		var graphic = AssetPaths.not_available__png;
		this.name = name;
		switch (name)
		{
			case "king":
				graphic = AssetPaths.King__png;
			case "princess":
				graphic = AssetPaths.Princess__png;
		}
		loadGraphic(graphic, true, 10, 10);
	}
}
