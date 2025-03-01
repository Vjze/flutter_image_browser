// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.8.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';


            // These functions are ignored because they are not marked as `pub`: `get_image_info`, `is_image_file`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `SCAN_PROGRESS`, `SHOULD_STOP`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `deref`, `deref`, `fmt`, `initialize`, `initialize`


            String  getPath() => RustLib.instance.api.crateApiSimpleGetPath();

Future<int>  scanImages({required String p }) => RustLib.instance.api.crateApiSimpleScanImages(p: p);

Stream<ImageInfo>  listImages({required String p , required int l }) => RustLib.instance.api.crateApiSimpleListImages(p: p, l: l);

void  stopScan() => RustLib.instance.api.crateApiSimpleStopScan();

Future<double>  getScanProgress() => RustLib.instance.api.crateApiSimpleGetScanProgress();

            class ImageInfo  {
                final String path;
final String name;
final int width;
final int height;

                const ImageInfo({required this.path ,required this.name ,required this.width ,required this.height ,});

                
                

                
        @override
        int get hashCode => path.hashCode^name.hashCode^width.hashCode^height.hashCode;
        

                
        @override
        bool operator ==(Object other) =>
            identical(this, other) ||
            other is ImageInfo &&
                runtimeType == other.runtimeType
                && path == other.path&& name == other.name&& width == other.width&& height == other.height;
        
            }
            