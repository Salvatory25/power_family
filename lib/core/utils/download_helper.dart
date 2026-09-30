import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_io.dart';

Future<void> downloadTextFile(String text, String filename) async {
  await downloadFileImpl(text, filename);
}
