package;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.util.FlxTimer;

class Arrow extends FlxSprite
{
	private var speed:Float;
	private var direction:FlxAngle;
	private var damage:Float;

	public var timer:FlxTimer;

	// public function new(x:Float, y:Float, speed:Float = 500, direction:FlxAngle = FlxAngle(), damage:Float = 1)
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.makeGraphic(8, 2);
		width = 2;
		height = 2;
		offset.set(3, 0);
		exists = false;
		timer = new FlxTimer();
	}

	public function startArrow()
	{
		timer.start(2.0, function(Timer:FlxTimer) this.exists = false, 1);
	}
}
