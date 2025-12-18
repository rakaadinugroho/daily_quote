import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://quotes.liupurnomo.com/api';

  Future<QuoteResponse> getQuotes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$_baseUrl/quotes?page=$page&limit=$limit');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        return QuoteResponse.fromJson(jsonBody);
      } else {
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load quotes: $e');
    }
  }
}
