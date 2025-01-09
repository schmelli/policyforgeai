/// Utility class for Markdown text operations
class MarkdownUtils {
  /// Wraps the selected text with the given prefix and suffix
  static String wrapSelection(String text, int start, int end, String prefix, [String? suffix]) {
    if (start == end) {
      // No selection, just insert the markers
      return text.substring(0, start) + prefix + (suffix ?? prefix) + text.substring(end);
    }

    final selectedText = text.substring(start, end);
    return text.substring(0, start) + prefix + selectedText + (suffix ?? prefix) + text.substring(end);
  }

  /// Add or remove heading level at the start of the line
  static String toggleHeading(String text, int start, int level) {
    final lines = text.split('\n');
    var currentPos = 0;
    var targetLineIndex = -1;

    // Find the line containing the cursor
    for (var i = 0; i < lines.length; i++) {
      if (currentPos <= start && start <= currentPos + lines[i].length) {
        targetLineIndex = i;
        break;
      }
      currentPos += lines[i].length + 1; // +1 for newline
    }

    if (targetLineIndex == -1) return text;

    var line = lines[targetLineIndex];
    final headingMarker = '#' * level + ' ';

    // Remove existing heading markers
    line = line.replaceFirst(RegExp(r'^#{1,6}\s+'), '');

    // Add new heading marker if it wasn't already at the desired level
    if (!text.substring(currentPos).startsWith(headingMarker)) {
      line = headingMarker + line;
    }

    lines[targetLineIndex] = line;
    return lines.join('\n');
  }

  /// Add or remove bullet point at the start of the line
  static String toggleBulletPoint(String text, int start) {
    final lines = text.split('\n');
    var currentPos = 0;
    var targetLineIndex = -1;

    // Find the line containing the cursor
    for (var i = 0; i < lines.length; i++) {
      if (currentPos <= start && start <= currentPos + lines[i].length) {
        targetLineIndex = i;
        break;
      }
      currentPos += lines[i].length + 1;
    }

    if (targetLineIndex == -1) return text;

    var line = lines[targetLineIndex];
    const bulletMarker = '- ';

    // Toggle bullet point
    if (line.startsWith(bulletMarker)) {
      line = line.substring(bulletMarker.length);
    } else {
      line = bulletMarker + line;
    }

    lines[targetLineIndex] = line;
    return lines.join('\n');
  }

  /// Add or remove numbered list item at the start of the line
  static String toggleNumberedList(String text, int start) {
    final lines = text.split('\n');
    var currentPos = 0;
    var targetLineIndex = -1;

    // Find the line containing the cursor
    for (var i = 0; i < lines.length; i++) {
      if (currentPos <= start && start <= currentPos + lines[i].length) {
        targetLineIndex = i;
        break;
      }
      currentPos += lines[i].length + 1;
    }

    if (targetLineIndex == -1) return text;

    var line = lines[targetLineIndex];
    
    // Check if line is already numbered
    final numberMatch = RegExp(r'^\d+\.\s+').firstMatch(line);
    if (numberMatch != null) {
      // Remove numbering
      line = line.substring(numberMatch.end);
    } else {
      // Add numbering (always start with 1)
      line = '1. ' + line;
    }

    lines[targetLineIndex] = line;
    return lines.join('\n');
  }
}
