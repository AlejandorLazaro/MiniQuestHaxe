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

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();

		titleText = new FlxText(20, 0, 0, "MiniQuest", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(X);
		add(titleText);

		testButton = new FlxButton(0, 0, "Test", clickTest);
		testButton.x = (FlxG.width / 2) - (testButton.width / 2);
		testButton.y = FlxG.height - testButton.height - 10;
		add(testButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function clickTest()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new SingleEnemyState());
		});
	}
}
