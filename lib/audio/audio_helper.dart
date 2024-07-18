import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  final List<AudioPlayer> _players;
  final AssetSource source;
  final String sourcePath;
  bool _isInitialized = false;

  AudioHelper(this.sourcePath, {int numberOfPlayers = 10})
      : _players = List.generate(numberOfPlayers, (_) => AudioPlayer()),
        source = AssetSource(sourcePath) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    _players.map((p) => p.setReleaseMode(ReleaseMode.stop));
    await Future.wait(_players.map((p) => p.setSource(source)));
    _isInitialized = true;
    print('audio init finished');
  }

  void play() {
    if (!_isInitialized) return;

    for (int i = 0; i < _players.length; i++) {
      final player = _players[i];
      if (player.state == PlayerState.stopped) {
        player.resume();
        return;
      } else if (player.state == PlayerState.completed) {
        player.play(source);
        return;
      } else if (player.state == PlayerState.playing) {}
    }
  }
}
