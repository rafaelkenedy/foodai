enum MessageRole { user, assistant, system }

enum MessageType { text, image, textWithImage }

class Message {
  final MessageRole role;
  final String content;
  final MessageType messageType;
  final String? imageUrl;
  final DateTime timestamp;

  Message({
    required this.role,
    required this.content,
    this.messageType = MessageType.text,
    this.imageUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] ?? '',
      messageType: MessageType.values.firstWhere(
        (e) => e.name == (json['message_type'] ?? 'text').replaceAll('_', ''),
        orElse: () => MessageType.text,
      ),
      imageUrl: json['image_url'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
      'message_type': messageType.name,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
