package;

import flixel.FlxSprite;

class Portal extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		// TODO: Figure out how to prevent the default Flixel graphic
		// (which is way bigger than 10x10) from being used here.
		setSize(10, 10);
	}
}
