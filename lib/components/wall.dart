import 'package:animal_merge_game/components/body_component_with_user_data.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Wall extends BodyComponentWithUserData {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
