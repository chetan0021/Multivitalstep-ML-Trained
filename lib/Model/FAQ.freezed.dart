// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'FAQ.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FAQ {
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FAQCopyWith<FAQ> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FAQCopyWith<$Res> {
  factory $FAQCopyWith(FAQ value, $Res Function(FAQ) then) =
      _$FAQCopyWithImpl<$Res, FAQ>;
  @useResult
  $Res call({String question, String answer});
}

/// @nodoc
class _$FAQCopyWithImpl<$Res, $Val extends FAQ> implements $FAQCopyWith<$Res> {
  _$FAQCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
  }) {
    return _then(_value.copyWith(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FAQImplCopyWith<$Res> implements $FAQCopyWith<$Res> {
  factory _$$FAQImplCopyWith(_$FAQImpl value, $Res Function(_$FAQImpl) then) =
      __$$FAQImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question, String answer});
}

/// @nodoc
class __$$FAQImplCopyWithImpl<$Res> extends _$FAQCopyWithImpl<$Res, _$FAQImpl>
    implements _$$FAQImplCopyWith<$Res> {
  __$$FAQImplCopyWithImpl(_$FAQImpl _value, $Res Function(_$FAQImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
  }) {
    return _then(_$FAQImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FAQImpl extends _FAQ {
  const _$FAQImpl({required this.question, required this.answer}) : super._();

  @override
  final String question;
  @override
  final String answer;

  @override
  String toString() {
    return 'FAQ(question: $question, answer: $answer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FAQImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, question, answer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FAQImplCopyWith<_$FAQImpl> get copyWith =>
      __$$FAQImplCopyWithImpl<_$FAQImpl>(this, _$identity);
}

abstract class _FAQ extends FAQ {
  const factory _FAQ(
      {required final String question,
      required final String answer}) = _$FAQImpl;
  const _FAQ._() : super._();

  @override
  String get question;
  @override
  String get answer;
  @override
  @JsonKey(ignore: true)
  _$$FAQImplCopyWith<_$FAQImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
