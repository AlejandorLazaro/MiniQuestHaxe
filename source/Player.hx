package;

import Item.ItemType;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

using StringTools;

enum WeaponType
{
	NONE;
	SWORD;
	BOW;
}

enum PlayerState
{
	IDLE;
	ATTACKING;
	ATTACK_COOLDOWN;
	DAMAGED;
}

class Player extends FlxSprite
{
	var player:Player;
	var equippedWeapon:WeaponType;
	var unlockedItems:Map<ItemType, Bool>; // We need something to represent unlocking items via pickups

	public var maxHealth:Int;

	var state:PlayerState;
	var attackTimer:Float;
	var attackDelayTimer:Float;

	// var stepSound:FlxSound;
	static inline var SPEED:Float = 100;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.maxHealth = 3; // Initial max health is 3
		this.health = maxHealth;
		this.equippedWeapon = WeaponType.NONE;
		this.unlockedItems = [];
		loadGraphic(AssetPaths.Sprites2__png, true, 10, 10);
		animation.add("idle", [0, 2, 0, 3, 1], 6, false);
		animation.add("sword_idle", [5, 6, 7, 8], 6, false);
		animation.add("bow_idle", [10, 11, 12, 13], 6, false);
		animation.add("basic_attack", [4, 4, 4], 6, false);
		animation.add("sword_attack", [9, 5, 5], 6, false);
		animation.add("bow_attack", [14, 14, 13], 6, false);

		drag.x = drag.y = 1600;
		setSize(6, 7);
		offset.set(2, 3);
		state = IDLE;
		// stepSound = FlxG.sound.load(AssetPaths.step__wav);
	}

	override function update(elapsed:Float)
	{
		updateState(elapsed);
		updateMovement();
		updatePlayerAnimation();
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
		}
	}

	function updatePlayerAnimation()
	{
		var equip_1:Bool = false;
		var equip_2:Bool = false;

		#if FLX_KEYBOARD
		equip_1 = FlxG.keys.anyPressed([ONE]); // Sword Button
		equip_2 = FlxG.keys.anyPressed([TWO]); // Bow Button
		#end

		if (state != IDLE || (equip_1 && equip_2))
			equip_1 = equip_2 = false;

		// 1. Animating an attack is the highest priority
		if (state == ATTACKING)
		{
			switch (equippedWeapon)
			{
				case NONE:
					animation.play("basic_attack");
				case SWORD:
					animation.play("sword_attack");
				case BOW:
					animation.play("bow_attack");
			}
		}
		// 2. Animating weapon switches is 2nd priority
		else if (equip_1 && unlockedItems.get(SWORD))
		{
			changeWeapon(SWORD);
			animation.play("sword_idle");
		}
		else if (equip_2 && unlockedItems.get(BOW))
		{
			changeWeapon(BOW);
			animation.play("bow_idle");
		}
			// 3. Animating movement is 3rd priority
			// // if the player is moving (velocity is not 0 for either axis), we need to change the animation to match their facing
			// else if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			// {
			// 	// switch (facing)
			// 	// {
			// 	// 	case FlxObject.LEFT, FlxObject.RIGHT:
			// 	// 		animation.play("lr");
			// 	// 	case FlxObject.UP:
			// 	// 		animation.play("u");
			// 	// 	case FlxObject.DOWN:
			// 	// 		animation.play("d");
			// 	// }
			// 	// // stepSound.play();
			// }
		// 4. Animating the idle player is the last priority
		else if (animation.finished)
		{
			switch (equippedWeapon)
			{
				case NONE:
					animation.play("idle");
				case SWORD:
					animation.play("sword_idle");
				case BOW:
					animation.play("bow_idle");
			}
		}
	}

	function updateState(elapsed:Float)
	{
		var use:Bool = false;

		#if FLX_KEYBOARD
		use = FlxG.keys.anyPressed([SPACE]);
		#end

		if (use && state == IDLE)
		{
			// Add a switch statement here to make attack timer change behavior based on equipped weapon
			state = ATTACKING;
			switch (equippedWeapon)
			{
				case NONE:
					attackTimer = 0.3;
				case SWORD:
					attackTimer = 0.2;
				case BOW:
					attackTimer = 0.1;
			}
		}
		else if (state == ATTACKING)
		{
			attackTimer -= elapsed;
			if (attackTimer < 0)
			{
				// Same here for the cooldown
				state = ATTACK_COOLDOWN;
				switch (equippedWeapon)
				{
					case NONE:
						attackDelayTimer = 0.5;
					case SWORD:
						attackDelayTimer = 0.3;
					case BOW:
						attackDelayTimer = 0.8;
				}
			}
		}
		else if (state == ATTACK_COOLDOWN)
		{
			attackDelayTimer -= elapsed;
			if (attackDelayTimer < 0)
			{
				state = IDLE;
			}
		}
	}

	// We'll need to add logic to handle switching weapons after unlocking them
	public function changeWeapon(weapon:WeaponType)
	{
		if (this.equippedWeapon != weapon)
		{
			switch (weapon)
			{
				case NONE:
					this.equippedWeapon = NONE;
				case SWORD:
					this.equippedWeapon = SWORD;
				case BOW:
					this.equippedWeapon = BOW;
			}
		}
	}

	public function unlockItem(item:Item.ItemType)
	{
		unlockedItems[item] = true;
	}

	public function activeDamageAura():Bool
	{
		return attackTimer > 0;
	}
}
