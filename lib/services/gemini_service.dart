import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles all communication with the Gemini API for the AuraCare chatbot.
/// Keeps a running ChatSession so the model remembers conversation context.
class GeminiService {
  late final GenerativeModel _model;
  late ChatSession _chat;

  // Separate model for one-shot document summarization — this does NOT use
  // chat history, since each report summary is an independent request.
  late final GenerativeModel _reportModel;

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

    _reportModel = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are AuraCare\'s medical report reader. You will be given a '
            'photo or PDF of a medical report, lab result, prescription, or '
            'imaging summary. Read the document carefully and produce a clear, '
            'patient-friendly summary using this exact Markdown structure:\n\n'
            '### 📋 Overview\n'
            'One or two sentences on what kind of report this is and when it '
            'appears to be from (if a date is visible).\n\n'
            '### 🔍 Key Findings\n'
            '- Bullet each important result, value, or diagnosis found in the '
            'document\n'
            '- Note if a value is flagged high/low/abnormal in the original '
            'report\n\n'
            '### 💬 In Simple Terms\n'
            'Explain the key findings in plain, everyday language a non-medical '
            'person can understand. Avoid unexplained jargon — if you must use '
            'a medical term, briefly define it in parentheses.\n\n'
            '### ✅ Suggested Next Steps\n'
            '- 1-3 short, general suggestions (e.g. "discuss this result with '
            'your doctor", "no action needed if you feel well", etc.)\n\n'
            'Rules:\n'
            '- Base your summary ONLY on what is actually visible in the '
            'document. Never invent values, names, or results that are not '
            'present.\n'
            '- If the document is unreadable, blurry, cropped, or not a '
            'medical report at all, say so clearly instead of guessing.\n'
            '- Always end with a short one-line reminder that this is an AI '
            'summary and the original report should be reviewed with a '
            'licensed doctor for medical decisions.\n'
            '- Do not diagnose new conditions beyond what is written in the '
            'report — only explain what is already there.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.3, // lower temperature: prioritize accuracy over creativity
        maxOutputTokens: 1024,
      ),
    );
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

  /// Sends a medical report (PDF or image) to Gemini and returns a
  /// structured, plain-language Markdown summary.
  ///
  /// [bytes] — raw file bytes (from file_picker, Firebase download, etc.)
  /// [mimeType] — e.g. 'application/pdf', 'image/jpeg', 'image/png'
  ///
  /// Never throws — returns a user-friendly error string on failure.
  Future<String> summarizeDocument({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    // Gemini's inline data limit is ~20MB per request.
    const maxBytes = 20 * 1024 * 1024;
    if (bytes.length > maxBytes) {
      return "⚠️ This file is too large to summarize (over 20MB). "
          "Please try a smaller file or a lower-resolution scan.";
    }

    try {
      final content = [
        Content.multi([
          TextPart(
            'Please read this medical report and summarize it following '
                'your instructions.',
          ),
          DataPart(mimeType, bytes),
        ]),
      ];

      final response = await _reportModel.generateContent(content);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        return "I couldn't read anything useful from this file. Please "
            "make sure it's a clear photo or PDF of the report and try again.";
      }
      return text.trim();
    } on GenerativeAIException catch (e) {
      return "AuraCare couldn't process this document right now (${e.message}). "
          "Please try again in a moment.";
    } catch (e) {
      return "Something went wrong while reading this document. Please "
          "check your connection and try again.";
    }
  }
}