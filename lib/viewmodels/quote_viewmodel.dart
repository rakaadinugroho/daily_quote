import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/local_storage_service.dart';

class QuoteViewModel extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<Quote> _quotes = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  List<Quote> get quotes {
    if (_searchQuery.isEmpty) {
      return _quotes;
    }
    return _quotes.where((quote) {
      final query = _searchQuery.toLowerCase();
      return quote.text.toLowerCase().contains(query) ||
          quote.author.toLowerCase().contains(query) ||
          quote.category.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  bool get isLoadingMore => _isLoadingMore;

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchQuotes({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _quotes = [];
      _hasNextPage = true;
      _errorMessage = null;
    }

    if (!_hasNextPage) return;

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _quoteService.getQuotes(page: _currentPage);

      if (refresh) {
        _quotes = response.data;
        // Cache only the first page results
        if (_currentPage == 1) {
          await _localStorageService.saveQuotes(_quotes);
        }
      } else {
        _quotes.addAll(response.data);
      }

      _hasNextPage = response.pagination.hasNextPage;
      _currentPage++;
      _errorMessage = null;
    } catch (e) {
      // If we are on the first page and there is an error (e.g. no internet), try to load from cache
      if (_currentPage == 1 && refresh) {
        try {
          final cachedQuotes = await _localStorageService.getQuotes();
          if (cachedQuotes.isNotEmpty) {
            _quotes = cachedQuotes;
            _errorMessage = null; // Clear error if cache load is successful
            // Assume no next page for offline mode or handle differently if needed
            _hasNextPage = false;
          } else {
            _errorMessage = e.toString();
          }
        } catch (cacheError) {
          _errorMessage = e.toString();
        }
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
