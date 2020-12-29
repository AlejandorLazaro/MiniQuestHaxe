package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class GameOverState extends FlxState
{
	var win:Bool; // if we won or lost
	var titleText:FlxText; // the title text
	var mainMenuButton:FlxButton; // button to go to main menu

	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	win		true if the player beat the boss, false if they died
	 */
	public function new(win:Bool)
	{
		super();
		this.win = win;
	}

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end

		// create and add each of our items

		titleText = new FlxText(0, 20, 0, if (win) "You Win!" else "Game Over!", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		mainMenuButton = new FlxButton(0, FlxG.height - 32, "Main Menu", switchToMainMenu);
		mainMenuButton.screenCenter(FlxAxes.X);
		add(mainMenuButton);

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	/**
	 * When the user hits the main menu button, it should fade out and then take them back to the MenuState
	 */
	function switchToMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}
