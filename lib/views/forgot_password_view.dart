import 'package:flutter/material.dart';
import 'package:food_app/widgets/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/broccoli_mascot.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'login_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _sent = false;

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
    _usernameCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Gagal mengirim permintaan'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                          color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  Text(
                    'Forgot Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF2E6B45),
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
                    child: _sent ? _SuccessContent() : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          const BroccoliMascot(size: 140),
                          const SizedBox(height: 18),
                          Text(
                            'Forgot Password',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A3A2A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masukkan email atau nomor HP yang terdaftar',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form card
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
                                  hint: 'Masukkan no tlpn / email',
                                  icon: Icons.contact_phone_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Field ini wajib diisi' : null,
                                ),
                                const SizedBox(height: 12),
                                AuthTextField(
                                  controller: _usernameCtrl,
                                  hint: 'Username',
                                  icon: Icons.person_outline,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Username wajib diisi' : null,
                                ),
                                const SizedBox(height: 12),
                                AuthTextField(
                                  controller: _newPassCtrl,
                                  hint: 'Buat Password anda',
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
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                  validator: (v) =>
                                      v!.length < 6 ? 'Min. 6 karakter' : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          AuthButton(
                            label: 'Continue',
                            isLoading: auth.isLoading,
                            onTap: _submit,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('OR',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey[500], fontSize: 12)),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _GoogleButton(),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginView()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Not a user yet? ',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600], fontSize: 13),
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

class _SuccessContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF2E6B45).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline,
              size: 60, color: Color(0xFF2E6B45)),
        ),
        const SizedBox(height: 24),
        Text(
          'Email Terkirim!',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A3A2A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Instruksi reset password telah dikirim ke email Anda.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        AuthButton(
          label: 'Kembali ke Login',
          isLoading: false,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(Icons.g_mobiledata, color: Color(0xFF4285F4), size: 26),
          const SizedBox(width: 8),
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
    );
  }
}