//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:connectivity_plus_web/connectivity_plus_web.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:printing/printing_web.dart';
import 'package:syncfusion_flutter_pdfviewer_web/pdfviewer_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  ConnectivityPlusPlugin.registerWith(registrar);
  FilePickerWeb.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  PrintingPlugin.registerWith(registrar);
  SyncfusionFlutterPdfViewerPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
