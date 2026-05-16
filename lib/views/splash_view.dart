import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/broccoli_mascot.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _mascotCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _mascotScale;
  late Animation<double> _textFade;
  late Animation<Offset> _mascotSlide;
  late Animation<Offset> _textSlide;

  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Cook Without the Hassle',
      'desc':
          'Paket sayur dan bumbu lengkap yang siap membantu Anda membuat masakan lezat tanpa perlu repot berbelanja.',
    },
    {
      'title': 'Fresh Every Day',
      'desc':
          'Kami menjamin kesegaran setiap produk yang kami antar langsung ke pintu rumah Anda.',
    },
    {
      'title': 'Quick Delivery',
      'desc':
          'Pesanan Anda akan sampai dalam waktu singkat dengan pengiriman cepat dan terpercaya.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _mascotCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _textCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    _mascotScale =
        CurvedAnimation(parent: _mascotCtrl, curve: Curves.easeOutBack);

    _mascotSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mascotCtrl, curve: Curves.easeOut));

    _textFade =
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _playEnter();
  }

  void _playEnter() {
    _mascotCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _textCtrl.forward();
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _mascotCtrl.reset();
      _textCtrl.reset();
      setState(() => _currentPage++);
      _playEnter();
    } else {
      _goToLogin();
    }
  }

  @override
  void dispose() {
    _mascotCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1A3A2A),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0xFF2E6B45), Color(0xFF1A3A2A)],
                    ),
                  ),
                  child: SlideTransition(
                    position: _mascotSlide,
                    child: ScaleTransition(
                      scale: _mascotScale,
                      child: const Center(
                        child: BroccoliMascot(size: 210),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(data['desc']!),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      Row(
                        children: List.generate(_pages.length, (i) {
                          final active = i == _currentPage;
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF2E6B45)
                                  : const Color(0xFFB8D4C4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (!isLast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: GestureDetector(
                onTap: _goToLogin,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}