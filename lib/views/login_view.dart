import 'package:flutter/material.dart';
import 'package:food_app/views/MainNav.dart';
import 'package:food_app/widgets/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import '../widgets/broccoli_mascot.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNav(initialIndex: 0)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF1A3A2A),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          // Mascot
                          const BroccoliMascot(size: 160),
                          const SizedBox(height: 24),
                          // Welcome text
                          Text(
                            'Welcome Back !',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A3A2A),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Form fields ────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3A2A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                AuthTextField(
                                  controller: _emailCtrl,
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  controller: _passCtrl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscure,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  validator: (v) => v!.isEmpty ? 'Password wajib diisi' : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Forgot password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordView()),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Forgot Password? ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Click here',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF2E6B45),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Diubah menggunakan Selector agar rebuild-nya efisien khusus untuk tombol loading saja
                          Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isLoading,
                            builder: (context, isLoading, child) {
                              return AuthButton(
                                label: 'Sign In',
                                isLoading: isLoading,
                                onTap: _login,
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                          // OR divider
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                            ],
                          ),

                          const SizedBox(height: 16),
                          // Google sign in
                          _GoogleButton(),

                          const SizedBox(height: 20),
                          // Sign Up link
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterView()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have account yet? ",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF1A3A2A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // G logo
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Kuning (Top-Left ke Top-Right)
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(r, r)
      ..lineTo(r - 0.72 * r, r - 0.69 * r)
      ..arcToPoint(Offset(r + 0.72 * r, r - 0.69 * r), radius: Radius.circular(r), clockwise: true)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Hijau (Bottom-Left ke Bottom-Right)
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(r, r)
      ..lineTo(r - 0.72 * r, r + 0.69 * r)
      ..arcToPoint(Offset(r + 0.72 * r, r + 0.69 * r), radius: Radius.circular(r), clockwise: false)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Merah (Sisi Kiri)
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(r, r)
      ..lineTo(r - 0.72 * r, r - 0.69 * r)
      ..arcToPoint(Offset(r - 0.72 * r, r + 0.69 * r), radius: Radius.circular(r), clockwise: false)
      ..close();
    canvas.drawPath(redPath, paint);

    // Biru (Sisi Kanan dan Palang Tengah G)
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(r, r)
      ..lineTo(r + 0.72 * r, r - 0.69 * r)
      ..arcToPoint(Offset(r + 1.0 * r, r), radius: Radius.circular(r), clockwise: true)
      ..arcToPoint(Offset(r + 0.72 * r, r + 0.69 * r), radius: Radius.circular(r), clockwise: true)
      ..lineTo(r, r + 0.2 * r)
      ..lineTo(r + 0.95 * r, r + 0.2 * r)
      ..lineTo(r + 0.95 * r, r - 0.2 * r)
      ..lineTo(r, r - 0.2 * r)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Mask Tengah Putih (Agar membentuk huruf G berlubang)
    paint.color = Colors.white;
    canvas.drawCircle(Offset(r, r), r * 0.6, paint);

    // Potongan kecil ekstra putih di atas palang biru agar pas menjadi struktur G
    final Path whiteCut = Path()
      ..moveTo(r + 0.5 * r, r - 0.2 * r)
      ..lineTo(r + 1.0 * r, r - 0.2 * r)
      ..lineTo(r + 1.0 * r, r - 0.6 * r)
      ..lineTo(r + 0.5 * r, r - 0.3 * r)
      ..close();
    canvas.drawPath(whiteCut, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
