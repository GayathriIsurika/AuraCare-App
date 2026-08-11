import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles all communication with the Gemini API for the AuraCare chatbot.
/// Keeps a running ChatSession so the model remembers conversation context.
class GeminiService {
  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found. Make sure .env is loaded and contains the key.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are AuraCare, a friendly and cautious health assistant inside '
            'a personal medical records app. Give clear, simple, general health '
            'information in plain language suitable for a mobile chat bubble. '
            'Keep answers concise (a few short sentences or a short list) unless '
            'the user asks for more detail.\n\n'
            'Only include a "not a doctor, consult a professional" reminder when '
            'it is genuinely relevant — e.g. the user is asking about a specific '
            'symptom, diagnosis, medication, dosage, or treatment decision. Do '
            'NOT repeat this reminder on every message; skip it entirely for '
            'greetings, small talk, thanks, general wellness tips (sleep, '
            'hydration, exercise, nutrition basics), or follow-up messages in '
            'the same conversation where you already gave the reminder recently. '
            'When you do include it, keep it to one short sentence, not a full '
            'paragraph.\n\n'
            'If the user describes a medical emergency, tell them to use the '
            'app\'s Emergency SOS feature or call local emergency services '
            'immediately, rather than continuing the conversation normally.\n\n'
            'Formatting style: write using Markdown. Always put a blank line '
            'before starting a bulleted list, and use "-" for each bullet '
            'point. Use **bold** for key terms. Start your reply with one '
            'relevant emoji that matches the topic (e.g. 😴 for sleep, 💧 for '
            'hydration, 🩺 for general health, 🍎 for nutrition, 🏃 for '
            'exercise), and use a couple of small emojis inline where they add '
            'clarity — but do not overdo it or use more than 3-4 emojis total '
            'in a response. Keep formatting clean and easy to scan on a small '
            'phone screen.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );

    _chat = _model.startChat();
  }

  /// Sends a message and returns Gemini's reply as plain text.
  /// Never throws — returns a user-friendly error string on failure.
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return "I couldn't come up with a response for that. Could you rephrase?";
      }
      return text.trim();
    } on GenerativeAIException catch (e) {
      return "AuraCare is having trouble connecting right now (${e.message}). Please try again in a moment.";
    } catch (e) {
      return "Something went wrong while getting a response. Please check your connection and try again.";
    }
  }

  /// Clears conversation history and starts a fresh chat session.
  void resetChat() {
    _chat = _model.startChat();
  }
}