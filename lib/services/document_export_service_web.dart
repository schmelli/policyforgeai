import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

class DocumentExportServiceWeb {
  static Future<void> writeFile(String path, String content) async {
    try {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      _downloadBlob(blob, path);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  static Future<void> writeBinaryFile(String path, List<int> bytes) async {
    try {
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      _downloadBlob(blob, path);
    } catch (e) {
      throw Exception('Failed to write binary file: $e');
    }
  }

  static void _downloadBlob(html.Blob blob, String fileName) {
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName.split('/').last)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
