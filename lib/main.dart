import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simplechat/models/message.dart';
import 'package:simplechat/widgets/chat_input_field.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

  void _handleSendMessage() async {
    // 1. Zmieniamy metodę na async
    final String text = _textController.text;
    if (text.isEmpty) {
      // Sprawdzamy, czy tekst nie jest pusty
      return; // Jeśli jest pusty, nic nie rób
    }

    // 2. Dodajemy wiadomość użytkownika do UI od razu
    final Message userMessage = Message(
      text: text,
      messageId:
          DateTime.now().millisecondsSinceEpoch.toString() +
          "_user", // Dodajemy _user dla unikalności
      senderId: 'user', // Identyfikator użytkownika
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage); // Dodajemy wiadomość użytkownika do listy
    });

    final String messageToSendToBackend =
        text; // Zapisujemy tekst przed wyczyszczeniem kontrolera
    _textController.clear(); // Czyścimy pole tekstowe
    FocusScope.of(context).unfocus(); // Opcjonalnie: ukrywamy klawiaturę

    // Opcjonalnie: Możesz dodać wskaźnik ładowania/pisania przez Gemini
    // np. dodając tymczasową wiadomość "Gemini pisze..." lub ustawiając flagę w stanie
    // setState(() { _isGeminiTyping = true; });

    try {
      // 3. Wywołanie Twojej funkcji Firebase Cloud Function
      final response = await http.post(
        Uri.parse('https://geminiproxy-vphgpojdyq-ew.a.run.app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'prompt':
              messageToSendToBackend, // Wysyłamy tekst wiadomości użytkownika jako "prompt"
        }),
      );

      // Opcjonalnie: Ukryj wskaźnik ładowania
      // setState(() { _isGeminiTyping = false; });

      if (response.statusCode == 200) {
        // Jeśli odpowiedź serwera jest OK (200)
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String geminiReply =
            data['reply'] ??
            'Nie udało się uzyskać odpowiedzi.'; // Odczytujemy odpowiedź z pola "reply"

        final Message geminiMessage = Message(
          text: geminiReply,
          messageId:
              "${DateTime.now().millisecondsSinceEpoch}_gemini", // Unikalne ID dla wiadomości Gemini
          senderId: 'gemini_bot', // Specjalny senderId dla Gemini
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(geminiMessage); // Dodajemy odpowiedź Gemini do listy
        });
      } else {
        // Jeśli serwer zwrócił błąd
        print(
          'Błąd odpowiedzi z backendu: ${response.statusCode} - ${response.body}',
        );
        final Message errorMessage = Message(
          text:
              'Przepraszam, wystąpił błąd serwera (${response.statusCode}). Spróbuj ponownie później.',
          messageId: "${DateTime.now().millisecondsSinceEpoch}_error",
          senderId: 'system', // Wiadomość systemowa o błędzie
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(errorMessage);
        });
      }
    } catch (e) {
      // Jeśli wystąpił błąd podczas samego zapytania HTTP (np. brak internetu)
      // Opcjonalnie: Ukryj wskaźnik ładowania
      // setState(() { _isGeminiTyping = false; });
      print('Błąd podczas wysyłania wiadomości do backendu: $e');
      final Message errorMessage = Message(
        text: 'Błąd połączenia. Sprawdź swoje połączenie z internetem.',
        messageId: "${DateTime.now().millisecondsSinceEpoch}_conn_error",
        senderId: 'system',
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(errorMessage);
      });
    }
  }

  final List<Message> _messages = [
    Message(
      text: 'Witaj w SimpleChat!',
      messageId: '1',
      senderId: 'system',
      timestamp: DateTime.now(),
    ),
  ];

  @override
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
                  final String formattedTime = DateFormat(
                    'HH:mm',
                  ).format(message.timestamp);

                  String initials = '';
                  Color avatarColor = Colors.grey;

                  if (message.senderId == 'user') {
                    initials =
                        'TY'; // Twoje Inicjały (lub np. z nazwy użytkownika)
                    avatarColor = const Color.fromARGB(
                      255,
                      12,
                      134,
                      114,
                    ); // Ten sam kolor co Twoje dymki
                  } else if (message.senderId == 'system') {
                    initials = 'S';
                    avatarColor = Colors.orange; // Inny kolor dla systemu
                  } else {
                    // Dla innych użytkowników (np. 'otherUser' jeśli taki masz)
                    initials = message.senderId.isNotEmpty
                        ? message.senderId[0].toUpperCase()
                        : '?'; // Pierwsza litera senderId
                    avatarColor = Colors.purple; // Jeszcze inny kolor
                  }
                  final avatar = CircleAvatar(
                    backgroundColor: avatarColor,
                    child: Text(
                      initials,
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                    radius: 16.0, // Rozmiar awatara
                  );

                  // Dymek wiadomości (ten sam co poprzednio)
                  final messageBubble = Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? const Color.fromARGB(255, 12, 134, 114)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: isUserMessage
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUserMessage ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: isUserMessage
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );

                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUserMessage) avatar,
                          const SizedBox(width: 2.0),
                          messageBubble,
                          if (isUserMessage) ...[
                            const SizedBox(width: 2.0),
                            avatar,
                          ],
                        ],
                      ),
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
