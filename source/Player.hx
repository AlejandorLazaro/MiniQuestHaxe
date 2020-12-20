package;

import Item.ItemType;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

enum WeaponType
{
	NONE;
	SWORD;
	BOW;
}

class Player extends FlxSprite
{
	var player:Player;
	var weapon:WeaponType;
	var unlockedItems:Map<ItemType, Bool>; // We need something to represent unlocking items via pickups

	// var stepSound:FlxSound;
	static inline var SPEED:Float = 200;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.weapon = WeaponType.NONE;
		this.unlockedItems = [];
		loadGraphic(AssetPaths.Sprites__png, true, 10, 10);
		// setFacingFlip(FlxObject.LEFT, false, false);
		// setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("idle", [0, 2, 0, 1], 6, false);
		// animation.add("lr", [3, 4, 3, 5], 6, false);
		// animation.add("u", [6, 7, 6, 8], 6, false);
		// animation.add("d", [0, 1, 0, 2], 6, false);
		drag.x = drag.y = 1600;
		setSize(6, 7);
		offset.set(2, 3);
		// stepSound = FlxG.sound.load(AssetPaths.step__wav);
	}

	override function update(elapsed:Float)
	{
		updateMovement();
		super.update(elapsed);
	}

	function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		#if FLX_KEYBOARD
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		#end
		#if mobile
		var virtualPad = PlayState.virtualPad;
		up = up || virtualPad.buttonUp.pressed;
		down = down || virtualPad.buttonDown.pressed;
		left = left || virtualPad.buttonLeft.pressed;
		right = right || virtualPad.buttonRight.pressed;
		#end

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up || down || left || right)
		{
			var newAngle:Float = 0;
			if (up)
			{
				newAngle = -90;
				if (left)
					newAngle -= 45;
				else if (right)
					newAngle += 45;
				facing = FlxObject.UP;
			}
			else if (down)
			{
				newAngle = 90;
				if (left)
					newAngle += 45;
				else if (right)
					newAngle -= 45;
				facing = FlxObject.DOWN;
			}
			else if (left)
			{
				newAngle = 180;
				facing = FlxObject.LEFT;
			}
			else if (right)
			{
				newAngle = 0;
				facing = FlxObject.RIGHT;
			}

			// Determine the player's velocity based on angle and speed (deals with hypotenuse travel correctly)
			velocity.set(SPEED, 0);
			velocity.rotate(FlxPoint.weak(0, 0), newAngle);

			// // if the player is moving (velocity is not 0 for either axis), we need to change the animation to match their facing
			// if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			// {
			// 	switch (facing)
			// 	{
			// 		case FlxObject.LEFT, FlxObject.RIGHT:
			// 			animation.play("lr");
			// 		case FlxObject.UP:
			// 			animation.play("u");
			// 		case FlxObject.DOWN:
			// 			animation.play("d");
			// 	}
			// 	stepSound.play();
			// }
		}
		else
		{
			animation.play("idle");
		}
	}

	// We'll need to add logic to handle switching weapons after unlocking them
	public function changeWeapon(weapon:WeaponType)
	{
		if (this.weapon != weapon)
		{
			switch (weapon)
			{
				case NONE:
					this.weapon = NONE;
				case SWORD:
					this.weapon = SWORD;
				case BOW:
					this.weapon = BOW;
			}
		}
	}

	public function unlockItem(item:Item.ItemType)
	{
		this.unlockedItems[item] = true;
	}
}
