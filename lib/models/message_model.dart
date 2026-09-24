import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  
  // Local only
  final bool isMe;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.isMe = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final senderId = map['sender_id'] ?? '';
    
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chat_id'] ?? '',
      senderId: senderId,
      content: map['content'] ?? '',
      isRead: map['is_read'] ?? false,
      createdAt: _parseDate(map['created_at']),
      isMe: currentUserId != null && senderId == currentUserId,
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
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
