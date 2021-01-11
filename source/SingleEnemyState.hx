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
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class SingleEnemyState extends FlxState
{
	var player:Player;
	var enemies:FlxTypedGroup<Enemy>;
	var enemyHealthBars:FlxTypedGroup<FlxBar>;

	var map:FlxOgmo3Loader;
	var hud:HUD;
	var items:FlxTypedGroup<Item>;
	var overworld:FlxTilemap;
	var ending:Bool;
	var endButton:FlxButton;

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.miniQuest__ogmo, AssetPaths.single_enemy_test__json);
		overworld = map.loadTilemap(AssetPaths.TileTextures2__png, "overworld");
		overworld.follow();
		overworld.setTileProperties(1, FlxObject.NONE); // Grass
		overworld.setTileProperties(3, FlxObject.ANY); // Boulder
		overworld.setTileProperties(16, FlxObject.ANY); // Tree
		add(overworld);

		items = new FlxTypedGroup<Item>();
		add(items);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		hud = new HUD();
		add(hud);

		FlxG.camera.follow(player, TOPDOWN, 1);

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
			FlxG.collide(player, overworld);
			FlxG.collide(enemies, overworld);
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
			case "fire_ant":
				enemies.add(new FireAnt(x, y));
		}
	}

	// Functions determining collision effects

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
						enemies.forEachOfType(Miasma, checkSeenEnemyKilled);
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

	// State change functions (E.g.: Game over)

	function doneFadeOut()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new GameOverState(false));
		});
	}
}
