package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var playButton:FlxButton;
	var testButton:FlxButton;
	var titleCard:FlxSprite;

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();

		titleCard = new FlxSprite(0, 0);
		titleCard.loadGraphic(AssetPaths.Title_mini__png);
		add(titleCard);

		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.x = (FlxG.width / 2) - playButton.width - 10;
		playButton.y = FlxG.height - playButton.height - 10;
		// playButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(playButton);

		testButton = new FlxButton(0, 0, "Test", clickTest);
		testButton.x = (FlxG.width - 20) - testButton.width - 10;
		testButton.y = FlxG.height - testButton.height - 10;
		// testButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(testButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function clickPlay()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState());
		});
	}

	function clickTest()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new TestState());
		});
	}
}
