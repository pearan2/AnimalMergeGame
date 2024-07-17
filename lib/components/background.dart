import 'dart:math';

import 'package:animal_merge_game/components/game.dart';
import 'package:flame/components.dart';

class Background extends SpriteComponent
    with HasGameReference<AnimalMergeGame> {
  Background({required super.sprite})
      : super(anchor: Anchor.center, position: Vector2(0, 0));

  @override
  void onMount() {
    super.onMount();

    size = Vector2.all(max(game.camera.visibleWorldRect.width,
        game.camera.visibleWorldRect.height));
  }
}
