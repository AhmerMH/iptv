import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iptvapp/src/widgets/login/login.dart';
import 'package:iptvapp/src/styles/app_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPTV App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'IPTV App'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.appBackground,
      body: Stack(
        children: [
          // Animated stars background
          ...List.generate(20, (index) => _buildStar()),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated text logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: Text(
                        'IPTV',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = AppStyles.appBarBackground.withOpacity(_fadeAnimation.value),
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: AppStyles.appBarBackground.withOpacity(_fadeAnimation.value),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Subtitle with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Your Entertainment Hub',
                    style: TextStyle(
                      color: AppStyles.colorIcon,
                      fontSize: 18,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }  Widget _buildStar() {
    final random = Random();
    final top = random.nextDouble() * MediaQuery.of(context).size.height;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    // Ensure delay is between 0.0 and 1.0
    final delay = random.nextDouble() * 0.7; // Reduced from 3 to 0.7

    return Positioned(
      top: top,
      left: left,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(seconds: 3),
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
        builder: (context, double value, child) {
          return Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppStyles.colorIcon
            ),
          );
        },
      ),
    );
  }}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.getAppBar(widget.title),
      body: const LoginPage(),
    );
  }
}