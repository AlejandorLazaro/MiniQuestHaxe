package;

import Item;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var background:FlxSprite;
	var statusText:FlxText;
	var swordPickup:FlxSprite;
	var bowPickup:FlxSprite;
	var healthCounter:FlxText;
	var playerHealthBar:FlxBar;

	public var enemyHealthBars:Map<Enemy, FlxBar>;

	public function new()
	{
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		add(background);

		healthCounter = new FlxText(16, 2, 0, "3 / 3", 8);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(healthCounter);

		playerHealthBar = new FlxBar(14, 0, LEFT_TO_RIGHT, 30, 4);
		playerHealthBar.value = 100; // the enemySprite's health bar starts at 100%
		playerHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.LIME, true, FlxColor.WHITE);
		add(playerHealthBar);

		enemyHealthBars = new Map<Enemy, FlxBar>();

		// Adding row of item pickups (with greyed icons to show they aren't gathered initially)
		swordPickup = new FlxSprite(FlxG.width - 20 - 5, 2, AssetPaths.sword__png);
		swordPickup.color = FlxColor.GRAY;
		add(swordPickup);
		bowPickup = new FlxSprite(FlxG.width - 10 - 5, 2, AssetPaths.bow__png);
		bowPickup.color = FlxColor.GRAY;
		add(bowPickup);

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	public function updatePlayerHealth(health:Int, maxHealth:Int)
	{
		healthCounter.text = health + " / " + maxHealth;
		playerHealthBar.value = (health / maxHealth) * 100; // change the player's health bar
	}

	public function updateEnemyHealthBar(enemy:Enemy, health:Int, maxHealth:Int)
	{
		// If a health bar for this enemy doesn't exist in this collection yet, create it
		enemyHealthBars[enemy].visible = true;
		enemyHealthBars[enemy].value = (health / maxHealth) * 100; // change the enemy's health bar
	}

	public function addNewEnemyHealthBar(enemy:Enemy)
	{
		var enemyHealthBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 12, 1);
		enemyHealthBar.parent = enemy;
		enemyHealthBar.trackParent(Std.int(-enemy.width / 2), Std.int(-enemy.height));
		enemyHealthBar.value = 100; // the enemy's health bar starts at 100%
		enemyHealthBar.killOnEmpty = true;
		enemyHealthBar.visible = false;
		enemyHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, false);
		enemyHealthBars[enemy] = enemyHealthBar;
		add(enemyHealthBars[enemy]);
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
