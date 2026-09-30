import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> downloadFileImpl(String text, String filename) async {
  try {
    final bytes = utf8.encode(text);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    // Fallback if anything goes wrong
    await Clipboard.setData(ClipboardData(text: text));
  }
}
