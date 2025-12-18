class Quote {
  final int id;
  final String text;
  final String author;
  final String category;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      author: json['author'] ?? 'Unknown',
      category: json['category'] ?? 'General',
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}

class QuoteResponse {
  final String status;
  final String message;
  final List<Quote> data;
  final Pagination pagination;

  QuoteResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    return QuoteResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((item) => Quote.fromJson(item)).toList() ?? [],
      pagination: Pagination.fromJson(json['metadata']['pagination']),
    );
  }
}
