import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    required String ipAddress,
    required int port,
    @Default(false) bool isHost,
    @Default({}) Map<String, int> scores,
    @Default(false) bool isReady,
    @Default(false) bool isConnected,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
