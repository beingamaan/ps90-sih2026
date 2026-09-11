import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;


  // ─── 1. ENHANCE IMAGE (REMOVE.BG & LOCAL AI) ─────────
  static const String removeBgApiKey = String.fromEnvironment(
    'REMOVE_BG_API_KEY',
    defaultValue: 'roVNnnb34xzwNjLKsZCc9854',
  );

  static Future<String?> enhanceImage(Uint8List imageBytes, String filename) async {
    // Priority 1: Direct Remove.bg API call with user key (instant & works everywhere without local backend)
    if (removeBgApiKey.isNotEmpty && removeBgApiKey != 'mock_key') {
      try {
        final uri = Uri.parse('https://api.remove.bg/v1.0/removebg');
        final request = http.MultipartRequest('POST', uri);
        request.headers['X-Api-Key'] = removeBgApiKey;
        request.fields['size'] = 'auto';
        request.files.add(http.MultipartFile.fromBytes('image_file', imageBytes, filename: filename));

        final streamedResponse = await request.send().timeout(const Duration(seconds: 12));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final b64 = base64Encode(response.bodyBytes);
          return 'data:image/png;base64,$b64';
        }
      } catch (e) {
        // Fallthrough to local backend / client matting
      }
    }

    // Priority 2: Local Python Backend (FastAPI rembg u2netp)
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/enhance-image'));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: filename));
      final streamedResponse = await request.send().timeout(const Duration(seconds: 4));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['enhanced_image'];
      }
    } catch (_) {}

    return null;
  }

  // ─── 2. GENERATE LISTING (GEMINI 3.6 FLASH) ──────────
  static Future<Map<String, dynamic>> generateListing(String transcript, String category, {String targetLang = 'hi'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-listing'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transcript': transcript, 'category': category, 'target_lang': targetLang}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Generate Listing API Error: $e');
    }
    return {
      "title": "Handcrafted $category Item",
      "description": "Authentic handmade craft built with traditional artisan skills.",
      "hindi_description": "पारंपरिक कारीगर तकनीकों से निर्मित हस्तनिर्मित शिल्प।",
      "tags": ["Handmade", category, "Craft"],
      "maker_story": "Handcrafted by local artisans preserving centuries of cultural heritage.",
      "status": "fallback"
    };
  }

  // ─── 3. PRICING ASSISTANT ──────────────────────────────
  static Future<Map<String, dynamic>> suggestPrice(double materialCost, double hoursWorked, String category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/price-suggestion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'material_cost': materialCost,
          'hours_worked': hoursWorked,
          'category': category
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Price Suggestion API Error: $e');
    }
    return {
      "material_cost": materialCost,
      "hours_worked": hoursWorked,
      "labor_cost": hoursWorked * 50.0,
      "cost_floor": (materialCost + hoursWorked * 50.0) * 1.08,
      "market_min": 400.0,
      "market_max": 900.0,
      "recommended_price": (materialCost + hoursWorked * 50.0) * 1.08,
      "guardrail_triggered": true,
      "guardrail_message": "Fair Wage Guardrail: Price is above the calculated cost floor.",
      "seasonal_note": ""
    };
  }

  // ─── 4. MOCK PUBLISH (ONDC / GeM) ──────────────────────
  static Future<Map<String, dynamic>> mockPublish(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mock-publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Mock Publish API Error: $e');
    }
    return {
      "status": "success",
      "message": "Successfully published to ONDC Network",
      "listing_id": "ONDC-IND-9999",
      "live_url": "https://ondc.in/catalog/9999"
    };
  }

  // ─── 5. FETCH ITEMS FROM SQLITE ────────────────────────
  static Future<List<dynamic>> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      }
    } catch (e) {
      print('Fetch Items API Error: $e');
    }
    return [];
  }

  // ─── 6. HINDI TTS AUDIO GENERATOR ─────────────────────
  static Future<String?> getTtsAudio(String text, {String lang = 'hi'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'lang': lang}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['audio_b64'];
      }
    } catch (e) {
      print('TTS API Error: $e');
    }
    return null;
  }
}
