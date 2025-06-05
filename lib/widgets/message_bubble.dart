import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplechat/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUserMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUserMessage,
  });
  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat('HH:mm').format(message.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isCurrentUserMessage
            ? const Color.fromARGB(255, 12, 134, 114)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: isCurrentUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: isCurrentUserMessage ? Colors.white : Colors.black,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5.0), // Trochę większy odstęp
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 10.0,
              color: isCurrentUserMessage
                  ? Colors.white.withOpacity(
                      0.7,
                    ) // Lepsza czytelność na ciemnym tle
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
