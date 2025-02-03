import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:path/path.dart' as path;

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = (!_isOnDesktopAndWeb)
        ? Directory('/storage/emulated/0/Documents/Food Planner/Invoice')
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final types = {".pdf": "application/pdf", ".dwg": "application/x-autocad"};
    final url = file.path;
    final extension = path.extension(url);
    // await OpenFile.open(url);
    await OpenFile.open(url, type: types[extension]);
  }

  static bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}
