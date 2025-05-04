// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get id => throw _privateConstructorUsedError;
  List<Player> get players => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  GameSettings get settings => throw _privateConstructorUsedError;
  List<GameRound> get rounds => throw _privateConstructorUsedError;
  GameState get state => throw _privateConstructorUsedError;
  Player get host => throw _privateConstructorUsedError;
  String? get currentLetter => throw _privateConstructorUsedError;
  int? get currentRound => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call(
      {String id,
      List<Player> players,
      List<String> categories,
      GameSettings settings,
      List<GameRound> rounds,
      GameState state,
      Player host,
      String? currentLetter,
      int? currentRound});

  $GameSettingsCopyWith<$Res> get settings;
  $PlayerCopyWith<$Res> get host;
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? players = null,
    Object? categories = null,
    Object? settings = null,
    Object? rounds = null,
    Object? state = null,
    Object? host = null,
    Object? currentLetter = freezed,
    Object? currentRound = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GameSettings,
      rounds: null == rounds
          ? _value.rounds
          : rounds // ignore: cast_nullable_to_non_nullable
              as List<GameRound>,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as GameState,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as Player,
      currentLetter: freezed == currentLetter
          ? _value.currentLetter
          : currentLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      currentRound: freezed == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSettingsCopyWith<$Res> get settings {
    return $GameSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerCopyWith<$Res> get host {
    return $PlayerCopyWith<$Res>(_value.host, (value) {
      return _then(_value.copyWith(host: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
          _$GameImpl value, $Res Function(_$GameImpl) then) =
      __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<Player> players,
      List<String> categories,
      GameSettings settings,
      List<GameRound> rounds,
      GameState state,
      Player host,
      String? currentLetter,
      int? currentRound});

  @override
  $GameSettingsCopyWith<$Res> get settings;
  @override
  $PlayerCopyWith<$Res> get host;
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
      : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? players = null,
    Object? categories = null,
    Object? settings = null,
    Object? rounds = null,
    Object? state = null,
    Object? host = null,
    Object? currentLetter = freezed,
    Object? currentRound = freezed,
  }) {
    return _then(_$GameImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GameSettings,
      rounds: null == rounds
          ? _value._rounds
          : rounds // ignore: cast_nullable_to_non_nullable
              as List<GameRound>,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as GameState,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as Player,
      currentLetter: freezed == currentLetter
          ? _value.currentLetter
          : currentLetter // ignore: cast_nullable_to_non_nullable
              as String?,
      currentRound: freezed == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameImpl implements _Game {
  const _$GameImpl(
      {required this.id,
      required final List<Player> players,
      required final List<String> categories,
      required this.settings,
      final List<GameRound> rounds = const [],
      this.state = GameState.lobby,
      required this.host,
      this.currentLetter,
      this.currentRound})
      : _players = players,
        _categories = categories,
        _rounds = rounds;

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String id;
  final List<Player> _players;
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  final List<String> _categories;
  @override
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  final GameSettings settings;
  final List<GameRound> _rounds;
  @override
  @JsonKey()
  List<GameRound> get rounds {
    if (_rounds is EqualUnmodifiableListView) return _rounds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rounds);
  }

  @override
  @JsonKey()
  final GameState state;
  @override
  final Player host;
  @override
  final String? currentLetter;
  @override
  final int? currentRound;

  @override
  String toString() {
    return 'Game(id: $id, players: $players, categories: $categories, settings: $settings, rounds: $rounds, state: $state, host: $host, currentLetter: $currentLetter, currentRound: $currentRound)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            const DeepCollectionEquality().equals(other._rounds, _rounds) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.currentLetter, currentLetter) ||
                other.currentLetter == currentLetter) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_players),
      const DeepCollectionEquality().hash(_categories),
      settings,
      const DeepCollectionEquality().hash(_rounds),
      state,
      host,
      currentLetter,
      currentRound);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(
      this,
    );
  }
}

abstract class _Game implements Game {
  const factory _Game(
      {required final String id,
      required final List<Player> players,
      required final List<String> categories,
      required final GameSettings settings,
      final List<GameRound> rounds,
      final GameState state,
      required final Player host,
      final String? currentLetter,
      final int? currentRound}) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get id;
  @override
  List<Player> get players;
  @override
  List<String> get categories;
  @override
  GameSettings get settings;
  @override
  List<GameRound> get rounds;
  @override
  GameState get state;
  @override
  Player get host;
  @override
  String? get currentLetter;
  @override
  int? get currentRound;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameRound _$GameRoundFromJson(Map<String, dynamic> json) {
  return _GameRound.fromJson(json);
}

/// @nodoc
mixin _$GameRound {
  String get id => throw _privateConstructorUsedError;
  String get letter => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  Map<String, Map<String, String>> get answers =>
      throw _privateConstructorUsedError; // playerId -> category -> answer
  Map<String, Map<String, int>> get scores =>
      throw _privateConstructorUsedError;

  /// Serializes this GameRound to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameRoundCopyWith<GameRound> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameRoundCopyWith<$Res> {
  factory $GameRoundCopyWith(GameRound value, $Res Function(GameRound) then) =
      _$GameRoundCopyWithImpl<$Res, GameRound>;
  @useResult
  $Res call(
      {String id,
      String letter,
      int roundNumber,
      DateTime startTime,
      DateTime? endTime,
      Map<String, Map<String, String>> answers,
      Map<String, Map<String, int>> scores});
}

/// @nodoc
class _$GameRoundCopyWithImpl<$Res, $Val extends GameRound>
    implements $GameRoundCopyWith<$Res> {
  _$GameRoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? letter = null,
    Object? roundNumber = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? answers = null,
    Object? scores = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      letter: null == letter
          ? _value.letter
          : letter // ignore: cast_nullable_to_non_nullable
              as String,
      roundNumber: null == roundNumber
          ? _value.roundNumber
          : roundNumber // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      scores: null == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, int>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameRoundImplCopyWith<$Res>
    implements $GameRoundCopyWith<$Res> {
  factory _$$GameRoundImplCopyWith(
          _$GameRoundImpl value, $Res Function(_$GameRoundImpl) then) =
      __$$GameRoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String letter,
      int roundNumber,
      DateTime startTime,
      DateTime? endTime,
      Map<String, Map<String, String>> answers,
      Map<String, Map<String, int>> scores});
}

/// @nodoc
class __$$GameRoundImplCopyWithImpl<$Res>
    extends _$GameRoundCopyWithImpl<$Res, _$GameRoundImpl>
    implements _$$GameRoundImplCopyWith<$Res> {
  __$$GameRoundImplCopyWithImpl(
      _$GameRoundImpl _value, $Res Function(_$GameRoundImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? letter = null,
    Object? roundNumber = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? answers = null,
    Object? scores = null,
  }) {
    return _then(_$GameRoundImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      letter: null == letter
          ? _value.letter
          : letter // ignore: cast_nullable_to_non_nullable
              as String,
      roundNumber: null == roundNumber
          ? _value.roundNumber
          : roundNumber // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      scores: null == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, int>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameRoundImpl implements _GameRound {
  const _$GameRoundImpl(
      {required this.id,
      required this.letter,
      required this.roundNumber,
      required this.startTime,
      this.endTime,
      final Map<String, Map<String, String>> answers = const {},
      final Map<String, Map<String, int>> scores = const {}})
      : _answers = answers,
        _scores = scores;

  factory _$GameRoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameRoundImplFromJson(json);

  @override
  final String id;
  @override
  final String letter;
  @override
  final int roundNumber;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  final Map<String, Map<String, String>> _answers;
  @override
  @JsonKey()
  Map<String, Map<String, String>> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

// playerId -> category -> answer
  final Map<String, Map<String, int>> _scores;
// playerId -> category -> answer
  @override
  @JsonKey()
  Map<String, Map<String, int>> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

  @override
  String toString() {
    return 'GameRound(id: $id, letter: $letter, roundNumber: $roundNumber, startTime: $startTime, endTime: $endTime, answers: $answers, scores: $scores)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameRoundImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.letter, letter) || other.letter == letter) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            const DeepCollectionEquality().equals(other._scores, _scores));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      letter,
      roundNumber,
      startTime,
      endTime,
      const DeepCollectionEquality().hash(_answers),
      const DeepCollectionEquality().hash(_scores));

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameRoundImplCopyWith<_$GameRoundImpl> get copyWith =>
      __$$GameRoundImplCopyWithImpl<_$GameRoundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameRoundImplToJson(
      this,
    );
  }
}

abstract class _GameRound implements GameRound {
  const factory _GameRound(
      {required final String id,
      required final String letter,
      required final int roundNumber,
      required final DateTime startTime,
      final DateTime? endTime,
      final Map<String, Map<String, String>> answers,
      final Map<String, Map<String, int>> scores}) = _$GameRoundImpl;

  factory _GameRound.fromJson(Map<String, dynamic> json) =
      _$GameRoundImpl.fromJson;

  @override
  String get id;
  @override
  String get letter;
  @override
  int get roundNumber;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  Map<String, Map<String, String>>
      get answers; // playerId -> category -> answer
  @override
  Map<String, Map<String, int>> get scores;

  /// Create a copy of GameRound
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameRoundImplCopyWith<_$GameRoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
