import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../constant/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];

  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _chatStarted = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // This runs when user presses the send button
  void _sendMessage() {
    final text = _controller.text.trim();

    // Don't send if message is empty
    if (text.isEmpty) return;

    // Add the user's message to the list
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear(); // clear the text field
    });

    // Scroll down to show the new message
    _scrollToBottom();

    // Wait a moment then show bot reply
    Future.delayed(const Duration(milliseconds: 800), () {
      _getBotReply(text);
    });
  }

  // This generates a simple bot reply
  void _getBotReply(String userMessage) {
    String reply;

    final msg = userMessage.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi')) {
      reply = 'Hello! 👋 How can I help you today?';
    } else if (msg.contains('appointment')) {
      reply =
          'I can help you book an appointment! Please go to the appointments section.';
    } else if (msg.contains('doctor')) {
      reply =
          'You can find doctors in the Health Directory section of the app!';
    } else if (msg.contains('emergency')) {
      reply =
          '🚨 If this is an emergency please use the SOS button immediately!';
    } else if (msg.contains('reminder')) {
      reply = 'You can set medication reminders in the Reminders section!';
    } else if (msg.contains('thank')) {
      reply = 'You are welcome! 😊 Is there anything else I can help you with?';
    } else {
      reply =
          'I understand you are asking about "$userMessage". Please consult a medical professional for accurate advice.';
    }

    // Add the bot reply to the message list
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
    });

    // Scroll down to show the bot reply
    _scrollToBottom();
  }

  // Scrolls the chat to the latest message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Bottom bar with microphone button (matches Image 1)
  Widget _buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Grid icon on the left
          IconButton(
            icon: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {},
          ),

          // Microphone button in the center
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.mic, color: buttonColor, size: 28),
          ),

          // Keyboard icon on the right
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white, size: 26),
            onPressed: () {
              // When keyboard icon is pressed, start chat
              setState(() {
                _chatStarted = true;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(backgroundColor: background, elevation: 0),
      body: _chatStarted ? _buildChatView() : _buildWelcomeView(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Welcome screen

  Widget _buildWelcomeView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Greeting Text
            const Text(
              "Hello\nI'm AuraCare",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),

            const SizedBox(height: 100),

            Image.asset('assets/images/robot.png', height: 150),

            const SizedBox(height: 30),

            // Subtitle text
            const Text(
              'How can I help you?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: textDark),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _chatStarted = true; // switches to chat screen
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'I want to know',
                style: TextStyle(color: buttonText, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chat screen
  // Chat screen (after user starts chatting)
  Widget _buildChatView() {
    return Column(
      children: [
        // Message bubbles list (takes up all available space)
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        // Text input bar at the bottom
        _buildInputBar(),
      ],
    );
  }

  // Each individual message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? buttonColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? buttonText : textDark, fontSize: 15),
        ),
      ),
    );
  }

  // Text input bar at the bottom
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: textGrey),
                filled: true,
                fillColor: background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send button
          CircleAvatar(
            backgroundColor: buttonColor,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
