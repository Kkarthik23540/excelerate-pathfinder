import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'learner_login_screen.dart';

// ─── Color constants ────────────────────────────────────────────────────
const kAuthPrimary = Color(0xFF5E35B1);
const kAuthAccent = Color(0xFFE57373);
const kAuthAccentDark = Color(0xFFE53935);
const kAuthFieldBg = Color(0xFFF3E5F5);
const kAuthFieldBgFocused = Color(0xFFEDE7F6);
const kAuthBlobPink = Color(0xFFFCE4EC);
const kAuthBlobLavender = Color(0xFFEDE7F6);
const kAuthError = Color(0xFFD32F2F);
const kAuthSuccess = Color(0xFF2E7D32);

// ============================================================
//  FORGOT PASSWORD SCREEN
// ============================================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _submitting = false;
  bool _emailFocused = false;
  String? _emailError;
  bool _emailTouched = false;

  // Email regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onEmailFocusChange);
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onEmailFocusChange);
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  // ============================================================
  //  LISTENERS
  // ============================================================
  void _onEmailFocusChange() {
    if (mounted) setState(() => _emailFocused = _emailFocus.hasFocus);
  }

  void _onEmailChanged() {
    if (!_emailTouched) _emailTouched = true;
    final value = _emailController.text.trim();
    if (value.isEmpty) {
      setState(() => _emailError = null);
    } else if (!_emailRegex.hasMatch(value)) {
      setState(() => _emailError = 'Please enter a valid email address');
    } else {
      setState(() => _emailError = null);
    }
  }

  bool _isFormValid() {
    return _emailRegex.hasMatch(_emailController.text.trim());
  }

  // ============================================================
  //  RESET PASSWORD
  // ============================================================
  Future<void> _handleResetPassword() async {
    setState(() => _emailTouched = true);

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reset link sent! Check your inbox.',
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: kAuthSuccess,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        errorMsg = 'No account found with this email';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Too many attempts. Try again later.';
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      _showError(errorMsg);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kAuthAccentDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================
  //  UI BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: kAuthPrimary),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kAuthAccentDark, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 36,
                          color: kAuthAccentDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Enter your email and we'll send you\na reset link",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field with focus + validation
                    const Text('EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hint: 'Enter your mail-ID',
                      icon: Icons.mail_outline,
                      focused: _emailFocused,
                      errorText: _emailError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleResetPassword(),
                    ),
                    const SizedBox(height: 24),

                    // Send Reset Email Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        (_submitting || !_isFormValid()) ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAuthPrimary,
                          disabledBackgroundColor: kAuthPrimary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Send Reset Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign in link
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                              children: [
                                TextSpan(text: 'Remember your password? '),
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                    color: kAuthAccentDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  // ============================================================
  //  CUSTOM TEXT FIELD (with focus highlight + error)
  // ============================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool focused,
    String? errorText,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    // Color logic
    Color borderColor;
    Color bgColor;
    Color iconColor;
    if (errorText != null) {
      borderColor = kAuthError;
      bgColor = const Color(0xFFFFEBEE);
      iconColor = kAuthError;
    } else if (focused) {
      borderColor = kAuthPrimary;
      bgColor = kAuthFieldBgFocused;
      iconColor = kAuthPrimary;
    } else {
      borderColor = kAuthAccent;
      bgColor = kAuthFieldBg.withOpacity(0.5);
      iconColor = kAuthAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: focused || errorText != null ? 1.6 : 1.2,
            ),
            boxShadow: focused
                ? [
              BoxShadow(
                color: kAuthPrimary.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.35),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey(iconColor),
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 13, color: kAuthError),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: kAuthError,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
//  GRADIENT BACKGROUND
// ============================================================
class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kAuthBlobPink.withOpacity(0.7),
                  kAuthBlobPink.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF8BBD0).withOpacity(0.4),
                  const Color(0xFFF8BBD0).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: 50,
          right: 50,
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kAuthBlobLavender.withOpacity(0.35),
                  kAuthBlobLavender.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        child!,
      ],
    );
  }
}