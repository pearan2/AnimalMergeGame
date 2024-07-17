import 'package:animal_merge_game/components/animal.dart';
import 'package:animal_merge_game/components/body_component_with_user_data.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class GameOverLine extends BodyComponentWithUserData with ContactCallbacks {
  final Vector2 _start;
  final Vector2 _end;
  final void Function() onGameOver;

  GameOverLine(this._start, this._end, {required this.onGameOver});

  final animals = <Animal, DateTime>{};

  double tick = 0.0;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Animal) {
      animals[other] = DateTime.now();
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Animal) {
      animals.remove(other);
    }
    super.endContact(other, contact);
  }

  void addTick(double dt) {
    tick += dt;
    if (tick < 1) {
      return;
    }
    tick = 0;
    final keys = animals.keys.toList();
    for (int i = keys.length - 1; i >= 0; i--) {
      final key = keys[i];
      if (key.isRemoving || key.isRemoved) {
        animals.remove(key);
      } else {
        final lastContactTime = animals[key]!;
        if (lastContactTime
            .isBefore(DateTime.now().add(-const Duration(seconds: 1)))) {
          onGameOver();
        }
      }
    }
  }

  @override
  void update(double dt) {
    addTick(dt);
    super.update(dt);
  }

  @override
  Body createBody() {
    final width = _end.x - _start.x;
    final center = _start + ((_end - _start) / 2) - Vector2(0, 0.001);
    const height = 0.0001;

    final shape = PolygonShape()..setAsBox(width / 2, height, center, 0);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    final bodyDef = BodyDef(
      type: BodyType.static,
      userData: this,
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
