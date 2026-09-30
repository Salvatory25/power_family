import 'package:flutter/services.dart';
import 'dart:typed_data';

Future<void> downloadFileImpl(String text, String filename) async {
  await Clipboard.setData(ClipboardData(text: text));
}

Future<void> downloadBytesImpl(Uint8List bytes, String filename) async {
  // Mobile fallback without file access plugins - not much we can do without share_plus or path_provider.
  // In a real app we would use path_provider to save the bytes and then open it.
}
