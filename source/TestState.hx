package;

import enemy_library.Crab;
import enemy_library.FireAnt;
import enemy_library.Miasma;
import enemy_library.SandCreep;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.tile.FlxBaseTilemap;
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
		map = new FlxOgmo3Loader(AssetPaths.miniQuest__ogmo, AssetPaths.test__json);
		overworld = map.loadTilemap(AssetPaths.TileTextures2__png, "overworld");
		overworld.follow();
		overworld.setTileProperties(1, FlxObject.NONE); // Grass
		overworld.setTileProperties(2, FlxObject.ANY, onContactWithIceBlock); // Ice Block
		overworld.setTileProperties(3, FlxObject.ANY, onContactWithRock); // Boulder
		overworld.setTileProperties(4, FlxObject.NONE); // Beach Sand
		overworld.setTileProperties(5, FlxObject.NONE); // Craggy Ground
		overworld.setTileProperties(6, FlxObject.NONE); // Desert Sand
		overworld.setTileProperties(7, FlxObject.NONE); // Dirt
		overworld.setTileProperties(8, FlxObject.ANY, onContactWithWater); // Water
		overworld.setTileProperties(9, FlxObject.ANY, onContactWithRock); // Brown Boulder
		overworld.setTileProperties(10, FlxObject.NONE); // Upheaved Desert Sand
		overworld.setTileProperties(11, FlxObject.NONE); // Flowers
		overworld.setTileProperties(12, FlxObject.NONE); // Metal Floor
		overworld.setTileProperties(13, FlxObject.NONE); // Bleached Road
		overworld.setTileProperties(14, FlxObject.NONE); // Wooden Board
		overworld.setTileProperties(15, FlxObject.ANY, onContactWithShell); // Shell
		overworld.setTileProperties(16, FlxObject.ANY, onContactWithTree); // Tree
		overworld.setTileProperties(17, FlxObject.ANY, onContactWithSky); // Sky
		overworld.setTileProperties(18, FlxObject.ANY, onContactWithSky); // Cloud
		overworld.setTileProperties(19, FlxObject.NONE); // Dark Grass
		overworld.setTileProperties(20, FlxObject.ANY, onContactWithTree); // Dark Tree
		overworld.setTileProperties(21, FlxObject.NONE); // Golden Road
		overworld.setTileProperties(22, FlxObject.ANY, onContactWithTree); // Fruit Tree
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

		hud = new HUD();
		add(hud);

		FlxG.camera.follow(player, TOPDOWN, 1);
		// Edit the deadzone, since the hud isn't considered by default on the presets
		// Based on FlxCamera's `TOPDOWN` preset
		var helper = Math.max(FlxG.width, FlxG.height - hud.getBackgroundHeight()) / 4;
		FlxG.camera.deadzone = FlxRect.get((FlxG.width - helper) / 2, (FlxG.height - helper + hud.getBackgroundHeight()) / 2, helper, helper);

		enemies.forEach(hud.addNewEnemyHealthBar);

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		endButton = new FlxButton(0, 0, "End Test", doneFadeOut);
		endButton.x = (FlxG.width - 20) - endButton.width - 10;
		endButton.y = FlxG.height - endButton.height - 10;
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
				enemy.onBeingInjured(player.getMidpoint(), player.getDamageDone());
				hud.updateEnemyHealthBar(enemy, Std.int(enemy.health), enemy.enemyMaxHealth);
				if (enemy.health <= 0)
				{
					// This is special behavior that allows Miasma enemies to
					// swarm if they see the player kill another Miasma entity
					if (Type.getClass(enemy) == Miasma)
					{
						enemies.forEachOfType(Miasma, checkSeenEnemyKilled);
					}
					player.increaseExperience(enemy.getExperience());
					hud.updatePlayerExperience(player.getCurrExp(), player.getCurrMaxExp());
					hud.updatePlayerLevel(player.level, player.maxLevel);
					hud.updatePlayerHealth(Std.int(player.health), Std.int(player.maxHealth));
					enemy.kill();
				}
			}
			else
			{
				player.onEnemyContact(enemy.getMidpoint(), enemy.getTouchDamage());
				hud.updatePlayerHealth(Std.int(player.health), Std.int(player.maxHealth));
			}
		}
		FlxG.collide(player, enemy);
		enemy.onEnemyContact(player.getMidpoint());
	}

	function arrowTouchEnemy(arrow:Arrow, enemy:Enemy)
	{
		if (arrow.alive && arrow.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			enemy.onBeingInjured(player.getMidpoint(), arrow.damage);
			hud.updateEnemyHealthBar(enemy, Std.int(enemy.health), enemy.enemyMaxHealth);
			if (enemy.health <= 0)
			{
				// This is special behavior that allows Miasma enemies to
				// swarm if they see the player kill another Miasma entity
				if (Type.getClass(enemy) == Miasma)
				{
					enemies.forEachOfType(Miasma, checkSeenEnemyKilled);
				}
				player.increaseExperience(enemy.getExperience());
				hud.updatePlayerExperience(player.getCurrExp(), player.getCurrMaxExp());
				hud.updatePlayerLevel(player.level, player.maxLevel);
				hud.updatePlayerHealth(Std.int(player.health), Std.int(player.maxHealth));
				enemy.kill();
			}
		}
		arrow.kill();
	}

	// Functions determining enemy characteristics (such as seeing the player)

	function shouldBeActive(enemy:Enemy)
	{
		enemy.isActive = enemy.getMidpoint().distanceTo(player.getMidpoint()) <= enemy.ACTIVE_RANGE;
	}

	function checkEnemyVision(enemy:Enemy)
	{
		// # Old version using the default `ray` function from FlxTilemap.hx
		// # Replacing this with a custom version that treats the `allowCollisions`
		// # of sky blocks as false so that enemies can still see and charge towards
		// # the player is a TODO
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

	///////////////////////////////////////////////////////////////////////////
	//
	// Functions specifically for arrow overlap callbacks
	//
	///////////////////////////////////////////////////////////////////////////

	function arrowOverlapWithTileProcessCallback(Arrow:Arrow, TileMap:FlxBaseTilemap<Dynamic>):Bool
	{
		return TileMap.overlapsWithCallback(Arrow, null);
	}

	///////////////////////////////////////////////////////////////////////////
	//
	// Functions for tile collision callbacks
	//
	///////////////////////////////////////////////////////////////////////////

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
				object.velocity.scale(0.25); // Slow the arrow down but let it slide
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

	///////////////////////////////////////////////////////////////////////////
	//
	// State end function
	//
	///////////////////////////////////////////////////////////////////////////

	function doneFadeOut()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new GameOverState(false));
		});
	}
}
