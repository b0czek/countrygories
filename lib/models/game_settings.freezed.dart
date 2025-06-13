// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameSettings _$GameSettingsFromJson(Map<String, dynamic> json) {
  return _GameSettings.fromJson(json);
}

/// @nodoc
mixin _$GameSettings {
  int get numberOfRounds => throw _privateConstructorUsedError;
  int get timePerRound => throw _privateConstructorUsedError;
  ScoringMode get scoringMode => throw _privateConstructorUsedError;
  bool get allowCustomCategories => throw _privateConstructorUsedError;
  List<String> get excludedLetters => throw _privateConstructorUsedError;
  List<String> get selectedCategories => throw _privateConstructorUsedError;

  /// Serializes this GameSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSettingsCopyWith<GameSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSettingsCopyWith<$Res> {
  factory $GameSettingsCopyWith(
          GameSettings value, $Res Function(GameSettings) then) =
      _$GameSettingsCopyWithImpl<$Res, GameSettings>;
  @useResult
  $Res call(
      {int numberOfRounds,
      int timePerRound,
      ScoringMode scoringMode,
      bool allowCustomCategories,
      List<String> excludedLetters,
      List<String> selectedCategories});
}

/// @nodoc
class _$GameSettingsCopyWithImpl<$Res, $Val extends GameSettings>
    implements $GameSettingsCopyWith<$Res> {
  _$GameSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numberOfRounds = null,
    Object? timePerRound = null,
    Object? scoringMode = null,
    Object? allowCustomCategories = null,
    Object? excludedLetters = null,
    Object? selectedCategories = null,
  }) {
    return _then(_value.copyWith(
      numberOfRounds: null == numberOfRounds
          ? _value.numberOfRounds
          : numberOfRounds // ignore: cast_nullable_to_non_nullable
              as int,
      timePerRound: null == timePerRound
          ? _value.timePerRound
          : timePerRound // ignore: cast_nullable_to_non_nullable
              as int,
      scoringMode: null == scoringMode
          ? _value.scoringMode
          : scoringMode // ignore: cast_nullable_to_non_nullable
              as ScoringMode,
      allowCustomCategories: null == allowCustomCategories
          ? _value.allowCustomCategories
          : allowCustomCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      excludedLetters: null == excludedLetters
          ? _value.excludedLetters
          : excludedLetters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedCategories: null == selectedCategories
          ? _value.selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameSettingsImplCopyWith<$Res>
    implements $GameSettingsCopyWith<$Res> {
  factory _$$GameSettingsImplCopyWith(
          _$GameSettingsImpl value, $Res Function(_$GameSettingsImpl) then) =
      __$$GameSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int numberOfRounds,
      int timePerRound,
      ScoringMode scoringMode,
      bool allowCustomCategories,
      List<String> excludedLetters,
      List<String> selectedCategories});
}

/// @nodoc
class __$$GameSettingsImplCopyWithImpl<$Res>
    extends _$GameSettingsCopyWithImpl<$Res, _$GameSettingsImpl>
    implements _$$GameSettingsImplCopyWith<$Res> {
  __$$GameSettingsImplCopyWithImpl(
      _$GameSettingsImpl _value, $Res Function(_$GameSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numberOfRounds = null,
    Object? timePerRound = null,
    Object? scoringMode = null,
    Object? allowCustomCategories = null,
    Object? excludedLetters = null,
    Object? selectedCategories = null,
  }) {
    return _then(_$GameSettingsImpl(
      numberOfRounds: null == numberOfRounds
          ? _value.numberOfRounds
          : numberOfRounds // ignore: cast_nullable_to_non_nullable
              as int,
      timePerRound: null == timePerRound
          ? _value.timePerRound
          : timePerRound // ignore: cast_nullable_to_non_nullable
              as int,
      scoringMode: null == scoringMode
          ? _value.scoringMode
          : scoringMode // ignore: cast_nullable_to_non_nullable
              as ScoringMode,
      allowCustomCategories: null == allowCustomCategories
          ? _value.allowCustomCategories
          : allowCustomCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      excludedLetters: null == excludedLetters
          ? _value._excludedLetters
          : excludedLetters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedCategories: null == selectedCategories
          ? _value._selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSettingsImpl implements _GameSettings {
  const _$GameSettingsImpl(
      {this.numberOfRounds = 5,
      this.timePerRound = 60,
      this.scoringMode = ScoringMode.manual,
      this.allowCustomCategories = true,
      final List<String> excludedLetters = const ["Q", "V", "X", "Y"],
      final List<String> selectedCategories = const []})
      : _excludedLetters = excludedLetters,
        _selectedCategories = selectedCategories;

  factory _$GameSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSettingsImplFromJson(json);

  @override
  @JsonKey()
  final int numberOfRounds;
  @override
  @JsonKey()
  final int timePerRound;
  @override
  @JsonKey()
  final ScoringMode scoringMode;
  @override
  @JsonKey()
  final bool allowCustomCategories;
  final List<String> _excludedLetters;
  @override
  @JsonKey()
  List<String> get excludedLetters {
    if (_excludedLetters is EqualUnmodifiableListView) return _excludedLetters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedLetters);
  }

  final List<String> _selectedCategories;
  @override
  @JsonKey()
  List<String> get selectedCategories {
    if (_selectedCategories is EqualUnmodifiableListView)
      return _selectedCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedCategories);
  }

  @override
  String toString() {
    return 'GameSettings(numberOfRounds: $numberOfRounds, timePerRound: $timePerRound, scoringMode: $scoringMode, allowCustomCategories: $allowCustomCategories, excludedLetters: $excludedLetters, selectedCategories: $selectedCategories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSettingsImpl &&
            (identical(other.numberOfRounds, numberOfRounds) ||
                other.numberOfRounds == numberOfRounds) &&
            (identical(other.timePerRound, timePerRound) ||
                other.timePerRound == timePerRound) &&
            (identical(other.scoringMode, scoringMode) ||
                other.scoringMode == scoringMode) &&
            (identical(other.allowCustomCategories, allowCustomCategories) ||
                other.allowCustomCategories == allowCustomCategories) &&
            const DeepCollectionEquality()
                .equals(other._excludedLetters, _excludedLetters) &&
            const DeepCollectionEquality()
                .equals(other._selectedCategories, _selectedCategories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      numberOfRounds,
      timePerRound,
      scoringMode,
      allowCustomCategories,
      const DeepCollectionEquality().hash(_excludedLetters),
      const DeepCollectionEquality().hash(_selectedCategories));

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSettingsImplCopyWith<_$GameSettingsImpl> get copyWith =>
      __$$GameSettingsImplCopyWithImpl<_$GameSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSettingsImplToJson(
      this,
    );
  }
}

abstract class _GameSettings implements GameSettings {
  const factory _GameSettings(
      {final int numberOfRounds,
      final int timePerRound,
      final ScoringMode scoringMode,
      final bool allowCustomCategories,
      final List<String> excludedLetters,
      final List<String> selectedCategories}) = _$GameSettingsImpl;

  factory _GameSettings.fromJson(Map<String, dynamic> json) =
      _$GameSettingsImpl.fromJson;

  @override
  int get numberOfRounds;
  @override
  int get timePerRound;
  @override
  ScoringMode get scoringMode;
  @override
  bool get allowCustomCategories;
  @override
  List<String> get excludedLetters;
  @override
  List<String> get selectedCategories;

  /// Create a copy of GameSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSettingsImplCopyWith<_$GameSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
