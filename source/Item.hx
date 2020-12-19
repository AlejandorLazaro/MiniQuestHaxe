package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum ItemType
{
	SWORD;
	BOW;
}

class Item extends FlxSprite
{
	public var type:ItemType;

	public function new(x:Float, y:Float, itemType:ItemType)
	{
		super(x, y);
		this.type = itemType;
		loadGraphic(getAssetPathForType(itemType), false, 10, 10);
	}

	static public function getAssetPathForType(itemType:ItemType)
	{
		var assetPath = AssetPaths.not_available__png;
		switch (itemType)
		{
			case SWORD:
				assetPath = AssetPaths.sword__png;

			case BOW:
				assetPath = AssetPaths.bow__png;
		}
		return assetPath;
	}

	override function kill()
	{
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_)
	{
		exists = false;
	}
}
