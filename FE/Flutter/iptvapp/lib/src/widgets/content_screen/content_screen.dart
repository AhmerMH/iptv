import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptvapp/src/services/credentials_service.dart';
import 'package:iptvapp/src/styles/app_style.dart';
import 'package:iptvapp/src/widgets/video_player_screen/video_player_screen.dart';

class ContentScreen extends StatefulWidget {
  final String title;
  final dynamic content;

  const ContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  Map<String, String> categoryNames = {};
  late String baseUrl;
  late String username;
  late String password;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _itemFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _initializeFocusNodes();
  }

  Future<void> _loadCredentials() async {
    final credentials = await CredentialsService.getCredentials();
    setState(() {
      baseUrl = credentials['serverUrl']!;
      username = credentials['username']!;
      password = credentials['password']!;
    });
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        '$baseUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': _getCategoryAction(widget.title),
        },
      );

      setState(() {
        categoryNames = Map.fromEntries((response.data as List).map((cat) =>
            MapEntry(cat['category_id'].toString(), cat['category_name'])));
      });
    } catch (e) {
      print('Failed to load categories');
    }
  }

  String _getCategoryAction(String contentType) {
    switch (contentType) {
      case 'Live TV':
        return 'get_live_categories';
      case 'Movies':
        return 'get_vod_categories';
      case 'Series':
        return 'get_series_categories';
      default:
        return 'get_live_categories';
    }
  }

  List<String> getCategories() {
    return widget.content
        .map<String>((item) => item['category_id'] as String)
        .toSet()
        .toList();
  }

  void _initializeFocusNodes() {
    _itemFocusNodes.clear();
    for (var i = 0; i < widget.content.length; i++) {
      _itemFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _categoryFocus.dispose();
    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.appBackground,
      appBar: AppStyles.getAppBar(widget.title),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          
          return isWideScreen 
            ? _buildWideLayout()
            : _buildNarrowLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Container(
          width: 200,
          color: Colors.grey[900],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ['All', ...getCategories()].length,
                  itemBuilder: (context, index) {
                    final categoryId = ['All', ...getCategories()][index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedCategory == categoryId 
                            ? Colors.cyan[800] 
                            : Colors.transparent,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory = categoryId;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            categoryId == 'All'
                                ? 'All Categories'
                                : (categoryNames[categoryId] ?? categoryId),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: selectedCategory == categoryId 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );                  },                ),
              ),
            ],
          ),
        ),        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Focus(
                  focusNode: _searchFocus,
                  child: TextField(
                    style: const TextStyle(color: AppStyles.colorInputText),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: AppStyles.colorInputText),
                      prefixIcon: Icon(Icons.search, color: AppStyles.colorInputText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppStyles.colorInputBackground,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: getFilteredContent().length,
                    itemBuilder: (context, index) {
                      final item = getFilteredContent()[index];
                      return Focus(
                        focusNode: _itemFocusNodes[index],
                        child: InkWell(
                          onTap: () => _onItemSelected(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      item['stream_icon'] ?? '',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[900],
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.cyan[800]!,
                                              size: 50,
                                            ),
                                          ),
                                        );
                                      },                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          color: AppStyles.colorTileText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        categoryNames[item['category_id']] ?? '',
                                        style: TextStyle(
                                          color: AppStyles.colorTileSubtitle,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Focus(
            focusNode: _searchFocus,
            child: TextField(
              style: const TextStyle(color: AppStyles.colorInputText),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppStyles.colorInputText),
                prefixIcon: Icon(Icons.search, color: AppStyles.colorInputText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppStyles.colorInputBackground,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
        
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ['All', ...getCategories()].length,
            itemBuilder: (context, index) {
              final categoryId = ['All', ...getCategories()][index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  selected: selectedCategory == categoryId,
                  label: Text(
                    categoryId == 'All' 
                      ? 'All Categories' 
                      : (categoryNames[categoryId] ?? categoryId),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedCategory = categoryId;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: getFilteredContent().length,
              itemBuilder: (context, index) {
                final item = getFilteredContent()[index];
                return Focus(
                  focusNode: _itemFocusNodes[index],
                  child: InkWell(
                    onTap: () => _onItemSelected(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                item['stream_icon'] ?? '',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[900],
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.cyan[800],
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    color: AppStyles.colorTileText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  categoryNames[item['category_id']] ?? '',
                                  style: TextStyle(
                                    color: AppStyles.colorTileSubtitle,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onItemSelected(dynamic item) {
    final streamUrl =
        '$baseUrl/movie/${item['stream_id']}.${item['container_extension']}?username=$username&password=$password';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          streamUrl: streamUrl,
          title: item['name'],
        ),
      ),
    );
  }

  List<dynamic> getFilteredContent() {
    return widget.content.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item['category_id'] == selectedCategory;
      final matchesSearch = item['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
