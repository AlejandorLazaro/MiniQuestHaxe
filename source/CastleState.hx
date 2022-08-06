package;

import enemy_library.FireAnt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class CastleState extends FlxState
{
	var player:Player;
	var portals:FlxTypedGroup<Portal>;
	var enemies:FlxTypedGroup<Enemy>;
	var npcs:FlxTypedGroup<NPC>;
	var map:FlxOgmo3Loader;
	var hud:HUD;
	var items:FlxTypedGroup<Item>;
	var overworld:FlxTilemap;
	var ending:Bool;
	var endButton:FlxButton;

	override public function create()
	{
		map = new FlxOgmo3Loader(AssetPaths.miniQuest__ogmo, AssetPaths.castle__json);
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

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		npcs = new FlxTypedGroup<NPC>();
		add(npcs);

		portals = new FlxTypedGroup<Portal>();
		add(portals);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

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
			FlxG.collide(player, portals, transitionToCastleExterior);
			FlxG.collide(enemies, overworld);
			FlxG.collide(npcs, overworld);
			FlxG.collide(player, npcs);
			FlxG.collide(npcs, npcs);
			FlxG.collide(enemies, enemies);
			enemies.forEachAlive(shouldBeActive);
			enemies.forEachAlive(checkEnemyVision);
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
			case "king":
				npcs.add(new NPC(x, y, entity.name));
			case "princess":
				npcs.add(new NPC(x, y, entity.name));
			case "fire_ant":
				enemies.add(new FireAnt(x, y));
			case "portal":
				portals.add(new Portal(x, y));
			default: // Assume everything else is an enemy
				enemies.add(new Enemy(x, y, entity.name));
		}
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

	function transitionToCastleExterior(player:Player, portal:Portal)
	{
		if (player.alive && player.exists && portal.alive && portal.exists)
		{
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
			{
				// TODO: Determine how to switch states while also providing data to change how
				// the next state will render.
				// I.e.: Think of Mario and Luigi Superstar Saga, where you can enter and exit
				// the same maps from and to multiple locations.
				FlxG.switchState(new TestState());
			});
			player.health = 0; // Placeholder logic that kills the player until we have something meaningful happening with the castle, like loading a new level/area
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
