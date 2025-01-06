import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:iptvapp/src/services/credentials_service.dart';
import 'package:iptvapp/src/widgets/content_screen/content_screen.dart';
import 'package:iptvapp/src/styles/app_style.dart';

class TVScreen extends StatefulWidget {
  const TVScreen({super.key});

  @override
  State<TVScreen> createState() => _TVScreenState();
}

class _TVScreenState extends State<TVScreen> {
  bool isLoading = false;
  late String baseUrl;
  late String username;
  late String password;
  final _liveTvFocus = FocusNode();
  final _moviesFocus = FocusNode();
  final _seriesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = await CredentialsService.getCredentials();
    setState(() {
      baseUrl = credentials['serverUrl']!;
      username = credentials['username']!;
      password = credentials['password']!;
    });
  }

  Future<void> fetchContent(String type) async {
    setState(() => isLoading = true);

    final dio = Dio();
    try {
      final response = await dio.get(
        '$baseUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': _getAction(type),
        },
      );

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentScreen(
            title: type,
            content: response.data,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load $type: $e')),
      );
    }
  }

  String _getAction(String type) {
    switch (type) {
      case 'Live TV':
        return 'get_live_streams';
      case 'Movies':
        return 'get_vod_streams';
      case 'Series':
        return 'get_series';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.appBackground,
      appBar: AppStyles.getAppBar('Welcome'),
      body: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPortrait = constraints.maxHeight > constraints.maxWidth;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: isPortrait
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildCircularOption(
                              'Live TV',
                              Icons.live_tv,
                              () => fetchContent('Live TV'),
                              _liveTvFocus,
                              nextFocus: _moviesFocus,
                            ),
                            const SizedBox(height: 32),
                            _buildCircularOption(
                              'Movies',
                              Icons.movie,
                              () => fetchContent('Movies'),
                              _moviesFocus,
                              nextFocus: _seriesFocus,
                            ),
                            const SizedBox(height: 32),
                            _buildCircularOption(
                              'Series',
                              Icons.tv,
                              () => fetchContent('Series'),
                              _seriesFocus,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildCircularOption(
                              'Live TV',
                              Icons.live_tv,
                              () => fetchContent('Live TV'),
                              _liveTvFocus,
                              nextFocus: _moviesFocus,
                            ),
                            const SizedBox(width: 64),
                            _buildCircularOption(
                              'Movies',
                              Icons.movie,
                              () => fetchContent('Movies'),
                              _moviesFocus,
                              nextFocus: _seriesFocus,
                            ),
                            const SizedBox(width: 64),
                            _buildCircularOption(
                              'Series',
                              Icons.tv,
                              () => fetchContent('Series'),
                              _seriesFocus,
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildCircularOption(
    String title,
    IconData icon,
    VoidCallback onTap,
    FocusNode focusNode, {
    FocusNode? nextFocus,
  }) {
    return Focus(
      focusNode: focusNode,
      onKeyEvent: (node, event) {        
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
              nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppStyles.bubbleBackground,
              boxShadow: [
                BoxShadow(
                  color: AppStyles.bubbleShadow,
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppStyles.bubbleIcon,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppStyles.bubbleText,
            ),
          ),
        ],
      ),
    );
  }}
