import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:iptvapp/src/styles/app_style.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.streamUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _videoPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _videoPlayerController = VlcPlayerController.network(
      'http://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
      ),
    );

    _videoPlayerController.addOnInitListener(() {
      setState(() {
        _isInitialized = true;
      });
    });

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.hasError) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Stream playback error occurred';
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.cyan,
          ),
          SizedBox(height: 20),
          Text(
            'Loading stream...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializePlayer();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppStyles.getAppBar(widget.title),
      body: _hasError
          ? _buildErrorDisplay()
          : Stack(
              children: [
                Center(
                  child: VlcPlayer(
                    controller: _videoPlayerController,
                    aspectRatio: 16 / 9,
                    placeholder: _buildLoadingIndicator(),
                  ),
                ),
                if (!_isInitialized) _buildLoadingIndicator(),
              ],
            ),
    );
  }
}