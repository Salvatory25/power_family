import 'package:flutter/services.dart';

Future<void> downloadFileImpl(String text, String filename) async {
  // Mobile/Desktop fallback without file access plugins
  await Clipboard.setData(ClipboardData(text: text));
}
