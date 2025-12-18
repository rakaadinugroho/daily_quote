import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class LocalStorageService {
  static const String _quotesKey = 'cached_quotes';

  Future<void> saveQuotes(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> quotesJson = quotes.map((quote) => json.encode(quote.toJson())).toList();
    await prefs.setStringList(_quotesKey, quotesJson);
  }

  Future<List<Quote>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? quotesJson = prefs.getStringList(_quotesKey);

    if (quotesJson == null) {
      return [];
    }

    return quotesJson.map((quoteStr) => Quote.fromJson(json.decode(quoteStr))).toList();
  }

  Future<void> clearQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quotesKey);
  }
}
