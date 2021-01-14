package;

import TileHelper;
import enemy_library.Crab;
import enemy_library.FireAnt;
import enemy_library.Miasma;
import enemy_library.SandCreep;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class TestState extends FlxState
{
	public static var arrows:FlxTypedGroup<Arrow>;

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
		map = TileHelper.loadOgmo3MapFromOgmoFile(AssetPaths.miniQuest__ogmo, AssetPaths.test__json);
		overworld = TileHelper.loadTileMapFromOgmoMap(map, AssetPaths.TileTextures2__png, "overworld");
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
		for (effect in player.enumerateDrawEffects())
			add(effect);

		var poolSize:Int = 10;
		var arrow:Arrow;
		arrows = new FlxTypedGroup<Arrow>(poolSize);
		for (i in 0...poolSize)
		{
			arrow = new Arrow();
			arrows.add(arrow);
		}
		add(arrows);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		enemies.forEach(hud.addNewEnemyHealthBar);

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
			FlxG.overlap(arrows, overworld, null, arrowOverlapWithTileProcessCallback);
			FlxG.overlap(arrows, enemies, arrowTouchEnemy);
			enemies.forEachAlive(shouldBeActive);
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
			case "sand_creep":
				enemies.add(new SandCreep(x, y));
			case "fire_ant":
				enemies.add(new FireAnt(x, y));
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
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
			{
				FlxG.switchState(new CastleState());
			});
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
				enemy.onBeingInjured(player.getMidpoint());
				hud.updateEnemyHealthBar(enemy, Std.int(enemy.health), enemy.enemyMaxHealth);
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
			}
			else
			{
				player.health--;
				hud.updatePlayerHealth(Std.int(player.health), Std.int(player.maxHealth));
				player.flicker();
			}
		}
		FlxG.collide(player, enemy);
		enemy.onEnemyContact(player.getMidpoint());
	}

	function arrowTouchEnemy(arrow:FlxSprite, enemy:Enemy)
	{
		if (arrow.alive && arrow.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			enemy.onBeingInjured(player.getMidpoint());
			hud.updateEnemyHealthBar(enemy, Std.int(enemy.health), enemy.enemyMaxHealth);
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
		}
		arrow.kill();
	}

	// Functions determining enemy characteristics (such as seeing the player)

	function shouldBeActive(enemy:Enemy)
	{
		enemy.isActive = !(enemy.getMidpoint().distanceTo(player.getMidpoint()) > enemy.ACTIVE_RANGE);
	}

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

	// Functions specifically for arrow overlap callbacks

	function arrowOverlapWithTileProcessCallback(Arrow:Arrow, TileMap:FlxBaseTilemap<Dynamic>):Bool
	{
		return TileMap.overlapsWithCallback(Arrow, null);
	}

	// Functions for tile collision callbacks

	function onContactWithTree(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	function onContactWithRock(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
				object.flicker(0.8, 0.1, function(Void) object.kill());
		}
	}

	function onContactWithIceBlock(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	function onContactWithShell(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	function onContactWithWater(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				return;
		}
	}

	function onContactWithSky(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				return;
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
