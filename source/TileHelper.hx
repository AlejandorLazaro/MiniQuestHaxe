package;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

class TileHelper
{
	/**
	 * Call this function to load an Ogmo3 map from a given Ogmo file
	 *
	 * @param	OgmoAssetsPath	Specify the *.ogmo file that contains the project data to load.
	 * @param	OgmoJSONPath	Path to the JSON file that contains the map level data to load.
	 * @return	Returns a FlxOgmo3Loader object that can then have a FlxTileMap created from it
	 */
	public static function loadOgmo3MapFromOgmoFile(OgmoAssetsPath:String, OgmoJSONPath:String):FlxOgmo3Loader
	{
		return new FlxOgmo3Loader(AssetPaths.miniQuest__ogmo, AssetPaths.test__json);
	}

	/**
	 * Call this to load a tilemap from an FlxOgmo3Loader object and set camera/tile properties
	 *
	 * @param	OgmoMap			Specify which game camera you want.  If null getScreenPosition() will just grab the first global camera.
	 * @param	TileTexturePath	Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
	 * @param	TileLayerName	Whether to update the collision system's world size, default value is true.
	 * @param	FollowCamera	Whether to update the collision system's world size, default value is true.
	 * @param	TileToCollisionCallbackMap	Whether to update the collision system's world size, default value is true.
	 * @return	A fully configured FlxTilemap object that has tiles configured with images and collision logic.
	 */
	public static function loadTileMapFromOgmoMap(OgmoMap:FlxOgmo3Loader, TileTexturePath:String, TileLayerName:String, ?FollowCamera:Bool,
			?TileToCollisionCallbackMap:Map<Int, FlxObject->Void>)
	{
		var overworld = OgmoMap.loadTilemap(AssetPaths.TileTextures2__png, "overworld");
		if (FollowCamera)
			overworld.follow();
		if (true)
		{
			setDefaultTileCollisionProperties(overworld);
		}
		else
			throw "Haven't created a non-default map setup yet!";
		return overworld;
	}

	private static function setDefaultTileCollisionProperties(TileMap:FlxTilemap)
	{
		TileMap.setTileProperties(1, FlxObject.NONE); // Grass
		TileMap.setTileProperties(2, FlxObject.ANY, onContactWithIceBlock); // Ice Block
		TileMap.setTileProperties(3, FlxObject.ANY, onContactWithRock); // Boulder
		TileMap.setTileProperties(4, FlxObject.NONE); // Beach Sand
		TileMap.setTileProperties(5, FlxObject.NONE); // Craggy Ground
		TileMap.setTileProperties(6, FlxObject.NONE); // Desert Sand
		TileMap.setTileProperties(7, FlxObject.NONE); // Dirt
		TileMap.setTileProperties(8, FlxObject.ANY, onContactWithWater); // Water
		TileMap.setTileProperties(9, FlxObject.ANY, onContactWithRock); // Brown Boulder
		TileMap.setTileProperties(10, FlxObject.NONE); // Upheaved Desert Sand
		TileMap.setTileProperties(11, FlxObject.NONE); // Flowers
		TileMap.setTileProperties(12, FlxObject.NONE); // Metal Floor
		TileMap.setTileProperties(13, FlxObject.NONE); // Bleached Road
		TileMap.setTileProperties(14, FlxObject.NONE); // Wooden Board
		TileMap.setTileProperties(15, FlxObject.ANY, onContactWithShell); // Shell
		TileMap.setTileProperties(16, FlxObject.ANY, onContactWithTree); // Tree
		TileMap.setTileProperties(17, FlxObject.ANY, onContactWithSky); // Sky
		TileMap.setTileProperties(18, FlxObject.ANY, onContactWithSky); // Cloud
		TileMap.setTileProperties(19, FlxObject.NONE); // Dark Grass
		TileMap.setTileProperties(20, FlxObject.ANY, onContactWithTree); // Dark Tree
		TileMap.setTileProperties(21, FlxObject.NONE); // Golden Road
		TileMap.setTileProperties(22, FlxObject.ANY, onContactWithTree); // Fruit Tree
	}

	// Default tile collision callbacks

	static function onContactWithTree(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	static function onContactWithRock(tile:FlxObject, object:Dynamic)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
				object.flicker(0.8, 0.1, function(Void) object.kill());
		}
	}

	static function onContactWithIceBlock(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	static function onContactWithShell(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				FlxObject.separate(tile, object);
				object.velocity.set(0, 0);
		}
	}

	static function onContactWithWater(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				return;
		}
	}

	static function onContactWithSky(tile:FlxObject, object:FlxObject)
	{
		switch (Type.getClass(object))
		{
			case Arrow:
				return;
		}
	}
}
