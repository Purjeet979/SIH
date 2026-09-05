import 'package:flutter/material.dart';
import 'login_page.dart';
import 'theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _scanController;
  late AnimationController _pulseController;

  // Splash entrance & exit controllers
  late AnimationController _splashIntroController;
  late AnimationController _splashOutController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _splashFadeAnimation;
  late Animation<double> _splashScaleAnimation;

  bool _splashDismissed = false;

  @override
  void initState() {
    super.initState();

    // Intro entrance controller (smooth logo scale + staggered text reveal)
    _splashIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashIntroController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashIntroController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _splashIntroController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashIntroController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashIntroController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Smooth dismiss controller (silky dissolve with subtle scale)
    _splashOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _splashFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashOutController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _splashScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _splashOutController,
        curve: Curves.easeInCubic,
      ),
    );

    // Play intro immediately
    _splashIntroController.forward();

    // After holding for 1500ms, start the buttery smooth dissolve
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _splashOutController.forward().then((_) {
          if (mounted) {
            setState(() {
              _splashDismissed = true;
            });
          }
        });
      }
    });

    // Looping animations
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _splashIntroController.dispose();
    _splashOutController.dispose();
    _floatController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: Stack(
        children: [
          // Main Landing Page Content (laid out smoothly underneath)
          Positioned.fill(
            child: _buildMainContent(context),
          ),

          // Splash Overlay (solid surfaceBase background, perfectly centered, smoothly dissolves)
          if (!_splashDismissed)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _splashOutController.value > 0.0,
                child: FadeTransition(
                  opacity: _splashFadeAnimation,
                  child: Container(
                    color: AppTheme.surfaceBase,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _splashScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _splashScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildSplash(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Splash: centered logo + app name ──
  Widget _buildSplash(BuildContext context) {
    return AnimatedBuilder(
      animation: _splashIntroController,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: _titleOpacity.value,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  'RuleScan',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: _taglineOpacity.value,
              child: const Text(
                'Scan it. Check it. Prove it.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Main landing content ──
  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      key: const ValueKey('content'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text('RuleScan', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Text('Go to Login', style: Theme.of(context).textTheme.labelLarge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Headlines
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.passGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Next-Gen Regulatory Intelligence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Compliance made simple.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Automated regulatory checks, instant document verification, and seamless audit readiness.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Animated Graphic Area
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlueLight.withValues(alpha: 0.8),
                        boxShadow: [BoxShadow(color: AppTheme.primaryBlueLight, blurRadius: 40, spreadRadius: 20)],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) => Transform.translate(offset: Offset(0, -10 * _floatController.value), child: child),
                      child: Container(
                        width: 170, height: 210,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(width: 50, height: 10, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(5))),
                              const SizedBox(width: 8),
                              Container(width: 30, height: 10, decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(5))),
                            ]),
                            const SizedBox(height: 20),
                            Container(width: 120, height: 7, decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(3.5))),
                            const SizedBox(height: 10),
                            Container(width: 90, height: 7, decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(3.5))),
                            const SizedBox(height: 10),
                            Container(width: 100, height: 7, decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(3.5))),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(color: AppTheme.passGreenLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.passGreen.withValues(alpha: 0.3))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.check_circle, color: AppTheme.passGreen, size: 14),
                                const SizedBox(width: 6),
                                Container(width: 60, height: 6, decoration: BoxDecoration(color: AppTheme.passGreen, borderRadius: BorderRadius.circular(3))),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) => Positioned(top: 40 + (180 * _scanController.value), child: child!),
                      child: Container(
                        width: 190, height: 3,
                        decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(1.5), boxShadow: [BoxShadow(color: AppTheme.primaryBlue, blurRadius: 10, spreadRadius: 2)]),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Transform.scale(
                        scale: 1.0 + (0.05 * _pulseController.value),
                        child: Opacity(opacity: 0.6 + (0.4 * _pulseController.value), child: child),
                      ),
                      child: SizedBox(
                        width: 220, height: 250,
                        child: Stack(children: [
                          Positioned(top: 0, left: 0, child: _buildBracket(false, false)),
                          Positioned(top: 0, right: 0, child: _buildBracket(false, true)),
                          Positioned(bottom: 0, left: 0, child: _buildBracket(true, false)),
                          Positioned(bottom: 0, right: 0, child: _buildBracket(true, true)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Get Started'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18),
                ]),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.surfaceSubtle, side: BorderSide.none),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.play_circle_outline, color: AppTheme.primaryBlue, size: 20), SizedBox(width: 8), Text('Watch Demo'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBracket(bool bottom, bool right) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: bottom ? BorderSide.none : const BorderSide(color: AppTheme.primaryBlue, width: 3),
          bottom: bottom ? const BorderSide(color: AppTheme.primaryBlue, width: 3) : BorderSide.none,
          left: right ? BorderSide.none : const BorderSide(color: AppTheme.primaryBlue, width: 3),
          right: right ? const BorderSide(color: AppTheme.primaryBlue, width: 3) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: (!bottom && !right) ? const Radius.circular(8) : Radius.zero,
          topRight: (!bottom && right) ? const Radius.circular(8) : Radius.zero,
          bottomLeft: (bottom && !right) ? const Radius.circular(8) : Radius.zero,
          bottomRight: (bottom && right) ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

