import 'package:equatable/equatable.dart';

/// Represents a user in the system
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final List<String> teams;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.teams,
    required this.preferences,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        role,
        teams,
        preferences,
        createdAt,
        lastLoginAt,
        isActive,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'teams': teams,
        'preferences': preferences.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
        'isActive': isActive,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.viewer,
      ),
      teams: (json['teams'] as List<dynamic>).map((e) => e as String).toList(),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  User copyWith({
    String? displayName,
    UserRole? role,
    List<String>? teams,
    UserPreferences? preferences,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      teams: teams ?? this.teams,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// User roles in the system
enum UserRole {
  admin,
  manager,
  editor,
  reviewer,
  viewer,
}

/// User preferences for customizing their experience
class UserPreferences extends Equatable {
  final String theme;
  final String locale;
  final bool enableNotifications;
  final NotificationPreferences notifications;
  final EditorPreferences editor;
  final AIPreferences ai;

  const UserPreferences({
    required this.theme,
    required this.locale,
    required this.enableNotifications,
    required this.notifications,
    required this.editor,
    required this.ai,
  });

  factory UserPreferences.defaults() {
    return UserPreferences(
      theme: 'light',
      locale: 'en',
      enableNotifications: true,
      notifications: NotificationPreferences.defaults(),
      editor: EditorPreferences.defaults(),
      ai: AIPreferences.defaults(),
    );
  }

  @override
  List<Object?> get props => [
        theme,
        locale,
        enableNotifications,
        notifications,
        editor,
        ai,
      ];

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'locale': locale,
        'enableNotifications': enableNotifications,
        'notifications': notifications.toJson(),
        'editor': editor.toJson(),
        'ai': ai.toJson(),
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String? ?? 'light',
      locale: json['locale'] as String? ?? 'en',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      notifications: json['notifications'] != null
          ? NotificationPreferences.fromJson(json['notifications'] as Map<String, dynamic>)
          : NotificationPreferences.defaults(),
      editor: json['editor'] != null
          ? EditorPreferences.fromJson(json['editor'] as Map<String, dynamic>)
          : EditorPreferences.defaults(),
      ai: json['ai'] != null
          ? AIPreferences.fromJson(json['ai'] as Map<String, dynamic>)
          : AIPreferences.defaults(),
    );
  }
}

/// Notification preferences
class NotificationPreferences extends Equatable {
  final bool documentUpdates;
  final bool comments;
  final bool mentions;
  final bool reviews;
  final bool systemUpdates;
  final String notificationMethod; // 'email', 'push', 'both'

  const NotificationPreferences({
    required this.documentUpdates,
    required this.comments,
    required this.mentions,
    required this.reviews,
    required this.systemUpdates,
    required this.notificationMethod,
  });

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      documentUpdates: true,
      comments: true,
      mentions: true,
      reviews: true,
      systemUpdates: true,
      notificationMethod: 'both',
    );
  }

  @override
  List<Object?> get props => [
        documentUpdates,
        comments,
        mentions,
        reviews,
        systemUpdates,
        notificationMethod,
      ];

  Map<String, dynamic> toJson() => {
        'documentUpdates': documentUpdates,
        'comments': comments,
        'mentions': mentions,
        'reviews': reviews,
        'systemUpdates': systemUpdates,
        'notificationMethod': notificationMethod,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      documentUpdates: json['documentUpdates'] as bool? ?? true,
      comments: json['comments'] as bool? ?? true,
      mentions: json['mentions'] as bool? ?? true,
      reviews: json['reviews'] as bool? ?? true,
      systemUpdates: json['systemUpdates'] as bool? ?? true,
      notificationMethod: json['notificationMethod'] as String? ?? 'both',
    );
  }
}

/// Editor preferences
class EditorPreferences extends Equatable {
  final String fontFamily;
  final double fontSize;
  final bool lineNumbers;
  final bool spellCheck;
  final bool autoSave;
  final int autoSaveInterval;
  final bool darkMode;
  final Map<String, dynamic> keyBindings;

  const EditorPreferences({
    required this.fontFamily,
    required this.fontSize,
    required this.lineNumbers,
    required this.spellCheck,
    required this.autoSave,
    required this.autoSaveInterval,
    required this.darkMode,
    required this.keyBindings,
  });

  factory EditorPreferences.defaults() {
    return const EditorPreferences(
      fontFamily: 'Inter',
      fontSize: 14,
      lineNumbers: true,
      spellCheck: true,
      autoSave: true,
      autoSaveInterval: 30,
      darkMode: false,
      keyBindings: {},
    );
  }

  @override
  List<Object?> get props => [
        fontFamily,
        fontSize,
        lineNumbers,
        spellCheck,
        autoSave,
        autoSaveInterval,
        darkMode,
        keyBindings,
      ];

  Map<String, dynamic> toJson() => {
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'lineNumbers': lineNumbers,
        'spellCheck': spellCheck,
        'autoSave': autoSave,
        'autoSaveInterval': autoSaveInterval,
        'darkMode': darkMode,
        'keyBindings': keyBindings,
      };

  factory EditorPreferences.fromJson(Map<String, dynamic> json) {
    return EditorPreferences(
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
      lineNumbers: json['lineNumbers'] as bool? ?? true,
      spellCheck: json['spellCheck'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 30,
      darkMode: json['darkMode'] as bool? ?? false,
      keyBindings: Map<String, dynamic>.from(json['keyBindings'] as Map? ?? {}),
    );
  }
}

/// AI feature preferences
class AIPreferences extends Equatable {
  final bool enableSuggestions;
  final bool enableAnalysis;
  final bool enableAutoComplete;
  final Map<String, bool> enabledFeatures;
  final Map<String, dynamic> customSettings;

  const AIPreferences({
    required this.enableSuggestions,
    required this.enableAnalysis,
    required this.enableAutoComplete,
    required this.enabledFeatures,
    required this.customSettings,
  });

  factory AIPreferences.defaults() {
    return const AIPreferences(
      enableSuggestions: true,
      enableAnalysis: true,
      enableAutoComplete: true,
      enabledFeatures: {
        'writingSuggestions': true,
        'contentAnalysis': true,
        'structureAnalysis': true,
        'glossaryGeneration': true,
        'complianceChecking': true,
        'sentimentAnalysis': true,
        'readabilityAnalysis': true,
        'phrasingAlternatives': true,
      },
      customSettings: {},
    );
  }

  @override
  List<Object?> get props => [
        enableSuggestions,
        enableAnalysis,
        enableAutoComplete,
        enabledFeatures,
        customSettings,
      ];

  Map<String, dynamic> toJson() => {
        'enableSuggestions': enableSuggestions,
        'enableAnalysis': enableAnalysis,
        'enableAutoComplete': enableAutoComplete,
        'enabledFeatures': enabledFeatures,
        'customSettings': customSettings,
      };

  factory AIPreferences.fromJson(Map<String, dynamic> json) {
    return AIPreferences(
      enableSuggestions: json['enableSuggestions'] as bool? ?? true,
      enableAnalysis: json['enableAnalysis'] as bool? ?? true,
      enableAutoComplete: json['enableAutoComplete'] as bool? ?? true,
      enabledFeatures: Map<String, bool>.from(json['enabledFeatures'] as Map? ?? {}),
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? {}),
    );
  }
}
