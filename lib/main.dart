import 'package:animal_merge_game/components/game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(
      home: GameWrapper(),
    ),
  );
}

class GameWrapper extends StatelessWidget {
  const GameWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return GameWidget<AnimalMergeGame>.controlled(
      gameFactory: () => AnimalMergeGame(),
      overlayBuilderMap: {
        AnimalMergeGame.statusBarOverlayKey: (_, game) {
          return DefaultTextStyle(
            style: GoogleFonts.lobster(),
            child: SafeArea(
                child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder(
                    valueListenable: game.score,
                    builder: (context, value, child) => Text(
                      'Score : $value',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: game.nextAnimalType,
                    builder: (context, animalType, child) {
                      return Row(
                        children: [
                          const Text(
                            'Next : ',
                            style: TextStyle(fontSize: 24),
                          ),
                          Image.asset(
                            'assets/images/animals/${animalType.getFileName}',
                            height: 32,
                            width: 32,
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            )),
          );
        },
        AnimalMergeGame.gameOverOverlayKey: (_, game) {
          return DefaultTextStyle(
            style: GoogleFonts.lobster(),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Number of '),
                        Image.asset(
                          'assets/images/animals/chick.png',
                          width: 24,
                          height: 24,
                        ),
                        Text(' : ${game.numberOfChicks}')
                      ],
                    ),
                    TextButton(
                        onPressed: game.reStart,
                        child: const Text(
                          'Play again',
                          style:
                              TextStyle(fontSize: 32, color: Colors.lightBlue),
                        )),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
