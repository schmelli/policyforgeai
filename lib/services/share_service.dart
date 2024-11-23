import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharePermission {
  view,
  comment,
  edit,
}

class ShareLink {
  final String id;
  final String documentId;
  final String projectId;
  final SharePermission permission;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String createdBy;
  final bool isActive;

  ShareLink({
    required this.id,
    required this.documentId,
    required this.projectId,
    required this.permission,
    required this.createdAt,
    this.expiresAt,
    required this.createdBy,
    this.isActive = true,
  });

  factory ShareLink.fromJson(Map<String, dynamic> json) {
    return ShareLink(
      id: json['id'],
      documentId: json['documentId'],
      projectId: json['projectId'],
      permission: SharePermission.values.byName(json['permission']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      createdBy: json['createdBy'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'documentId': documentId,
        'projectId': projectId,
        'permission': permission.name,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'createdBy': createdBy,
        'isActive': isActive,
      };

  String get shareUrl =>
      '/share/${base64Url.encode(utf8.encode(jsonEncode(toJson())))}';
}

class ShareService {
  static Future<ShareLink> createShareLink({
    required String documentId,
    required String projectId,
    required SharePermission permission,
    required String createdBy,
    DateTime? expiresAt,
  }) async {
    final id = _generateShareId();
    final link = ShareLink(
      id: id,
      documentId: documentId,
      projectId: projectId,
      permission: permission,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      createdBy: createdBy,
    );

    await _saveShareLink(link);
    return link;
  }

  static Future<ShareLink?> getShareLink(String id) async {
    final link = await _loadShareLink(id);
    if (link == null) return null;

    // Check if link is expired
    if (link.expiresAt != null && link.expiresAt!.isBefore(DateTime.now())) {
      await _deactivateShareLink(id);
      return null;
    }

    // Check if link is active
    if (!link.isActive) return null;

    return link;
  }

  static Future<List<ShareLink>> getDocumentShareLinks(String documentId) async {
    final links = await _loadDocumentShareLinks(documentId);
    return links.where((link) {
      if (!link.isActive) return false;
      if (link.expiresAt != null && link.expiresAt!.isBefore(DateTime.now())) {
        _deactivateShareLink(link.id);
        return false;
      }
      return true;
    }).toList();
  }

  static Future<void> deactivateShareLink(String id) async {
    await _deactivateShareLink(id);
  }

  static Future<ShareLink?> parseShareUrl(String url) async {
    try {
      final encoded = url.split('/share/')[1];
      final decoded = utf8.decode(base64Url.decode(encoded));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return ShareLink.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static String _generateShareId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode('$timestamp:$random')).toString();
    return hash.substring(0, 16);
  }

  static Future<void> _saveShareLink(ShareLink link) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save link by ID
    await prefs.setString('share_link_${link.id}', jsonEncode(link.toJson()));
    
    // Add to document's share links list
    final docLinks = await _loadDocumentShareLinks(link.documentId);
    docLinks.add(link);
    await prefs.setString(
      'doc_share_links_${link.documentId}',
      jsonEncode(docLinks.map((l) => l.toJson()).toList()),
    );
  }

  static Future<ShareLink?> _loadShareLink(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final linkJson = prefs.getString('share_link_$id');
    if (linkJson == null) return null;
    
    return ShareLink.fromJson(jsonDecode(linkJson));
  }

  static Future<List<ShareLink>> _loadDocumentShareLinks(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final linksJson = prefs.getString('doc_share_links_$documentId');
    if (linksJson == null) return [];
    
    final List<dynamic> linksList = jsonDecode(linksJson);
    return linksList
        .map((json) => ShareLink.fromJson(json))
        .where((link) => link.isActive)
        .toList();
  }

  static Future<void> _deactivateShareLink(String id) async {
    final link = await _loadShareLink(id);
    if (link == null) return;
    
    final updatedLink = ShareLink(
      id: link.id,
      documentId: link.documentId,
      projectId: link.projectId,
      permission: link.permission,
      createdAt: link.createdAt,
      expiresAt: link.expiresAt,
      createdBy: link.createdBy,
      isActive: false,
    );
    
    await _saveShareLink(updatedLink);
  }
}
