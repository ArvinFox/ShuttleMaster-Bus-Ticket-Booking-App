import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<AlignmentGeometry> _bgAnimation;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _zoomAnimation = Tween<double>(begin: 20.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _bgAnimation = Tween<Alignment>(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Random twinkling stars
    final random = Random();
    _starAnimations = List.generate(8, (_) {
      return Tween<double>(begin: 0.2, end: 0.8).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            random.nextDouble() * 0.5,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.forward();

    Timer(Duration(seconds: 5), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasVisitedHome = prefs.getBool(AppConfig.hasVisitedHomeKey);
      final userId = prefs.getString(AppConfig.userIdKey);
      final role = prefs.getString(AppConfig.userRoleKey);

      String route = "/welcome";

      if (hasVisitedHome != null) {
        route = "/select-role";

        if (userId != null && role != null) {
          if (role == AppConfig.passengerRole) {
            route = "/student/home";
          } else if (role == AppConfig.driverRole) {
            route = "/driver/home";
          }
        }
      }

      Navigator.pushReplacementNamed(
        context, 
        route,
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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _bgAnimation.value,
                end: Alignment.center,
                colors: [
                  Colors.blueAccent.shade700,
                  Colors.lightBlueAccent.shade200,
                ],
              ),
            ),
            child: Stack(
              children: [
                for (int i = 0; i < _starAnimations.length; i++)
                  _buildStar(i),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _zoomAnimation.value,
                          child: Text(
                            "ShuttleMaster",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Lottie.asset(
                          "assets/lottie/bus.json",
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Generate stars at random positions
  Widget _buildStar(int index) {
    final random = Random();
    double left = random.nextDouble() * MediaQuery.of(context).size.width;
    double top = random.nextDouble() * MediaQuery.of(context).size.height;

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _starAnimations[index].value,
            child: Icon(
              Icons.star_rounded,
              size: random.nextDouble() * 20 + 5,
              color: Colors.white.withOpacity(0.8),
            ),
          );
        },
      ),
    );
  }
}