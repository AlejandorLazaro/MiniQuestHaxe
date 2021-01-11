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
	var enemyHealthBar:FlxBar;

	// var enemyHealthBars:Map<Enemy, FlxBar>;

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
		// create and add a FlxBar to show the enemySprite's health. We'll make it Red and Yellow.
		// enemyHealthBar = new FlxBar(enemySprite.x - 6, playerHealthCounter.y, LEFT_TO_RIGHT, 20, 10);
		playerHealthBar.value = 100; // the enemySprite's health bar starts at 100%
		playerHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.LIME, true, FlxColor.WHITE);
		add(playerHealthBar);

		enemyHealthBar = new FlxBar(this.background.frameWidth - 44, 0, LEFT_TO_RIGHT, 30, 4);
		// create and add a FlxBar to show the enemySprite's health. We'll make it Red and Yellow.
		// enemyHealthBar = new FlxBar(enemySprite.x - 6, playerHealthCounter.y, LEFT_TO_RIGHT, 20, 10);
		enemyHealthBar.value = 100; // the enemySprite's health bar starts at 100%
		enemyHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
		add(enemyHealthBar);

		// enemyHealthBars = new Map<Enemy, FlxBar>();

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

	// This is temporary until we find a way to have multiple health bars present at the same time
	public function updateEnemyHealth(enemy:Enemy, health:Int, maxHealth:Int)
	{
		FlxG.log.add("Enemy health = " + health + "/" + maxHealth);
		// If a health bar for this enemy doesn't exist in this collection yet, create it

		enemyHealthBar.value = (health / maxHealth) * 100; // change the enemy's health bar
	}

	// public function updateEnemyHealth(enemy:Enemy, health:Int, maxHealth:Int)
	// {
	// 	FlxG.log.add("Enemy health bars: " + enemyHealthBars);
	// 	FlxG.log.add("Enemy health = " + health + "/" + maxHealth);
	// 	// If a health bar for this enemy doesn't exist in this collection yet, create it
	// 	if (!enemyHealthBars.exists(enemy))
	// 	{
	// 		enemyHealthBars[enemy] = new FlxBar(50, 0, LEFT_TO_RIGHT, 30, 4);
	// 		// create and add a FlxBar to show the enemySprite's health. We'll make it Red and Yellow.
	// 		// enemyHealthBar = new FlxBar(enemySprite.x - 6, playerHealthCounter.y, LEFT_TO_RIGHT, 20, 10);
	// 		enemyHealthBars[enemy].value = 100; // the enemySprite's health bar starts at 100%
	// 		enemyHealthBars[enemy].createFilledBar(0xffdc143c, FlxColor.RED, true, FlxColor.WHITE);
	// 		// enemyHealthBars[enemy].killOnEmpty = true;
	// 		add(enemyHealthBars[enemy]);
	// 	}
	// 	enemyHealthBars[enemy].value = (health / maxHealth) * 100; // change the enemy's health bar
	// 	FlxG.log.add("Enemy health bars after injury: " + enemyHealthBars[enemy]);
	// }

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
