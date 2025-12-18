import 'package:flutter/material.dart';
import '../viewmodels/quote_viewmodel.dart';
import 'widgets/quote_card.dart';

class QuoteListView extends StatefulWidget {
  const QuoteListView({Key? key}) : super(key: key);

  @override
  State<QuoteListView> createState() => _QuoteListViewState();
}

class _QuoteListViewState extends State<QuoteListView> {
  final QuoteViewModel _viewModel = QuoteViewModel();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelUpdate);
    _scrollController.addListener(_onScroll);
    _viewModel.fetchQuotes();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelUpdate() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_viewModel.isLoading &&
          !_viewModel.isLoadingMore &&
          _viewModel.hasNextPage) {
        _viewModel.fetchQuotes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5), // Light cream background
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await _viewModel.fetchQuotes(refresh: true);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DAILY INSPIRATION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'All Quotes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Search Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey.shade400),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: _viewModel.search,
                                    decoration: InputDecoration(
                                      hintText: 'Search by author or tag...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  if (_viewModel.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_viewModel.errorMessage != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_viewModel.errorMessage!),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  _viewModel.fetchQuotes(refresh: true),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index < _viewModel.quotes.length) {
                            return QuoteCard(quote: _viewModel.quotes[index]);
                          } else if (_viewModel.hasNextPage) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  "You've reached the end",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }
                        }, childCount: _viewModel.quotes.length + 1),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
