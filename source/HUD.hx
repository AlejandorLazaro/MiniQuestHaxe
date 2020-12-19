package;

import Item;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

// import Item.ItemType;
class HUD extends FlxTypedGroup<FlxSprite>
{
	var background:FlxSprite;
	var unlockedItems:Map<ItemType, FlxSprite>; // We need something to represent unlocking items via pickups
	var itemStatus:FlxText;

	public function new()
	{
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		// healthCounter = new FlxText(16, 2, 0, "3 / 3", 8);
		// healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		// moneyCounter = new FlxText(0, 2, 0, "0", 8);
		// moneyCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		// healthIcon = new FlxSprite(4, healthCounter.y + (healthCounter.height / 2) - 4, AssetPaths.health__png);
		// moneyIcon = new FlxSprite(FlxG.width - 12, moneyCounter.y + (moneyCounter.height / 2) - 4, AssetPaths.coin__png);
		// moneyCounter.alignment = RIGHT;
		// moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		add(background);

		itemStatus = new FlxText(0, 2, 0, "Items Not Picked Up", 8);
		add(itemStatus);

		// var item_image_buffer = 0;
		// for (item in Type.allEnums(Item.ItemType))
		// {
		// 	item_image_buffer += 10;
		// 	unlockedItems[item] = new FlxSprite(item_image_buffer, 10, Item.getAssetPathForType(item));
		// 	add(unlockedItems[item]);
		// }

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	// public function updateHealth(health:Int)
	// {
	// 	healthCounter.text = health + " / 3";
	// }

	public function unlockItem(item:Item.ItemType)
	{
		// unlockedItems[item] = true;
		switch (item)
		{
			case SWORD:
				itemStatus.text = "Sword Picked Up";
			case BOW:
				itemStatus.text = "Bow Picked Up";
		}
		// Add logic to add/modify unlocked item to the HUD
	}
}
