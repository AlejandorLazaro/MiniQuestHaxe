package;

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
	var healthCounter:FlxText;
	var playerHealthBar:FlxBar;
	var enemyHealthBar:FlxBar;

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

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	public function updatePlayerHealth(health:Int, maxHealth:Int)
	{
		healthCounter.text = health + " / " + maxHealth;
		playerHealthBar.value = (health / maxHealth) * 100; // change the player's health bar
	}

	// This is temporary until we find a way to have multiple health bars present at the same time
	public function updateEnemyHealthBar(enemy:Enemy, health:Int, maxHealth:Int)
	{
		FlxG.log.add("Enemy health = " + health + "/" + maxHealth);
		enemyHealthBar.value = (health / maxHealth) * 100; // change the enemy's health bar
		FlxG.log.add("Enemy health bar value = " + enemyHealthBar.value);
		FlxG.log.add("Enemy health bar = " + enemyHealthBar);
	}

	public function addNewEnemyHealthBar(enemy:Enemy)
	{
		enemyHealthBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 12, 3);
		// I didn't want to use 'setParent' because it forces the use of a variable to be tracked,
		// but I only wanted the bar to follow an FlxSprite instead, while being in full control
		// of the actual bar values separately. (e.g.: freely increasing the max HP value)
		// enemyHealthBar.setParent(enemy, "", true, 0, 0);
		enemyHealthBar.parent = enemy;
		enemyHealthBar.trackParent(0, 0);
		enemyHealthBar.value = 100; // the enemySprite's health bar starts at 100%
		enemyHealthBar.killOnEmpty = true;
		enemyHealthBar.createFilledBar(FlxColor.BLACK, FlxColor.RED, true, FlxColor.WHITE);
		add(enemyHealthBar);
		FlxG.log.add("Initial enemy health bar = " + enemyHealthBar);
		FlxG.log.add("X: " + enemyHealthBar.x + "; Y: " + enemyHealthBar.y);
		FlxG.log.add("Enemy health bar value = " + enemyHealthBar.value);
	}
}
