package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var playButton:FlxButton;
	var testButton:FlxButton;
	var titleText:FlxText;
	var optionsButton:FlxButton;
	#if desktop
	var exitButton:FlxButton;
	#end

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();

		titleText = new FlxText(20, 0, 0, "MiniQuest", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(X);
		add(titleText);

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

		// optionsButton = new FlxButton(0, 0, "Options", clickOptions);
		// optionsButton.x = (FlxG.width / 2) + 10;
		// optionsButton.y = FlxG.height - optionsButton.height - 10;
		// // optionsButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		// add(optionsButton);

		#if desktop
		exitButton = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		exitButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		add(exitButton);
		#end

		#if desktop
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			// FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__ogg, 1, true);
		}
		#end
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

	// function clickOptions()
	// {
	// 	FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
	// 	{
	// 		FlxG.switchState(new OptionsState());
	// 	});
	// }
	#if desktop
	function clickExit()
	{
		Sys.exit(0);
	}
	#end
}
