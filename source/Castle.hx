package;

import flixel.FlxSprite;

class Castle extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic(AssetPaths.Castle__png, false, 90, 60);
		setSize(90, 60);
	}
}
