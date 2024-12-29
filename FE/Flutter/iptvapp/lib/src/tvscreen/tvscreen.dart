
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';

class TVScreen extends StatefulWidget {
  const TVScreen({super.key});

  @override
  State<TVScreen> createState() => _TVScreenState();
}
class _TVScreenState extends State<TVScreen> {
  final String baseUrl = 'https://webhop.xyz:8080';
  final String username = '93636283726';
  final String password = '53713632929';
  
  late VideoPlayerController _videoController;
  List<Channel> channels = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Initialize with a default stream
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://example.com/default.m3u8')
    )..initialize().then((_) {
        setState(() {});
      });
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_live_streams',
        },
      );
      setState(() {
        channels = (response.data as List)
            .map((channel) => Channel.fromJson(channel))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error appropriately
    }
  }

  void playChannel(String streamUrl) {
    _videoController = VideoPlayerController.network(streamUrl)
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildVideoPlayer(),
        Expanded(child: _buildChannelList()),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildVideoPlayer()),
        Expanded(child: _buildChannelList()),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (!_videoController.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: VideoPlayer(_videoController),
    );
  }

  Widget _buildChannelList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ListTile(
                leading: Image.network(channel.logo),
                title: Text(channel.name),
                onTap: () => playChannel(channel.streamUrl),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButton<String>(
      value: selectedCategory,
      items: ['All', ...channels.map((c) => c.category).toSet()]
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => selectedCategory = value!);
      },
    );
  }
}

class Channel {
  final String name;
  final String streamUrl;
  final String logo;
  final String category;

  Channel({
    required this.name,
    required this.streamUrl,
    required this.logo,
    required this.category,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'],
      streamUrl: json['stream_url'],
      logo: json['stream_icon'],
      category: json['category_name'],
    );
  }
}
