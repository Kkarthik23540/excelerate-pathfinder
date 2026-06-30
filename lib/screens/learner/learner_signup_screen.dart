// lib/screens/learner_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
//  SIGNUP SCREEN
// ============================================================
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // UI state
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _submitting = false;

  // Logo animations
  late final AnimationController _logoScaleController;
  late final AnimationController _logoGlowController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;

  // Focus states
  bool _nameFocused = false;
  bool _phoneFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmFocused = false;

  // Validation
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  bool _nameTouched = false;
  bool _phoneTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  // Email regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  // Phone regex
  static final RegExp _phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');

  @override
  void initState() {
    super.initState();

    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = CurvedAnimation(
      parent: _logoScaleController,
      curve: Curves.elasticOut,
    );

    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _logoGlowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logoScaleController.forward();
    });

    _nameFocus.addListener(() {
      if (mounted) setState(() => _nameFocused = _nameFocus.hasFocus);
    });
    _phoneFocus.addListener(() {
      if (mounted) setState(() => _phoneFocused = _phoneFocus.hasFocus);
    });
    _emailFocus.addListener(() {
      if (mounted) setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      if (mounted) setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
    _confirmPasswordFocus.addListener(() {
      if (mounted) setState(() => _confirmFocused = _confirmPasswordFocus.hasFocus);
    });

    _nameController.addListener(_onNameChanged);
    _phoneController.addListener(_onPhoneChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _phoneController.removeListener(_onPhoneChanged);
    _emailController.removeListener(_onEmailChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmChanged);

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _logoScaleController.dispose();
    _logoGlowController.dispose();
    super.dispose();
  }

  // ============================================================
  //  VALIDATION HANDLERS
  // ============================================================
  void _onNameChanged() {
    if (!_nameTouched) _nameTouched = true;
    final value = _nameController.text.trim();
    if (value.isEmpty) {
      setState(() => _nameError = null);
    } else if (value.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
    } else {
      setState(() => _nameError = null);
    }
  }

  void _onPhoneChanged() {
    if (!_phoneTouched) _phoneTouched = true;
    final value = _phoneController.text.trim();
    if (value.isEmpty) {
      setState(() => _phoneError = null);
    } else if (!_phoneRegex.hasMatch(value)) {
      setState(() => _phoneError = 'Enter a valid phone number');
    } else {
      setState(() => _phoneError = null);
    }
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

  void _onPasswordChanged() {
    if (!_passwordTouched) _passwordTouched = true;
    final value = _passwordController.text;
    if (value.isEmpty) {
      setState(() {
        _passwordError = null;
      });
    } else if (value.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
    } else {
      setState(() => _passwordError = null);
    }

    if (_confirmPasswordController.text.isNotEmpty) {
      _onConfirmChanged();
    }
  }

  void _onConfirmChanged() {
    if (!_confirmTouched) _confirmTouched = true;
    final value = _confirmPasswordController.text;
    if (value.isEmpty) {
      setState(() => _confirmError = null);
    } else if (value != _passwordController.text) {
      setState(() => _confirmError = 'Passwords do not match');
    } else {
      setState(() => _confirmError = null);
    }
  }

  bool _isFormValid() {
    return _nameController.text.trim().length >= 2 &&
        _phoneRegex.hasMatch(_phoneController.text.trim()) &&
        _emailRegex.hasMatch(_emailController.text.trim()) &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text == _passwordController.text &&
        _passwordController.text.isNotEmpty;
  }

  // ============================================================
  //  PASSWORD STRENGTH
  // ============================================================
  double _passwordStrength() {
    final p = _passwordController.text;
    if (p.isEmpty) return 0.0;
    double strength = 0;
    if (p.length >= 6) strength += 0.25;
    if (p.length >= 10) strength += 0.15;
    if (p.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (p.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (p.contains(RegExp(r'[0-9]'))) strength += 0.1;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;
    return strength.clamp(0.0, 1.0);
  }

  String _passwordStrengthLabel() {
    final s = _passwordStrength();
    if (s == 0) return '';
    if (s < 0.4) return 'Weak';
    if (s < 0.7) return 'Medium';
    return 'Strong';
  }

  Color _passwordStrengthColor() {
    final s = _passwordStrength();
    if (s == 0) return Colors.transparent;
    if (s < 0.4) return kAuthError;
    if (s < 0.7) return const Color(0xFFF59E0B);
    return kAuthSuccess;
  }

  // ============================================================
  //  NAVIGATION
  // ============================================================
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // ============================================================
  //  SIGNUP HANDLER - ✅ CHANGED: Goes to Login after signup
  // ============================================================
  Future<void> _handleSignup() async {
    setState(() {
      _nameTouched = true;
      _phoneTouched = true;
      _emailTouched = true;
      _passwordTouched = true;
      _confirmTouched = true;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    if (_nameController.text.trim().length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Phone number is required');
      return;
    }
    if (!_phoneRegex.hasMatch(_phoneController.text.trim())) {
      setState(() => _phoneError = 'Enter a valid phone number');
      return;
    }
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
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }
    if (!_agreeTerms) {
      _showError('Please agree to Terms of Service');
      return;
    }

    setState(() => _submitting = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await credential.user
          ?.updateDisplayName(_nameController.text.trim());

      if (credential.user != null) {
        await _createFirestoreUserDoc(
          uid: credential.user!.uid,
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      // ✅ CHANGED: Sign out the user, then go to Login screen
      // This forces them to login manually after signup
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // ✅ Navigate to Login Screen (not Home)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );

        // ✅ Show success snackbar on the login screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 Account created successfully! Please sign in.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: kAuthSuccess,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Account already exists. Please sign in.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password is too weak. Use 6+ characters.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address.';
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
  //  FIRESTORE USER DOC CREATION
  // ============================================================
  Future<void> _createFirestoreUserDoc({
    required String uid,
    required String email,
    required String name,
    required String phone,
  }) async {
    final db = FirebaseFirestore.instance;

    await db.collection('users').doc(uid).set({
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
  //  ERROR TOAST
  // ============================================================
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back, color: kAuthPrimary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Center(child: _buildAnimatedLogo()),
                    const SizedBox(height: 16),

                    Center(child: _buildBrandTitle()),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Start Your Path',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.3)),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text('Create your free account',
                          style: TextStyle(
                              fontSize: 13, color: Colors.black54)),
                    ),
                    const SizedBox(height: 28),

                    // Full Name
                    _buildLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                      focused: _nameFocused,
                      errorText: _nameError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _phoneFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildLabel('PHONE NUMBER'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      focused: _phoneFocused,
                      errorText: _phoneError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel('EMAIL ADDRESS'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hint: 'Enter your mail-ID ',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      focused: _emailFocused,
                      errorText: _emailError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildLabel('PASSWORD'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      focused: _passwordFocused,
                      errorText: _passwordError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
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

                    // Password strength bar
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: _passwordStrength(),
                                minHeight: 4,
                                backgroundColor: kAuthFieldBg,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _passwordStrengthColor(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _passwordStrengthLabel(),
                            style: TextStyle(
                              fontSize: 11,
                              color: _passwordStrengthColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildLabel('CONFIRM PASSWORD'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirm,
                      focused: _confirmFocused,
                      errorText: _confirmError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSignup(),
                      suffixIcon: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: kAuthAccent,
                            size: 20,
                          ),
                          onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Terms agreement
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _agreeTerms,
                              onChanged: (v) =>
                                  setState(() => _agreeTerms = v ?? false),
                              activeColor: kAuthAccent,
                              side: const BorderSide(
                                  color: kAuthAccent, width: 1.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                WidgetSpan(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                          color: kAuthAccent,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                TextSpan(text: ' & '),
                                WidgetSpan(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                          color: kAuthAccent,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Create Account Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_submitting || !_isFormValid())
                            ? null
                            : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAuthPrimary,
                          disabledBackgroundColor:
                          kAuthPrimary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_add,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Create Account',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign in link
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              children: [
                                TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                      color: kAuthAccentDark,
                                      fontWeight: FontWeight.w600),
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
  //  ANIMATED LOGO
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
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70 + (_logoGlow.value * 10),
                  height: 70 + (_logoGlow.value * 10),
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
                Container(
                  width: 64,
                  height: 64,
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
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 32,
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
  //  BRAND TITLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBrandTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
  //  LABEL
  // ============================================================
  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500));
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
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: kAuthError),
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
              gradient: RadialGradient(colors: [
                kAuthBlobPink.withOpacity(0.7),
                kAuthBlobPink.withOpacity(0.0)
              ]),
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
              gradient: RadialGradient(colors: [
                const Color(0xFFF8BBD0).withOpacity(0.4),
                const Color(0xFFF8BBD0).withOpacity(0.0)
              ]),
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
                  kAuthBlobLavender.withOpacity(0.0)
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