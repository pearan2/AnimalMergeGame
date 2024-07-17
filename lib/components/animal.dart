import 'dart:math';

import 'package:animal_merge_game/components/body_component_with_user_data.dart';
import 'package:animal_merge_game/components/game.dart';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart' as pt;
import 'package:flame_forge2d/flame_forge2d.dart';

const animalDefaultScale = 0.1;

enum AnimalType {
  chick(defaultScale: animalDefaultScale, score: 500), // 병아리
  chicken(defaultScale: animalDefaultScale, score: 2), // 닭
  duck(defaultScale: animalDefaultScale, score: 3), // 거위
  parrot(defaultScale: animalDefaultScale, score: 4), // 앵무새
  monkey(defaultScale: animalDefaultScale, score: 5), // 원숭이
  gorilla(defaultScale: animalDefaultScale, score: 6), // 고릴라
  pig(defaultScale: animalDefaultScale, score: 7), // 돼지
  zebra(defaultScale: animalDefaultScale, score: 8), // 얼룩말
  // buffalo(defaultScale: animalDefaultScale * 1.1, score: 10), // 물소
  // cow(defaultScale: animalDefaultScale * 1.2, score: 12), // 소
  rhino(defaultScale: animalDefaultScale * 1.2, score: 15), // 코뿔소
  elephant(defaultScale: animalDefaultScale * 1.4, score: 20); // 코끼리

  final double _defaultScale;
  final int score;

  String get getFileName => "$name.png";
  Sprite get sprite => sheet!.getSprite(getFileName);
  Vector2 get size => sheet!.getSize(getFileName);
  int get level => AnimalType.values.indexOf(this);
  double get scale => _defaultScale * (1 + level);
  AnimalType get next =>
      isLast ? AnimalType.values[0] : AnimalType.values[level + 1];
  bool get isLast =>
      AnimalType.values.indexOf(this) == AnimalType.values.length - 1;

  const AnimalType({required double defaultScale, required this.score})
      : _defaultScale = defaultScale;

  static XmlSpriteSheet? sheet;
  static AnimalType get random => values[Random().nextInt(4) + 1];
}

class Animal extends BodyComponentWithUserData with ContactCallbacks {
  final AnimalType type;

  Animal(this.type, {required Vector2 position})
      : super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.dynamic,
          fixtureDefs: [
            FixtureDef(
              CircleShape()..radius = (type.size.x / 2 * type.scale),
            )
              ..restitution = 0.6
              ..density = type.level.toDouble()
              ..friction = 0.8
          ],
        );

  Future<void> _addParticle() async {
    final sprite = await Flame.images.load('coin.png');

    world.add(
      ParticleSystemComponent(
        position: position,
        anchor: Anchor.center,
        particle: pt.Particle.generate(
          count: type.score,
          generator: (i) => pt.AcceleratedParticle(
              lifespan: 0.3,
              speed: (Vector2.random() - Vector2(0.5, 0.5)) * 10,
              acceleration: (Vector2.random() - Vector2(0.5, 0.5)) * 10,
              child: pt.ScalingParticle(
                  child: pt.SpriteParticle(
                      sprite: Sprite(sprite), size: type.size * type.scale))),
        ),
      ),
    );
  }

  void _addScore() {
    game.onScoreAdded(type.score);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (!isRemoving && !isRemoved && other is Animal && other.type == type) {
      removeFromParent();
      _addParticle();
      _addScore();
      if (position.y > other.position.y) {
        world.add(Animal(type.next, position: position));
        if (type.next == AnimalType.chick) {
          game.numberOfChicks++;
        }
        game.playAnimalMergeSound();
      }
    }
    super.beginContact(other, contact);
  }

  @override
  Future<void> onLoad() {
    add(SpriteComponent(
      anchor: Anchor.center,
      scale: Vector2.all(type.scale),
      size: type.size,
      sprite: type.sprite,
      position: Vector2(0, 0),
    ));
    return super.onLoad();
  }
}
