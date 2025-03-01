// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadEvent {

 Object get field0;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEvent&&const DeepCollectionEquality().equals(other.field0, field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(field0));

@override
String toString() {
  return 'DownloadEvent(field0: $field0)';
}


}

/// @nodoc
class $DownloadEventCopyWith<$Res>  {
$DownloadEventCopyWith(DownloadEvent _, $Res Function(DownloadEvent) __);
}


/// @nodoc


class DownloadEvent_Progress extends DownloadEvent {
  const DownloadEvent_Progress(this.field0): super._();
  

@override final  DownloadProgress field0;

/// Create a copy of DownloadEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEvent_ProgressCopyWith<DownloadEvent_Progress> get copyWith => _$DownloadEvent_ProgressCopyWithImpl<DownloadEvent_Progress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEvent_Progress&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'DownloadEvent.progress(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DownloadEvent_ProgressCopyWith<$Res> implements $DownloadEventCopyWith<$Res> {
  factory $DownloadEvent_ProgressCopyWith(DownloadEvent_Progress value, $Res Function(DownloadEvent_Progress) _then) = _$DownloadEvent_ProgressCopyWithImpl;
@useResult
$Res call({
 DownloadProgress field0
});




}
/// @nodoc
class _$DownloadEvent_ProgressCopyWithImpl<$Res>
    implements $DownloadEvent_ProgressCopyWith<$Res> {
  _$DownloadEvent_ProgressCopyWithImpl(this._self, this._then);

  final DownloadEvent_Progress _self;
  final $Res Function(DownloadEvent_Progress) _then;

/// Create a copy of DownloadEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DownloadEvent_Progress(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as DownloadProgress,
  ));
}


}

/// @nodoc


class DownloadEvent_Error extends DownloadEvent {
  const DownloadEvent_Error(this.field0): super._();
  

@override final  String field0;

/// Create a copy of DownloadEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEvent_ErrorCopyWith<DownloadEvent_Error> get copyWith => _$DownloadEvent_ErrorCopyWithImpl<DownloadEvent_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEvent_Error&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'DownloadEvent.error(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DownloadEvent_ErrorCopyWith<$Res> implements $DownloadEventCopyWith<$Res> {
  factory $DownloadEvent_ErrorCopyWith(DownloadEvent_Error value, $Res Function(DownloadEvent_Error) _then) = _$DownloadEvent_ErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$DownloadEvent_ErrorCopyWithImpl<$Res>
    implements $DownloadEvent_ErrorCopyWith<$Res> {
  _$DownloadEvent_ErrorCopyWithImpl(this._self, this._then);

  final DownloadEvent_Error _self;
  final $Res Function(DownloadEvent_Error) _then;

/// Create a copy of DownloadEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DownloadEvent_Error(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
