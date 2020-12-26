package;

import Item;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var background:FlxSprite;
	var statusText:FlxText;
	var swordPickup:FlxSprite;
	var bowPickup:FlxSprite;
	var healthCounter:FlxText;

	public function new()
	{
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		add(background);

		healthCounter = new FlxText(16, 2, 0, "3 / 3", 8);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(healthCounter);

		// Adding row of item pickups (with greyed icons to show they aren't gathered initially)
		swordPickup = new FlxSprite(FlxG.width - 20 - 5, 2, AssetPaths.sword__png);
		swordPickup.color = FlxColor.GRAY;
		add(swordPickup);
		bowPickup = new FlxSprite(FlxG.width - 10 - 5, 2, AssetPaths.bow__png);
		bowPickup.color = FlxColor.GRAY;
		add(bowPickup);

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	public function updateHealth(health:Int)
	{
		healthCounter.text = health + " / 3";
	}

	public function unlockItem(item:Item.ItemType)
	{
		switch (item)
		{
			case SWORD:
				swordPickup.color = FlxColor.WHITE;
			case BOW:
				bowPickup.color = FlxColor.WHITE;
		}
	}
}
