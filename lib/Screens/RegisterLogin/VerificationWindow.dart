// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Login.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Helper method to get responsive dimensions
  double _getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      // Desktop: 1/3 of screen width, max 400px
      return screenWidth * 0.5;
    } else if (screenWidth > 768) {
      // Tablet: 60% of screen width
      return screenWidth * 0.6;
    } else {
      // Mobile: 90% of screen width with padding
      return screenWidth * 0.9;
    }
  }

  double _getResponsiveHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight > 800) {
      // Desktop/Large screens: limit height to 70% max
      return (screenHeight * 0.7).clamp(500, 600);
    }
    return screenHeight; // Mobile/tablet use full height with SafeArea
  }

  // Get responsive font sizes
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 24;
    if (screenWidth > 768) return 22;
    return 20;
  }

  double _getDescriptionFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 16;
    if (screenWidth > 768) return 15;
    return 14;
  }

  double _getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 50;
    if (screenWidth > 768) return 45;
    return 40;
  }

  double _getContainerSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 100;
    if (screenWidth > 768) return 90;
    return 80;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Container(
                width: _getResponsiveWidth(context),
                height: isDesktop ? _getResponsiveHeight(context) : null,
                constraints: isDesktop
                    ? BoxConstraints(
                        maxHeight: _getResponsiveHeight(context),
                        minHeight: 500,
                      )
                    : null,
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 0 : 16,
                  vertical: isDesktop ? 0 : 16,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : (isTablet ? 32 : 24),
                  vertical: isDesktop ? 32 : (isTablet ? 24 : 20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Clock Icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: _getContainerSize(context),
                            height: _getContainerSize(context),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              size: _getIconSize(context),
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),

                    // Title with glassmorphism effect
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 20 : (isTablet ? 18 : 16),
                        vertical: isDesktop ? 14 : (isTablet ? 12 : 10),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'Akun Menunggu Persetujuan',
                        style: TextStyle(
                          fontSize: _getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),

                    // Description with improved styling
                    Container(
                      padding:
                          EdgeInsets.all(isDesktop ? 20 : (isTablet ? 18 : 16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white70,
                            size: isDesktop ? 28 : (isTablet ? 26 : 24),
                          ),
                          SizedBox(
                              height: isDesktop ? 12 : (isTablet ? 10 : 8)),
                          Text(
                            'Pendaftaran klinik Anda sedang ditinjau oleh tim kami.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getDescriptionFontSize(context),
                              color: Colors.white,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 6 : 4),
                          Text(
                            'Anda akan diberi notifikasi setelah akun Anda disetujui.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getDescriptionFontSize(context) - 1,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isDesktop ? 32 : (isTablet ? 28 : 24)),

                    // Enhanced button with modern design
                    Container(
                      width: double.infinity,
                      height: isDesktop ? 48 : (isTablet ? 52 : 48),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(isDesktop ? 24 : 26),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          );

                          try {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(-1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal keluar: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 24 : 26),
                          ),
                        ),
                        icon: Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFF667eea),
                          size: isDesktop ? 20 : (isTablet ? 22 : 20),
                        ),
                        label: Text(
                          'Kembali ke Login',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : (isTablet ? 17 : 16),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667eea),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 20 : (isTablet ? 18 : 16)),

                    // Status indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusDot(false, context),
                        const SizedBox(width: 6),
                        _buildStatusDot(true, context),
                        const SizedBox(width: 6),
                        _buildStatusDot(false, context),
                      ],
                    ),

                    SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),

                    Text(
                      'Sedang Ditinjau',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : (isTablet ? 13 : 12),
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDot(bool isActive, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dotSize =
        screenWidth > 1200 ? (isActive ? 10.0 : 6.0) : (isActive ? 12.0 : 8.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}
