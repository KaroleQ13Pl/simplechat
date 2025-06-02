import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController
  textController; // Controller for the text input field
  final VoidCallback onSend; // Callback function to handle sending messages

  const ChatInputField({
    super.key,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(64.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 12, 134, 114),
                    width: 5.0,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(64.0),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 12, 134, 114),
                    width: 2.0,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                hintText: "Wpisz wiadomość",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 12, 134, 114),
              borderRadius: BorderRadius.circular(64.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: Colors.white,
              onPressed: () {
                onSend();
              },
            ),
          ),
        ],
      ),
    );
  }
}
