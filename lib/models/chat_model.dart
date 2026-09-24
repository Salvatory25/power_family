import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  
  final String? propertyId;
  final String? branchId;
  
  // These will be populated locally or via a join view
  final String? otherParticipantName;
  final String? otherParticipantAvatar;
  final String? otherParticipantRole;

  ChatModel({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.propertyId,
    this.branchId,
    this.otherParticipantName,
    this.otherParticipantAvatar,
    this.otherParticipantRole,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    // Determine the "other" participant if we have a current user ID
    String? otherName;
    String? otherAvatar;
    String? otherRole;
    
    // Support if we used a view that joins profiles
    if (map['other_name'] != null) otherName = map['other_name'];
    if (map['other_avatar'] != null) otherAvatar = map['other_avatar'];
    if (map['other_role'] != null) otherRole = map['other_role'];

    return ChatModel(
      id: map['id'] ?? '',
      participant1Id: map['participant1_id'] ?? '',
      participant2Id: map['participant2_id'] ?? '',
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
      lastMessage: map['last_message'],
      lastMessageAt: map['last_message_at'] != null ? _parseDate(map['last_message_at']) : null,
      propertyId: map['property_id'],
      branchId: map['branch_id'],
      otherParticipantName: otherName,
      otherParticipantAvatar: otherAvatar,
      otherParticipantRole: otherRole,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant1_id': participant1Id,
      'participant2_id': participant2Id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'property_id': propertyId,
      'branch_id': branchId,
    };
  }

  ChatModel copyWith({
    String? id,
    String? participant1Id,
    String? participant2Id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? otherParticipantName,
    String? otherParticipantAvatar,
    String? otherParticipantRole,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      otherParticipantName: otherParticipantName ?? this.otherParticipantName,
      otherParticipantAvatar: otherParticipantAvatar ?? this.otherParticipantAvatar,
      otherParticipantRole: otherParticipantRole ?? this.otherParticipantRole,
    );
  }
}
