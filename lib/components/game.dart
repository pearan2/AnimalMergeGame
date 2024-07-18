import 'dart:async';

import 'package:animal_merge_game/components/animal.dart';
import 'package:animal_merge_game/components/background.dart';
import 'package:animal_merge_game/components/game_over_line.dart';
import 'package:animal_merge_game/components/wall.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

const worldZoomLevel = 100.0;

extension DoubleExtension on double {
  double get scale => this / worldZoomLevel;
}

extension IntExtension on int {
  double get scale => this / worldZoomLevel;
}

class AnimalMergeGame extends Forge2DGame with TapCallbacks {
  static const gameOverOverlayKey = 'gameOver';
  static const statusBarOverlayKey = 'statusBar';
  static int numberOfMergeSoundEffectPlayings = 0;

  late final XmlSpriteSheet animalSheet;

  final mt.ValueNotifier<int> score = mt.ValueNotifier(0);
  final mt.ValueNotifier<AnimalType> nextAnimalType =
      mt.ValueNotifier(AnimalType.random);
  int numberOfChicks = 0;

  AnimalMergeGame() : super(gravity: Vector2(0, 5));

  void onScoreAdded(int score) {
    this.score.value += score;
  }

  @override
  FutureOr<void> onLoad() async {
    final [animalImage, _, backgroundImage] = await [
      images.load('animal.png'),
      images.load('coin.png'),
      images.load('background.jpg'),
    ].wait;
    await FlameAudio.audioCache.load('merge.wav');
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.zoom = worldZoomLevel;
    camera.viewfinder.anchor = Anchor.center;

    animalSheet = XmlSpriteSheet(
        animalImage, await rootBundle.loadString('assets/animal.xml'));
    AnimalType.sheet = animalSheet;

    world.add(Background(sprite: Sprite(backgroundImage)));
    world.addAll(createBoundaries());

    overlays.add(statusBarOverlayKey);
    return super.onLoad();
  }

  void reStart() {
    for (var e in world.children) {
      if (e is Animal) {
        e.removeFromParent();
      }
    }
    overlays.remove(gameOverOverlayKey);
    score.value = 0;
    numberOfChicks = 0;
    paused = false;
  }

  void gameOver() {
    paused = true;
    overlays.add(gameOverOverlayKey);
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      GameOverLine(topLeft, topRight, onGameOver: gameOver),
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  Future<void> playAnimalMergeSound() async {
    if (numberOfMergeSoundEffectPlayings < 3) {
      FlameAudio.play('merge.wav')
          .then((_) => numberOfMergeSoundEffectPlayings--);
      numberOfMergeSoundEffectPlayings++;
    }
  }

  void pickNextAnimal() {
    nextAnimalType.value = AnimalType.random;
  }

  void addAnimal(double x) {
    x -= camera.visibleWorldRect.size.width / 2;
    world.add(Animal(nextAnimalType.value,
        position: Vector2(x, camera.visibleWorldRect.top)));
    pickNextAnimal();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (paused) {
      return;
    }
    addAnimal(event.canvasPosition.x.scale);
  }
}

class XmlSpriteSheet {
  final Image image;
  final _rects = <String, Rect>{};

  XmlSpriteSheet(this.image, String xml) {
    final document = XmlDocument.parse(xml);
    for (final node in document.xpath('//TextureAtlas/SubTexture')) {
      final name = node.getAttribute('name')!;
      final x = double.parse(node.getAttribute('x')!);
      final y = double.parse(node.getAttribute('y')!);
      final width = double.parse(node.getAttribute('width')!);
      final height = double.parse(node.getAttribute('height')!);
      _rects[name] = Rect.fromLTWH(x, y, width, height);
    }
  }

  Vector2 getSize(String name) {
    final rect = _rects[name];
    if (rect == null) {
      throw ArgumentError('Sprite $name not found');
    }
    return Vector2(rect.width.scale, rect.height.scale);
  }

  Sprite getSprite(String name) {
    final rect = _rects[name];
    if (rect == null) {
      throw ArgumentError('Sprite $name not found');
    }
    return Sprite(image,
        srcPosition: rect.topLeft.toVector2(), srcSize: rect.size.toVector2());
  }
}
