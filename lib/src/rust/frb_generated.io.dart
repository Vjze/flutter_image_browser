// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.8.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/check_version.dart';
import 'api/error.dart';
import 'api/simple.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_io.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  CrossPlatformFinalizerArg
  get rust_arc_decrement_strong_count_ImageScanErrorPtr =>
      wire._rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanErrorPtr;

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw);

  @protected
  ImageScanError
  dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    dynamic raw,
  );

  @protected
  ImageScanError
  dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    dynamic raw,
  );

  @protected
  RustStreamSink<DownloadEvent> dco_decode_StreamSink_download_event_Sse(
    dynamic raw,
  );

  @protected
  RustStreamSink<ImageInfo> dco_decode_StreamSink_image_info_Sse(dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  DownloadProgress dco_decode_box_autoadd_download_progress(dynamic raw);

  @protected
  UpdateInfo dco_decode_box_autoadd_update_info(dynamic raw);

  @protected
  DownloadEvent dco_decode_download_event(dynamic raw);

  @protected
  DownloadProgress dco_decode_download_progress(dynamic raw);

  @protected
  double dco_decode_f_32(dynamic raw);

  @protected
  double dco_decode_f_64(dynamic raw);

  @protected
  ImageInfo dco_decode_image_info(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  UpdateInfo? dco_decode_opt_box_autoadd_update_info(dynamic raw);

  @protected
  int dco_decode_u_32(dynamic raw);

  @protected
  BigInt dco_decode_u_64(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  UpdateInfo dco_decode_update_info(dynamic raw);

  @protected
  BigInt dco_decode_usize(dynamic raw);

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer);

  @protected
  ImageScanError
  sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    SseDeserializer deserializer,
  );

  @protected
  ImageScanError
  sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    SseDeserializer deserializer,
  );

  @protected
  RustStreamSink<DownloadEvent> sse_decode_StreamSink_download_event_Sse(
    SseDeserializer deserializer,
  );

  @protected
  RustStreamSink<ImageInfo> sse_decode_StreamSink_image_info_Sse(
    SseDeserializer deserializer,
  );

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  DownloadProgress sse_decode_box_autoadd_download_progress(
    SseDeserializer deserializer,
  );

  @protected
  UpdateInfo sse_decode_box_autoadd_update_info(SseDeserializer deserializer);

  @protected
  DownloadEvent sse_decode_download_event(SseDeserializer deserializer);

  @protected
  DownloadProgress sse_decode_download_progress(SseDeserializer deserializer);

  @protected
  double sse_decode_f_32(SseDeserializer deserializer);

  @protected
  double sse_decode_f_64(SseDeserializer deserializer);

  @protected
  ImageInfo sse_decode_image_info(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  UpdateInfo? sse_decode_opt_box_autoadd_update_info(
    SseDeserializer deserializer,
  );

  @protected
  int sse_decode_u_32(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  UpdateInfo sse_decode_update_info(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  void sse_encode_AnyhowException(
    AnyhowException self,
    SseSerializer serializer,
  );

  @protected
  void
  sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    ImageScanError self,
    SseSerializer serializer,
  );

  @protected
  void
  sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    ImageScanError self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_StreamSink_download_event_Sse(
    RustStreamSink<DownloadEvent> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_StreamSink_image_info_Sse(
    RustStreamSink<ImageInfo> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_download_progress(
    DownloadProgress self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_update_info(
    UpdateInfo self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_download_event(DownloadEvent self, SseSerializer serializer);

  @protected
  void sse_encode_download_progress(
    DownloadProgress self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_f_32(double self, SseSerializer serializer);

  @protected
  void sse_encode_f_64(double self, SseSerializer serializer);

  @protected
  void sse_encode_image_info(ImageInfo self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
    Uint8List self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_opt_box_autoadd_update_info(
    UpdateInfo? self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_update_info(UpdateInfo self, SseSerializer serializer);

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire implements BaseWire {
  factory RustLibWire.fromExternalLibrary(ExternalLibrary lib) =>
      RustLibWire(lib.ffiDynamicLibrary);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RustLibWire(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;

  void
  rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
      ptr,
    );
  }

  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanErrorPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
        'frbgen_Flutter_Image_Browser_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError',
      );
  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError =
      _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanErrorPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void
  rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError(
      ptr,
    );
  }

  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanErrorPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
        'frbgen_Flutter_Image_Browser_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError',
      );
  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanError =
      _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerImageScanErrorPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();
}
