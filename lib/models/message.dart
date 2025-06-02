class Message {
  final String text; // The content of the message
  final String messageId; // Unique identifier for the message
  final String senderId; // Unique identifier for the sender
  final DateTime timestamp; // Timestamp of when the message was sent
  final bool isRead; // Flag to indicate if the message has been read

  Message({
    required this.text,
    required this.messageId,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });
}
