// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'learner_home_screen.dart';
import 'learner_onboarding_quiz_screen.dart';
import 'learner_signup_screen.dart';
import 'learner_forgot_password_screen.dart';

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

const String kWebClientId =
    '485243538959-ko29fn8camgj9el2e02t6ad31oi4t5pg.apps.googleusercontent.com';

// ============================================================
//  LOGIN SCREEN
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _keepSignedIn = false;
  bool _submitting = false;

  // Logo animations (scale + glow, no rotation)
  late final AnimationController _logoScaleController;
  late final AnimationController _logoGlowController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;

  bool _emailFocused = false;
  bool _passwordFocused = false;

  String? _emailError;
  String? _passwordError;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();

    // ✅ Logo scale animation (entrance)
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = CurvedAnimation(
      parent: _logoScaleController,
      curve: Curves.elasticOut,
    );

    // ✅ Logo glow pulse
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _logoGlowController, curve: Curves.easeInOut),
    );

    // ✅ Start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoScaleController.forward();
    });

    _emailFocus.addListener(_onEmailFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _emailFocus.removeListener(_onEmailFocusChange);
    _passwordFocus.removeListener(_onPasswordFocusChange);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _logoScaleController.dispose();
    _logoGlowController.dispose();
    super.dispose();
  }

  // ============================================================
  //  FOCUS LISTENERS
  // ============================================================
  void _onEmailFocusChange() {
    if (!mounted) return;
    setState(() => _emailFocused = _emailFocus.hasFocus);
  }

  void _onPasswordFocusChange() {
    if (!mounted) return;
    setState(() => _passwordFocused = _passwordFocus.hasFocus);
  }

  void _onEmailChanged() {
    if (!_emailTouched) {
      _emailTouched = true;
    }
    final value = _emailController.text.trim();
    if (value.isEmpty) {
      setState(() => _emailError = null);
      return;
    }
    if (!_emailRegex.hasMatch(value)) {
      setState(() => _emailError = 'Please enter a valid email address');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _onPasswordChanged() {
    if (!_passwordTouched) {
      _passwordTouched = true;
    }
    final value = _passwordController.text;
    if (value.isEmpty) {
      setState(() => _passwordError = null);
      return;
    }
    if (value.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
    } else {
      setState(() => _passwordError = null);
    }
  }

  bool _isFormValid() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return _emailRegex.hasMatch(email) && password.length >= 6;
  }

  // ============================================================
  //  CHECK ONBOARDING STATUS & NAVIGATE
  // ============================================================
  Future<void> _checkOnboardingAndNavigate(String uid) async {
    try {
      final db = FirebaseFirestore.instance;
      final userDocRef = db.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      if (!mounted) return;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final onboardingCompleted = userData['onboardingCompleted'] ?? false;

        if (onboardingCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LearnerHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingQuizScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingQuizScreen()),
        );
      }
    } catch (e) {
      debugPrint('Onboarding check error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LearnerHomeScreen()),
        );
      }
    }
  }

  // ============================================================
  //  EMAIL/PASSWORD SIGN IN
  // ============================================================
  Future<void> _handleLogin() async {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final db = FirebaseFirestore.instance;
        final userDocRef = db.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          await _createFirestoreUserDoc(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            phone: user.phoneNumber ?? '',
            photoURL: user.photoURL,
          );
        } else {
          await userDocRef.update({
            'lastActiveAt': FieldValue.serverTimestamp(),
          });
        }

        await _checkOnboardingAndNavigate(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMsg = 'No account found. Please sign up first.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password. Try again.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'This account has been disabled.';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid email or password.';
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

  // ============================================================
  //  GOOGLE SIGN IN
  // ============================================================
  Future<void> _handleGoogleSignIn() async {
    setState(() => _submitting = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(clientId: kWebClientId);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _submitting = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final db = FirebaseFirestore.instance;
      final userDocRef = db.collection('users').doc(userCredential.user!.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await _createFirestoreUserDoc(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'New User',
          phone: userCredential.user!.phoneNumber ?? '',
          photoURL: userCredential.user!.photoURL,
        );
      } else {
        await userDocRef.update({
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      }

      await _checkOnboardingAndNavigate(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _showError('Google sign-in failed: ${e.message}');
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }


  // ============================================================
  //  HELPER: Create Firestore user documents
  // ============================================================
  Future<void> _createFirestoreUserDoc({
    required String uid,
    required String email,
    required String name,
    required String phone,
    String? photoURL,
  }) async {
    final db = FirebaseFirestore.instance;
    final userDocRef = db.collection('users').doc(uid);

    final doc = await userDocRef.get();
    if (doc.exists) {
      await userDocRef.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await userDocRef.set({
      'uid': uid,
      'email': email,
      'displayName': name,
      'phone': phone,
      'role': 'learner',
      'title': 'Learner',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'onboardingCompleted': false,
    });

    await db.collection('learnerProfiles').doc(uid).set({
      'userId': uid,
      'careerField': null,
      'experienceLevel': null,
      'primaryGoal': null,
      'weeklyHours': null,
      'topPriority': null,
      'roadmapId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await db.collection('achievements').doc(uid).set({
      'userId': uid,
      'totalXP': 0,
      'level': 0,
      'certificates': [],
      'completedProgrammes': [],
    });
  }

  // ============================================================
  //  NAVIGATION
  // ============================================================
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kAuthAccentDark,
        behavior: SnackBarBehavior.floating,
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
                    // ✅ Animated Logo
                    Center(child: _buildAnimatedLogo()),
                    const SizedBox(height: 16),

                    // ✅ Brand Title "Excelerate" + "PATHFINDER" (regular text)
                    Center(child: _buildBrandTitle()),
                    const SizedBox(height: 36),

                    // Email Field
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
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            )),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: const Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontSize: 12,
                                color: kAuthPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      focused: _passwordFocused,
                      errorText: _passwordError,
                      obscure: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      suffixIcon: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: kAuthAccent,
                            size: 20,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_submitting || !_isFormValid())
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAuthPrimary,
                          disabledBackgroundColor:
                          kAuthPrimary.withOpacity(0.4),
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
                            Icon(Icons.login,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: kAuthAccent)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withOpacity(0.5),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: kAuthAccent)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Google',
                            icon: const Text('G',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            onPressed:
                            _submitting ? null : _handleGoogleSignIn,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _handleSignUp,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              children: [
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Start your path',
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

  // ═══════════════════════════════════════════════════════════════
  //  ✅ ANIMATED LOGO (scale + glow, no rotation)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleController,
        _logoGlowController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing glow background
                Container(
                  width: 76 + (_logoGlow.value * 12),
                  height: 76 + (_logoGlow.value * 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kAuthAccentDark.withOpacity(_logoGlow.value * 0.4),
                        kAuthAccentDark.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Main logo body
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kAuthPrimary, kAuthAccentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kAuthAccentDark.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ✅ BRAND TITLE - Regular "E" + "xcelerate" + "PATHFINDER" pill
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBrandTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Regular "Excelerate" text (normal E character)
        const Text(
          'Excelerate',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: kAuthAccentDark,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        // "PATHFINDER" pill badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: kAuthAccentDark.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'PATHFINDER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kAuthPrimary,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  CUSTOM TEXT FIELD
  // ============================================================
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool focused,
    String? errorText,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
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
            obscureText: obscure,
            keyboardType: keyboardType,
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
              suffixIcon: suffixIcon,
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

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: kAuthAccent, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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