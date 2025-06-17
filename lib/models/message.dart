import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  joinGame,
  leaveGame,
  gameStarted,
  roundStarted,
  letterSelected,
  submitAnswers,
  playerSubmitted,
  roundEnded,
  scoringResults,
  scoreUpdate,
  gameEnded,
  finalScoreboard,
  playerReady,
  gameLobbyData,
  error,
  ping,
  pong,
  hostSessionTerminated,
}

@freezed
class Message with _$Message {
  const factory Message({
    required MessageType type,
    required Map<String, dynamic> payload,
    required String senderId,
    required DateTime timestamp,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
