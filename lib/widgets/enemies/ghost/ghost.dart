import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:ng_bonfire/utils/basic_value.dart';
import 'package:ng_bonfire/widgets/enemies/ghost/ghost_sprite_sheet.dart';

const tileSize = BasicValues.TILE_SIZE;

class Ghost extends SimpleEnemy with ObjectCollision, Lighting {
  bool canMove = true;
  Ghost({required Vector2 position})
      : super(
          life: 400,
          position: position,
          initDirection: Direction.left,
          speed: 80,
          size: Vector2(tileSize * 7, tileSize * 7),
          animation: SimpleDirectionAnimation(
            idleRight: GhostSpriteSheet.ghostIdleRight,
            idleLeft: GhostSpriteSheet.ghostIdleLeft,
            runRight: GhostSpriteSheet.ghostRunRight,
            runLeft: GhostSpriteSheet.ghostRunLeft,
          ),
        ) {
//Seta colisão
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(35, 45),
            align: Vector2(105, 120),
          ),
        ],
      ),
    );
    setupLighting(
      LightingConfig(
          radius: tileSize * 1.3,
          color: Colors.blueGrey.withOpacity(0.25),
          withPulse: true,
          pulseSpeed: 2,
          pulseVariation: 0.12,
          align: Vector2(5, 35),
          blurBorder: 15,
          useComponentAngle: true),
    );
  }

//Life bar
  @override
  void render(Canvas canvas) {
    drawDefaultLifeBar(
      canvas,
      width: 55,
      borderWidth: 1.5,
      height: 5,
      align: const Offset(90, -50),
      borderRadius: BorderRadius.circular(3),
      borderColor: Colors.black87,
      colorsLife: [
        Colors.red.shade700,
      ],
    );
    super.render(canvas);
  }

//Ataca ao ver
  @override
  void update(double dt) {
    if (canMove) {
     seePlayer(
        observed: (player) {
          seeAndMoveToPlayer(
            closePlayer: (player) {
              followComponent(
                player,
                dt,
                closeComponent: (player) {
                  _execAttack();
                },
              );
            },
            radiusVision: tileSize * 10,
            runOnlyVisibleInScreen: true,
          );
        },
        notObserved: () {
          idle();
        },
        radiusVision: tileSize * 10,
      );
    }
    super.update(dt);
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, identify) {
    if (!isDead) {
      _addDamageAnimation();
      showDamage(
        -damage,
        initVelocityTop: -3,
        maxDownSize: 20,
        config: TextStyle(
          color: Colors.blue.shade200,
          fontSize: tileSize / 2,
        ),
      );
    }
    super.receiveDamage(attacker, damage, identify);
  }

  void _execAttack() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    simpleAttackMelee(
      withPush: false,
      damage: 20,
      size: Vector2.all(tileSize * 2),
      interval: 800,
      execute: () {
        _addBossAttackAnimation();
      },
    );
  }

//Attack animation
  void _addBossAttackAnimation() {
    canMove = false;
    Future<SpriteAnimation> newAnimation;
    switch (lastDirection) {
      case Direction.left:
        newAnimation = GhostSpriteSheet.attackLeft;
        break;
      case Direction.right:
        newAnimation = GhostSpriteSheet.attackRight;
        break;
      case Direction.up:
        if (lastDirectionHorizontal == Direction.right) {
          newAnimation = GhostSpriteSheet.attackRight;
        } else {
          newAnimation = GhostSpriteSheet.attackLeft;
        }
        break;

      case Direction.down:
        if (lastDirectionHorizontal == Direction.right) {
          newAnimation = GhostSpriteSheet.attackRight;
        } else {
          newAnimation = GhostSpriteSheet.attackLeft;
        }
        break;

      case Direction.upLeft:
        newAnimation = GhostSpriteSheet.attackLeft;
        break;

      case Direction.upRight:
        newAnimation = GhostSpriteSheet.attackRight;
        break;

      case Direction.downLeft:
        newAnimation = GhostSpriteSheet.attackLeft;
        break;

      case Direction.downRight:
        newAnimation = GhostSpriteSheet.attackRight;
        break;
    }

    animation!.playOnce(
      newAnimation,
      runToTheEnd: false,
      onFinish: (() {
        canMove = true;
      }),
    );
  }

//Damage taken
  void _addDamageAnimation() {
    canMove = false;
    Future<SpriteAnimation> newAnimation;
    switch (lastDirection) {
      case Direction.left:
        newAnimation = GhostSpriteSheet.takeHitLeft;
        break;
      case Direction.right:
        newAnimation = GhostSpriteSheet.takeHitRight;
        break;
      case Direction.up:
        if (lastDirectionHorizontal == Direction.up) {
          newAnimation = GhostSpriteSheet.takeHitRight;
        } else {
          newAnimation = GhostSpriteSheet.takeHitRight;
        }
        break;
      case Direction.down:
        if (lastDirectionHorizontal == Direction.down) {
          newAnimation = GhostSpriteSheet.takeHitRight;
        } else {
          newAnimation = GhostSpriteSheet.takeHitLeft;
        }
        break;
      case Direction.upLeft:
        newAnimation = GhostSpriteSheet.takeHitLeft;
        break;
      case Direction.upRight:
        newAnimation = GhostSpriteSheet.takeHitRight;
        break;
      case Direction.downLeft:
        newAnimation = GhostSpriteSheet.takeHitLeft;
        break;
      case Direction.downRight:
        newAnimation = GhostSpriteSheet.takeHitRight;
        break;
    }
    animation!.playOnce(
      newAnimation,
      runToTheEnd: true,
      onFinish: (() {
        canMove = true;
      }),
    );
  }

//Death
  @override
  void die() {
    if (gameRef.player!.lastDirectionHorizontal == Direction.left) {
      gameRef.add(
        AnimatedObjectOnce(
          animation: GhostSpriteSheet.ghostDeathLeft,
          position: position,
          size: size,
          onFinish: () => removeFromParent(),
        ),
      );
    } else {
      gameRef.add(
        AnimatedObjectOnce(
          animation: GhostSpriteSheet.ghostDeathRight,
          position: position,
          size: size,
          onFinish: () => removeFromParent(),
        ),
      );
    }
    removeFromParent();
    super.die();
  }
}
