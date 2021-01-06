package;

import enemy_library.Crab;
import enemy_library.Miasma;
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
	var castle:Castle;
	var enemies:FlxTypedGroup<Enemy>;
	var map:FlxOgmo3Loader;
	var hud:HUD;
	var items:FlxTypedGroup<Item>;
	var overworld:FlxTilemap;
	var ending:Bool;
	// var won:Bool; // This will always be false for our Test state
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

		castle = new Castle();
		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(castle);
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
		if (ending)
		{
			return;
		}
		else
		{
			FlxG.overlap(player, items, playerTouchItem);
			FlxG.overlap(player, castle, playerTouchCastle);
			FlxG.collide(player, overworld);
			FlxG.collide(enemies, overworld);
			FlxG.collide(enemies, enemies);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
			if (player.health == 0)
			{
				player.kill();
				ending = true;
				doneFadeOut();
			}
		}
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
				castle.setPosition(x, y);
			case "miasma":
				enemies.add(new Miasma(x, y));
			case "crab":
				enemies.add(new Crab(x, y));
			default: // Assume everything else is an enemy
				enemies.add(new Enemy(x, y, entity.name));
		}
	}

	// Functions determining collision effects

	function playerTouchItem(player:Player, item:Item)
	{
		if (player.alive && player.exists && item.alive && item.exists)
		{
			player.unlockItem(item.type);
			hud.unlockItem(item.type);
			item.kill();
		}
	}

	function playerTouchCastle(player:Player, castle:Castle)
	{
		if (player.alive && player.exists && castle.alive && castle.exists)
		{
			player.health = 0; // Placeholder logic that kills the player until we have something meaningful happening with the castle, like loading a new level/area
		}
	}

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !player.isFlickering() && !enemy.isFlickering())
		{
			// Add logic to deal with whether the player or the enemy takes damage
			// For now, the enemy will always just die. Lol.
			//
			// Eventually make this return a numeric value to change the damage enemies take,
			// since it'd be nice to have different damage values (upgrades, etc)
			if (player.activeDamageAura())
			{
				enemy.health--;
				if (enemy.health == 0)
				{
					// This is special behavior that allows Miasma enemies to
					// swarm if they see the player kill another Miasma entity
					if (Type.getClass(enemy) == Miasma)
					{
						enemies.forEachOfType(Miasma, checkSeenEnemyKilled);
					}
					enemy.kill();
				}
				enemy.flicker();
			}
			else
			{
				player.health--;
				hud.updateHealth(Std.int(player.health));
				player.flicker();
			}
		}
		FlxG.collide(player, enemy);
	}

	// Functions determining enemy characteristics (such as seeing the player)

	function checkEnemyVision(enemy:Enemy)
	{
		if (overworld.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.onSeeingEnemyEntity(player.getMidpoint());
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	function checkSeenEnemyKilled(enemy:Enemy)
	{
		if (enemy.seesPlayer == true)
		{
			enemy.onSeingAllyKilled(player.getMidpoint());
		}
	}

	function doneFadeOut()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new GameOverState(false));
		});
	}
}
