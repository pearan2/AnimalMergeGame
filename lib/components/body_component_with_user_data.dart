import 'package:animal_merge_game/components/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BodyComponentWithUserData extends BodyComponent<AnimalMergeGame> {
  BodyComponentWithUserData({
    super.key,
    super.bodyDef,
    super.children,
    super.fixtureDefs,
    super.paint,
    super.priority,
    super.renderBody,
  });

  @override
  Body createBody() {
    final body = world.createBody(super.bodyDef!)..userData = this;
    fixtureDefs?.forEach(body.createFixture);
    return body;
  }
}
