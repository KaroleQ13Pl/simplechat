import 'package:flutter/material.dart';
import 'package:simplechat/models/message.dart';
import 'package:simplechat/widgets/chat_input_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController = ScrollController();

  TextEditingController _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // MEssage list to display in the chat
  void _handleSendMessage() {
    final String text = _textController.text;
    if (text.isNotEmpty) {
      final Message newMessage = Message(
        text: text,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'user',
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(newMessage);
      });
      _textController.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  List<Message> _messages = [
    Message(
      text: 'Witaj w SimpleChat!',
      messageId: '1',
      senderId: 'system',
      timestamp: DateTime.now(),
    ),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, index) {
                  final Message message = _messages[index];
                  final bool isUserMessage = message.senderId == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? const Color.fromARGB(255, 12, 134, 114)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(message.text),
                    ),
                  );
                },
              ),
            ),
            ChatInputField(
              textController: _textController,
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
