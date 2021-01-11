package;

import flixel.FlxSprite;
import flixel.math.FlxAngle;

class Arrow extends FlxSprite
{
	private var speed:Float;
	private var direction:FlxAngle;
	private var damage:Float;

	// public var timer:FlxTimer;
	// public function new(x:Float, y:Float, speed:Float = 500, direction:FlxAngle = FlxAngle(), damage:Float = 1)
	public function new(x:Float, y:Float)
	{
		super(x, y);
		// timer = new FlxTimer();
	}
}
