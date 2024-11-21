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
}
