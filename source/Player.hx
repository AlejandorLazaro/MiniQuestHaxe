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

	static var INITIAL_MAX_HEALTH:Int = 3;

	function REQ_EXP_FOR_LEVELUP(curr_level:Int)
	{
		return 2 * curr_level;
	}

	public var maxHealth:Int;
	public var maxLevel:Int;

	// TODO: Change level and health to private-like behaviors so we use callbacks to entities
	// to damage and update stats rather than doing it within "XState" code
	public var level:Int;

	private var experience:Int;
	private var base_damage:Int;

	var state:PlayerState;
	var attackTimer:Float;
	// var invulnTimer:Float;  # Forgoing this since we'll use 'flicker' for the invuln state
	var attackDelayTimer:Float;

	private var aimingAngle:Float;
	private var aimingInPlace:Bool = false;
	private var strafingActive:Bool = false;
	private var aimingArrow:FlxSprite;
	private var aimingArrowDelayTimer:Float;

	// var stepSound:FlxSound;
	static inline var SPEED:Float = 100;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		this.maxHealth = INITIAL_MAX_HEALTH;
		this.health = maxHealth;
		this.maxLevel = 10;
		this.level = 1;
		this.base_damage = 1;
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

		// Set the graphic to show where the bow is currently aiming
		aimingArrow = new FlxSprite(x, y);
		aimingArrow.loadGraphic(AssetPaths.aim_arrow__png, false, 4, 6);
	}

	override function update(elapsed:Float)
	{
		updateState(elapsed);
		updateMovement();
		updatePlayerAnimation();
		super.update(elapsed);
		aimingArrow.setPosition(x + 1, y);
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
			if (!aimingInPlace)
			{
				// Player should be slower if they are strafing while firing arrows
				if (strafingActive && (state == ATTACKING || state == ATTACK_COOLDOWN))
					velocity.set(SPEED * .5, 0);
				else
					velocity.set(SPEED, 0);
				velocity.rotate(FlxPoint.weak(0, 0), newAngle);
			}

			if (!strafingActive)
			{
				aimingAngle = newAngle;
				aimingArrow.angle = newAngle;
				aimingArrow.offset.set(-8, 0);
				aimingArrow.offset.rotate(FlxPoint.weak(0, 0), newAngle);
			}
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
		var keepAngle:Bool = false;

		#if FLX_KEYBOARD
		use = FlxG.keys.anyPressed([SPACE]);
		keepAngle = FlxG.keys.anyPressed([SHIFT]);
		#end

		// Determine if the player will strafe or stand in place to aim his bow
		if (keepAngle && equippedWeapon == BOW)
			strafingActive = true;
		else
			strafingActive = false;

		if (!use || keepAngle)
			aimingInPlace = false;
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
					// Add projectile logic
					if (!keepAngle)
						aimingInPlace = true;
					fireArrow();
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
						if (!use)
							aimingInPlace = false;
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

		if (strafingActive)
			aimingArrow.visible = true;
		else if (aimingInPlace)
		{
			if (aimingArrowDelayTimer < 0)
				aimingArrow.visible = true;
			else
				aimingArrowDelayTimer -= elapsed;
		}
		else
		{
			aimingArrow.visible = false;
			aimingArrowDelayTimer = 0.15;
		}
	}

	public function onBeingInjured(point:FlxPoint, damage:Int = 1)
	{
		this.flicker();
		health -= damage;

		if (health <= 0)
		{
			health = 0;
			this.kill();
		}
	}

	public function onEnemyContact(point:FlxPoint, damage:Int = 1)
	{
		if (this.isFlickering() || !this.alive)
		{
			return;
		}
		onBeingInjured(point, damage);
	}

	public function increaseExperience(exp:Int = 1)
	{
		if (level == maxLevel)
		{
			return;
		}

		var req_exp = REQ_EXP_FOR_LEVELUP(level);
		var did_level_up = false;
		experience += exp;
		while (experience >= req_exp)
		{
			level += 1;
			experience -= req_exp;
			req_exp = REQ_EXP_FOR_LEVELUP(level);
			did_level_up = true;
		}

		if (level > maxLevel)
			level = maxLevel;
		if (experience < 0)
			experience = 0;

		if (did_level_up)
		{
			base_damage = Std.int((level + 1) / 2);
			resetHealthToMax();
		}
	}

	public function getCurrExp()
	{
		return experience;
	}

	public function getCurrMaxExp()
	{
		return REQ_EXP_FOR_LEVELUP(level);
	}

	public function resetHealthToMax()
	{
		maxHealth = INITIAL_MAX_HEALTH + level;
		health = maxHealth;
	}

	public function getDamageDone()
	{
		if (equippedWeapon == WeaponType.SWORD)
		{
			return base_damage + 1;
		}
		return base_damage;
	}

	private function fireArrow()
	{
		var arrow:Arrow = TestState.arrows.recycle();
		arrow.startArrow();
		arrow.reset(x + (width - arrow.width) / 2, y + (offset.y - arrow.height) / 2);
		// TODO: Stop in place and aim in 8 cardinal directions
		arrow.angle = aimingAngle; // If we modify 'angle' then the actual sprite will be rotating

		arrow.velocity.set(150, 0);
		arrow.velocity.rotate(FlxPoint.weak(0, 0), arrow.angle);

		arrow.velocity.x *= 2;
		arrow.velocity.y *= 2;
		arrow.damage = base_damage;
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

	// Return an array of all FlxSprites that should animate/relate to the player
	//
	// E.g.: Aiming arrows, animating buffs/effects, etc
	public function enumerateDrawEffects():Array<FlxSprite>
	{
		return [aimingArrow];
	}
}
