// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.8.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/check_version.dart';
import 'api/simple.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'frb_generated.io.dart'
    if (dart.library.js_interop) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Initialize flutter_rust_bridge in mock mode.
  /// No libraries for FFI are loaded.
  static void initMock({required RustLibApi api}) {
    instance.initMockImpl(api: api);
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiSimpleInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.8.0';

  @override
  int get rustContentHash => 846163476;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
        stem: 'rust_lib_my_app',
        ioDirectory: 'rust/target/release/',
        webPrefix: 'pkg/',
      );
}

abstract class RustLibApi extends BaseApi {
  Future<UpdateInfo?> crateApiCheckVersionCheckUpdate();

  Stream<DownloadEvent> crateApiCheckVersionDownloadUpdate({
    required String url,
    required String fileName,
  });

  String crateApiSimpleGetPath();

  Future<double> crateApiSimpleGetScanProgress();

  Future<void> crateApiSimpleInitApp();

  Future<void> crateApiCheckVersionInstallUpdate({required String fileName});

  Stream<ImageInfo> crateApiSimpleListImages({
    required String p,
    required int l,
  });

  Future<void> crateApiCheckVersionRunInstaller({
    required String installerPath,
  });

  Future<int> crateApiSimpleScanImages({required String p});

  void crateApiSimpleStopScan();
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  Future<UpdateInfo?> crateApiCheckVersionCheckUpdate() {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 1,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_opt_box_autoadd_update_info,
          decodeErrorData: sse_decode_AnyhowException,
        ),
        constMeta: kCrateApiCheckVersionCheckUpdateConstMeta,
        argValues: [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiCheckVersionCheckUpdateConstMeta =>
      const TaskConstMeta(debugName: "check_update", argNames: []);

  @override
  Stream<DownloadEvent> crateApiCheckVersionDownloadUpdate({
    required String url,
    required String fileName,
  }) {
    final progressSink = RustStreamSink<DownloadEvent>();
    unawaited(
      handler.executeNormal(
        NormalTask(
          callFfi: (port_) {
            final serializer = SseSerializer(generalizedFrbRustBinding);
            sse_encode_String(url, serializer);
            sse_encode_String(fileName, serializer);
            sse_encode_StreamSink_download_event_Sse(progressSink, serializer);
            pdeCallFfi(
              generalizedFrbRustBinding,
              serializer,
              funcId: 2,
              port: port_,
            );
          },
          codec: SseCodec(
            decodeSuccessData: sse_decode_unit,
            decodeErrorData: sse_decode_AnyhowException,
          ),
          constMeta: kCrateApiCheckVersionDownloadUpdateConstMeta,
          argValues: [url, fileName, progressSink],
          apiImpl: this,
        ),
      ),
    );
    return progressSink.stream;
  }

  TaskConstMeta get kCrateApiCheckVersionDownloadUpdateConstMeta =>
      const TaskConstMeta(
        debugName: "download_update",
        argNames: ["url", "fileName", "progressSink"],
      );

  @override
  String crateApiSimpleGetPath() {
    return handler.executeSync(
      SyncTask(
        callFfi: () {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 3)!;
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_String,
          decodeErrorData: sse_decode_AnyhowException,
        ),
        constMeta: kCrateApiSimpleGetPathConstMeta,
        argValues: [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiSimpleGetPathConstMeta =>
      const TaskConstMeta(debugName: "get_path", argNames: []);

  @override
  Future<double> crateApiSimpleGetScanProgress() {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 4,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_f_32,
          decodeErrorData: null,
        ),
        constMeta: kCrateApiSimpleGetScanProgressConstMeta,
        argValues: [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiSimpleGetScanProgressConstMeta =>
      const TaskConstMeta(debugName: "get_scan_progress", argNames: []);

  @override
  Future<void> crateApiSimpleInitApp() {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 5,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: null,
        ),
        constMeta: kCrateApiSimpleInitAppConstMeta,
        argValues: [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiSimpleInitAppConstMeta =>
      const TaskConstMeta(debugName: "init_app", argNames: []);

  @override
  Future<void> crateApiCheckVersionInstallUpdate({required String fileName}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_String(fileName, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 6,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_AnyhowException,
        ),
        constMeta: kCrateApiCheckVersionInstallUpdateConstMeta,
        argValues: [fileName],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiCheckVersionInstallUpdateConstMeta =>
      const TaskConstMeta(debugName: "install_update", argNames: ["fileName"]);

  @override
  Stream<ImageInfo> crateApiSimpleListImages({
    required String p,
    required int l,
  }) {
    final sink = RustStreamSink<ImageInfo>();
    unawaited(
      handler.executeNormal(
        NormalTask(
          callFfi: (port_) {
            final serializer = SseSerializer(generalizedFrbRustBinding);
            sse_encode_String(p, serializer);
            sse_encode_u_32(l, serializer);
            sse_encode_StreamSink_image_info_Sse(sink, serializer);
            pdeCallFfi(
              generalizedFrbRustBinding,
              serializer,
              funcId: 7,
              port: port_,
            );
          },
          codec: SseCodec(
            decodeSuccessData: sse_decode_unit,
            decodeErrorData: sse_decode_AnyhowException,
          ),
          constMeta: kCrateApiSimpleListImagesConstMeta,
          argValues: [p, l, sink],
          apiImpl: this,
        ),
      ),
    );
    return sink.stream;
  }

  TaskConstMeta get kCrateApiSimpleListImagesConstMeta => const TaskConstMeta(
    debugName: "list_images",
    argNames: ["p", "l", "sink"],
  );

  @override
  Future<void> crateApiCheckVersionRunInstaller({
    required String installerPath,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_String(installerPath, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 8,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_AnyhowException,
        ),
        constMeta: kCrateApiCheckVersionRunInstallerConstMeta,
        argValues: [installerPath],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiCheckVersionRunInstallerConstMeta =>
      const TaskConstMeta(
        debugName: "run_installer",
        argNames: ["installerPath"],
      );

  @override
  Future<int> crateApiSimpleScanImages({required String p}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_String(p, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 9,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_u_32,
          decodeErrorData: sse_decode_AnyhowException,
        ),
        constMeta: kCrateApiSimpleScanImagesConstMeta,
        argValues: [p],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiSimpleScanImagesConstMeta =>
      const TaskConstMeta(debugName: "scan_images", argNames: ["p"]);

  @override
  void crateApiSimpleStopScan() {
    return handler.executeSync(
      SyncTask(
        callFfi: () {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 10)!;
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: null,
        ),
        constMeta: kCrateApiSimpleStopScanConstMeta,
        argValues: [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiSimpleStopScanConstMeta =>
      const TaskConstMeta(debugName: "stop_scan", argNames: []);

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return AnyhowException(raw as String);
  }

  @protected
  RustStreamSink<DownloadEvent> dco_decode_StreamSink_download_event_Sse(
    dynamic raw,
  ) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError();
  }

  @protected
  RustStreamSink<ImageInfo> dco_decode_StreamSink_image_info_Sse(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    throw UnimplementedError();
  }

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  DownloadProgress dco_decode_box_autoadd_download_progress(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_download_progress(raw);
  }

  @protected
  UpdateInfo dco_decode_box_autoadd_update_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_update_info(raw);
  }

  @protected
  DownloadEvent dco_decode_download_event(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    switch (raw[0]) {
      case 0:
        return DownloadEvent_Progress(
          dco_decode_box_autoadd_download_progress(raw[1]),
        );
      case 1:
        return DownloadEvent_Error(dco_decode_String(raw[1]));
      default:
        throw Exception("unreachable");
    }
  }

  @protected
  DownloadProgress dco_decode_download_progress(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 4)
      throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
    return DownloadProgress(
      downloadedBytes: dco_decode_u_64(arr[0]),
      totalBytes: dco_decode_u_64(arr[1]),
      speed: dco_decode_f_64(arr[2]),
      progress: dco_decode_f_64(arr[3]),
    );
  }

  @protected
  double dco_decode_f_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as double;
  }

  @protected
  double dco_decode_f_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as double;
  }

  @protected
  ImageInfo dco_decode_image_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 4)
      throw Exception('unexpected arr length: expect 4 but see ${arr.length}');
    return ImageInfo(
      path: dco_decode_String(arr[0]),
      name: dco_decode_String(arr[1]),
      width: dco_decode_usize(arr[2]),
      height: dco_decode_usize(arr[3]),
    );
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  UpdateInfo? dco_decode_opt_box_autoadd_update_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_update_info(raw);
  }

  @protected
  int dco_decode_u_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  BigInt dco_decode_u_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeU64(raw);
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  UpdateInfo dco_decode_update_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return UpdateInfo(
      version: dco_decode_String(arr[0]),
      changelog: dco_decode_String(arr[1]),
      downloadUrl: dco_decode_String(arr[2]),
      fileName: dco_decode_String(arr[3]),
      date: dco_decode_String(arr[4]),
    );
  }

  @protected
  BigInt dco_decode_usize(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeU64(raw);
  }

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_String(deserializer);
    return AnyhowException(inner);
  }

  @protected
  RustStreamSink<DownloadEvent> sse_decode_StreamSink_download_event_Sse(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    throw UnimplementedError('Unreachable ()');
  }

  @protected
  RustStreamSink<ImageInfo> sse_decode_StreamSink_image_info_Sse(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    throw UnimplementedError('Unreachable ()');
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  DownloadProgress sse_decode_box_autoadd_download_progress(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_download_progress(deserializer));
  }

  @protected
  UpdateInfo sse_decode_box_autoadd_update_info(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_update_info(deserializer));
  }

  @protected
  DownloadEvent sse_decode_download_event(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var tag_ = sse_decode_i_32(deserializer);
    switch (tag_) {
      case 0:
        var var_field0 = sse_decode_box_autoadd_download_progress(deserializer);
        return DownloadEvent_Progress(var_field0);
      case 1:
        var var_field0 = sse_decode_String(deserializer);
        return DownloadEvent_Error(var_field0);
      default:
        throw UnimplementedError('');
    }
  }

  @protected
  DownloadProgress sse_decode_download_progress(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_downloadedBytes = sse_decode_u_64(deserializer);
    var var_totalBytes = sse_decode_u_64(deserializer);
    var var_speed = sse_decode_f_64(deserializer);
    var var_progress = sse_decode_f_64(deserializer);
    return DownloadProgress(
      downloadedBytes: var_downloadedBytes,
      totalBytes: var_totalBytes,
      speed: var_speed,
      progress: var_progress,
    );
  }

  @protected
  double sse_decode_f_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getFloat32();
  }

  @protected
  double sse_decode_f_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getFloat64();
  }

  @protected
  ImageInfo sse_decode_image_info(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_path = sse_decode_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_width = sse_decode_usize(deserializer);
    var var_height = sse_decode_usize(deserializer);
    return ImageInfo(
      path: var_path,
      name: var_name,
      width: var_width,
      height: var_height,
    );
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  UpdateInfo? sse_decode_opt_box_autoadd_update_info(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_update_info(deserializer));
    } else {
      return null;
    }
  }

  @protected
  int sse_decode_u_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint32();
  }

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getBigUint64();
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  UpdateInfo sse_decode_update_info(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_version = sse_decode_String(deserializer);
    var var_changelog = sse_decode_String(deserializer);
    var var_downloadUrl = sse_decode_String(deserializer);
    var var_fileName = sse_decode_String(deserializer);
    var var_date = sse_decode_String(deserializer);
    return UpdateInfo(
      version: var_version,
      changelog: var_changelog,
      downloadUrl: var_downloadUrl,
      fileName: var_fileName,
      date: var_date,
    );
  }

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getBigUint64();
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  void sse_encode_AnyhowException(
    AnyhowException self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.message, serializer);
  }

  @protected
  void sse_encode_StreamSink_download_event_Sse(
    RustStreamSink<DownloadEvent> self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(
      self.setupAndSerialize(
        codec: SseCodec(
          decodeSuccessData: sse_decode_download_event,
          decodeErrorData: sse_decode_AnyhowException,
        ),
      ),
      serializer,
    );
  }

  @protected
  void sse_encode_StreamSink_image_info_Sse(
    RustStreamSink<ImageInfo> self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(
      self.setupAndSerialize(
        codec: SseCodec(
          decodeSuccessData: sse_decode_image_info,
          decodeErrorData: sse_decode_AnyhowException,
        ),
      ),
      serializer,
    );
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_box_autoadd_download_progress(
    DownloadProgress self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_download_progress(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_update_info(
    UpdateInfo self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_update_info(self, serializer);
  }

  @protected
  void sse_encode_download_event(DownloadEvent self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    switch (self) {
      case DownloadEvent_Progress(field0: final field0):
        sse_encode_i_32(0, serializer);
        sse_encode_box_autoadd_download_progress(field0, serializer);
      case DownloadEvent_Error(field0: final field0):
        sse_encode_i_32(1, serializer);
        sse_encode_String(field0, serializer);
    }
  }

  @protected
  void sse_encode_download_progress(
    DownloadProgress self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_u_64(self.downloadedBytes, serializer);
    sse_encode_u_64(self.totalBytes, serializer);
    sse_encode_f_64(self.speed, serializer);
    sse_encode_f_64(self.progress, serializer);
  }

  @protected
  void sse_encode_f_32(double self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putFloat32(self);
  }

  @protected
  void sse_encode_f_64(double self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putFloat64(self);
  }

  @protected
  void sse_encode_image_info(ImageInfo self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.path, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_usize(self.width, serializer);
    sse_encode_usize(self.height, serializer);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
    Uint8List self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_opt_box_autoadd_update_info(
    UpdateInfo? self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_update_info(self, serializer);
    }
  }

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint32(self);
  }

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putBigUint64(self);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_update_info(UpdateInfo self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.version, serializer);
    sse_encode_String(self.changelog, serializer);
    sse_encode_String(self.downloadUrl, serializer);
    sse_encode_String(self.fileName, serializer);
    sse_encode_String(self.date, serializer);
  }

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putBigUint64(self);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }
}
