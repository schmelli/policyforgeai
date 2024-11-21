import 'dart:convert';
import 'dart:html' as html;

class SettingsExportServiceWeb {
  static Future<void> writeFile(String path, String content) async {
    try {
      // Create blob
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create download link
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', path.split('/').last)
        ..style.display = 'none';

      // Add to document, click, and remove
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  static Future<String> readFile(String path) async {
    try {
      // For web, the path is actually the file content from FilePicker
      return path;
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }
}
