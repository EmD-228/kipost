/// Modèle de données pour les messages de chat (Supabase)
class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'file'
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final bool isRead;
  final DateTime createdAt;

  // Relations
  final Map<String, dynamic>? sender;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.isRead = false,
    required this.createdAt,
    this.sender,
  });

  /// Vérifie si c'est un message texte
  bool get isTextMessage => type == 'text';

  /// Vérifie si c'est un message image
  bool get isImageMessage => type == 'image';

  /// Vérifie si c'est un message fichier
  bool get isFileMessage => type == 'file';

  /// Factory constructor depuis une Map (Supabase)
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'],
      conversationId: map['conversation_id'],
      senderId: map['sender_id'],
      content: map['content'] ?? '',
      type: map['type'] ?? 'text',
      fileUrl: map['file_url'],
      fileName: map['file_name'],
      fileType: map['file_type'],
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      sender: map['sender'],
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'is_read': isRead,
    };
  }

  /// Copie avec modifications
  ChatMessageModel copyWith({
    String? content,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content ?? this.content,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      sender: sender,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, type: $type, senderId: $senderId, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modèle de données pour les conversations (Supabase)
class ConversationModel {
  final String id;
  final String contractId;
  final String clientId;
  final String providerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? contract;

  ConversationModel({
    required this.id,
    required this.contractId,
    required this.clientId,
    required this.providerId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.provider,
    this.contract,
  });

  /// Vérifie s'il y a des messages non lus
  bool get hasUnreadMessages => unreadCount > 0;

  /// Factory constructor depuis une Map (Supabase)
  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'],
      contractId: map['contract_id'],
      clientId: map['client_id'],
      providerId: map['provider_id'],
      lastMessage: map['last_message'],
      lastMessageAt: map['last_message_at'] != null 
          ? DateTime.parse(map['last_message_at']) 
          : null,
      unreadCount: map['unread_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      client: map['client'],
      provider: map['provider'],
      contract: map['contract'],
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'contract_id': contractId,
      'client_id': clientId,
      'provider_id': providerId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  /// Copie avec modifications
  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id,
      contractId: contractId,
      clientId: clientId,
      providerId: providerId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      client: client,
      provider: provider,
      contract: contract,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, contractId: $contractId, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
