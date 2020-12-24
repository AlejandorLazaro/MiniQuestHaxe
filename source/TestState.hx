package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class TestState extends FlxState
{
	var player:Player;
	var enemies:FlxTypedGroup<Enemy>;
	var map:FlxOgmo3Loader;
	var hud:HUD;
	var items:FlxTypedGroup<Item>;
	var overworld:FlxTilemap;
	var endButton:FlxButton;

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.miniQuest__ogmo, AssetPaths.test__json);
		overworld = map.loadTilemap(AssetPaths.TileTextures2__png, "overworld");
		overworld.follow();
		overworld.setTileProperties(1, FlxObject.NONE); // Grass
		overworld.setTileProperties(2, FlxObject.ANY); // Ice Block
		overworld.setTileProperties(3, FlxObject.ANY); // Boulder
		overworld.setTileProperties(4, FlxObject.NONE); // Beach Sand
		overworld.setTileProperties(5, FlxObject.NONE); // Craggy Ground
		overworld.setTileProperties(6, FlxObject.NONE); // Desert Sand
		overworld.setTileProperties(7, FlxObject.NONE); // Dirt
		overworld.setTileProperties(8, FlxObject.ANY); // Water
		overworld.setTileProperties(9, FlxObject.ANY); // Brown Boulder
		overworld.setTileProperties(10, FlxObject.NONE); // Upheaved Desert Sand
		overworld.setTileProperties(11, FlxObject.NONE); // Flowers
		overworld.setTileProperties(12, FlxObject.NONE); // Metal Floor
		overworld.setTileProperties(13, FlxObject.NONE); // Bleached Road
		overworld.setTileProperties(14, FlxObject.NONE); // Wooden Board
		overworld.setTileProperties(15, FlxObject.ANY); // Shell
		overworld.setTileProperties(16, FlxObject.ANY); // Tree
		overworld.setTileProperties(17, FlxObject.ANY); // Sky
		overworld.setTileProperties(18, FlxObject.ANY); // Cloud
		overworld.setTileProperties(19, FlxObject.NONE); // Dark Grass
		overworld.setTileProperties(20, FlxObject.ANY); // Dark Tree
		overworld.setTileProperties(21, FlxObject.NONE); // Golden Road
		overworld.setTileProperties(22, FlxObject.ANY); // Fruit Tree
		add(overworld);

		// coins = new FlxTypedGroup<Coin>();
		// coinSound = FlxG.sound.load(AssetPaths.coin__wav);
		// add(coins);

		items = new FlxTypedGroup<Item>();
		add(items);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		// combatHud = new CombatHUD();
		// add(combatHud);

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		endButton = new FlxButton(0, 0, "End Test", doneFadeOut);
		endButton.x = (FlxG.width - 20) - endButton.width - 10;
		endButton.y = FlxG.height - endButton.height - 10;
		// endButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(endButton);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.overlap(player, items, playerTouchItem);
		FlxG.collide(player, overworld);
		FlxG.collide(enemies, overworld);
		// enemies.forEachAlive(checkEnemyVision);
		FlxG.overlap(player, enemies, playerTouchEnemy);
	}

	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);
			case "sword":
				items.add(new Item(x, y, SWORD));
			case "bow":
				items.add(new Item(x, y, BOW));
			case "castle":
				true; // Deal with the castle
			default: // Assume everything else is an enemy
				enemies.add(new Enemy(x, y, entity.name));
		}
	}

	function playerTouchItem(player:Player, item:Item)
	{
		if (player.alive && player.exists && item.alive && item.exists)
		{
			player.unlockItem(item.type);
			hud.unlockItem(item.type);
			item.kill();
		}
	}

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			// Add logic to deal with whether the player or the enemy takes damage
			// For now, the enemy will always just die. Lol.
			enemy.kill();
		}
	}

	function doneFadeOut()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}
