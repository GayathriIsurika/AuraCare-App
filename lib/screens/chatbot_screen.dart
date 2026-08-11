import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message_model.dart';
import '../constant/app_colors.dart';
import 'package:auracare_app/services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  bool _chatStarted = false;
  bool _isBotTyping = false;

  // This runs when user presses the send button
  // NOTE: marked `async` because it uses `await` inside for the Gemini call
  void _sendMessage() async {
    final text = _controller.text.trim();

    // Don't send if message is empty
    if (text.isEmpty) return;

    // Add the user's message to the list
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear(); // clear the text field
      _isBotTyping = true;
    });

    // Scroll down to show the new message
    _scrollToBottom();

    // Call Gemini and wait for the reply
    final reply = await _geminiService.sendMessage(text);

    if (!mounted) return; // widget could be disposed while awaiting
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _isBotTyping = false;
    });
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

  // Chat screen (after user starts chatting)
  Widget _buildChatView() {
    // include 1 extra slot for the typing bubble when the bot is "typing"
    final itemCount = _messages.length + (_isBotTyping ? 1 : 0);

    return Column(
      children: [
        // Message bubbles list (takes up all available space)
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // last item = typing indicator, shown only while _isBotTyping
              if (_isBotTyping && index == _messages.length) {
                return _buildTypingBubble();
              }
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
        child: isUser
            ? Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        )
            : MarkdownBody(
          data: message.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: textDark, fontSize: 15, height: 1.4),
            strong: const TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            listBullet: const TextStyle(color: textDark, fontSize: 15),
            h1: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            h2: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Simple typing indicator bubble shown while waiting for Gemini's reply
  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          '...',
          style: TextStyle(color: textDark, fontSize: 18),
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
              onSubmitted: (_) => _sendMessage(),
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

          // Send button — disabled while waiting for a reply
          CircleAvatar(
            backgroundColor: buttonColor,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isBotTyping ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}