// lib/screens/admin/admin_login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_home_screen.dart';

// ─── Color constants (Admin Blue Theme) ────────────────────────────────
const kAuthPrimary = Color(0xFF1E40AF);  // ✅ Admin blue (was purple)
const kAuthAccent = Color(0xFF0EA5E9);   // ✅ Sky blue (was pink)
const kAuthAccentDark = Color(0xFFDC2626);  // ✅ Admin red (for errors/danger)
const kAuthFieldBg = Color(0xFFEFF6FF);  // ✅ Light blue
const kAuthFieldBgFocused = Color(0xFFDBEAFE);  // ✅ Focused blue
const kAuthBlobBlue = Color(0xFFDBEAFE);  // ✅ Blue blob
const kAuthBlobSky = Color(0xFFE0F2FE);  // ✅ Sky blue blob
const kAuthError = Color(0xFFDC2626);
const kAuthSuccess = Color(0xFF059669);  // ✅ Green (for success)

// ============================================================
//  ADMIN LOGIN SCREEN
// ============================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _keepSignedIn = false;
  bool _submitting = false;

  // Focus states
  bool _emailFocused = false;
  bool _passwordFocused = false;

  // Validation states
  String? _emailError;
  String? _passwordError;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  // Email regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ✅ Logo animations (scale + glow, no rotation)
  late final AnimationController _logoScaleController;
  late final AnimationController _logoGlowController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;

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
      setState(() => _passwordError = null);
    } else if (value.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
    } else {
      setState(() => _passwordError = null);
    }
  }

  bool _isFormValid() {
    return _emailRegex.hasMatch(_emailController.text.trim()) &&
        _passwordController.text.length >= 6;
  }

  // ============================================================
  //  ADMIN LOGIN HANDLER
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
          await _createFirestoreAdminDoc(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'Admin',
          );
        } else {
          final userData = userDoc.data() as Map<String, dynamic>;
          final role = userData['role'] ?? 'learner';

          if (role != 'admin') {
            await FirebaseAuth.instance.signOut();
            _showError('Access denied. Admin credentials required.');
            return;
          }

          await userDocRef.update({
            'lastActiveAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMsg = 'No admin account found. Contact system administrator.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password. Try again or contact support.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'This account has been disabled. Contact support.';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid email or password. Contact support if forgotten.';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Too many attempts. Contact support immediately.';
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
  //  CREATE FIRESTORE ADMIN DOCUMENT
  // ============================================================
  Future<void> _createFirestoreAdminDoc({
    required String uid,
    required String email,
    required String name,
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
      'phone': '',
      'role': 'admin',
      'title': 'Administrator',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'permissions': {
        'managePrograms': true,
        'manageUsers': true,
        'manageNotifications': true,
        'viewAnalytics': true,
      },
    });

    // Log admin login activity
    await db.collection('audit_logs').add({
      'action': 'ADMIN_LOGIN',
      'performedBy': uid,
      'adminEmail': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  //  CONTACT SUPPORT
  // ============================================================
  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kAuthAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kAuthPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: kAuthPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Need Help Signing In?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin accounts are managed securely. Contact our support team for assistance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              icon: Icons.email_rounded,
              title: 'Email Support',
              subtitle: 'admin-support@excelerate.com',
              color: kAuthPrimary,
              onTap: _launchEmail,
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.phone_rounded,
              title: 'Call Support',
              subtitle: '+1 (800) EXCEL-99',
              color: kAuthSuccess,
              onTap: _launchPhone,
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              subtitle: 'View documentation & FAQs',
              color: kAuthAccent,
              onTap: _showHelpCenter,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: kAuthAccentDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  LAUNCH EXTERNAL ACTIONS
  // ============================================================
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'admin-support@excelerate.com',
      query: 'subject=Admin Login Assistance',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showError('Email app not available. Contact: admin-support@excelerate.com');
      }
    } catch (e) {
      _showError('Could not open email. Contact: admin-support@excelerate.com');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+18003239299',
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showError('Phone app not available. Call: +1 (800) EXCEL-99');
      }
    } catch (e) {
      _showError('Could not open phone. Call: +1 (800) EXCEL-99');
    }
  }

  // ============================================================
  //  HELP CENTER
  // ============================================================
  void _showHelpCenter() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: kAuthPrimary),
            SizedBox(width: 8),
            Text('Admin Help Center'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFaqItem(
                'How do I get admin access?',
                'Admin accounts are created by the Super Admin. Contact support to request credentials.',
              ),
              const Divider(height: 20),
              _buildFaqItem(
                'I forgot my password',
                'Admin passwords cannot be self-reset. Contact Super Admin for a secure reset.',
              ),
              const Divider(height: 20),
              _buildFaqItem(
                'Why is my account disabled?',
                'Accounts may be disabled for security reasons. Contact support to reactivate.',
              ),
              const Divider(height: 20),
              _buildFaqItem(
                'How to change my password?',
                'After logging in, go to Profile → Account → Security & Privacy.',
              ),
              const Divider(height: 20),
              _buildFaqItem(
                'Is admin access secure?',
                'Yes, all admin actions are logged and monitored for security.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q: $question',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A: $answer',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
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
                    // ✅ Animated Admin Logo (same as learner)
                    Center(child: _buildAnimatedLogo()),
                    const SizedBox(height: 16),

                    // ✅ Brand Title "Excelerate" + "PATHFINDER" + Admin badge
                    Center(child: _buildBrandTitle()),
                    const SizedBox(height: 28),

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
                      hint: 'admin@excelerate.com',
                      icon: Icons.mail_outline,
                      focused: _emailFocused,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    const Text('PASSWORD',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        )),
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
                    const SizedBox(height: 16),

                    // Sign In Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_submitting || !_isFormValid())
                            ? null
                            : _handleLogin,
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
                            Icon(Icons.admin_panel_settings,
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
                    const SizedBox(height: 32),

                    // ✅ Restricted Access Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kAuthAccentDark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kAuthAccentDark.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.gpp_maybe_rounded, color: kAuthAccentDark, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'RESTRICTED AREA',
                                style: TextStyle(
                                  color: kAuthAccentDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This portal is highly confidential. Unauthorized access attempts are strictly monitored and subject to audit logs.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 11,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
  //  ✅ ANIMATED ADMIN LOGO (scale + glow, same as learner)
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
                        kAuthAccent.withOpacity(_logoGlow.value * 0.4),
                        kAuthAccent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Main logo body - Admin themed (blue gradient + shield)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [kAuthPrimary, kAuthAccent],  // ✅ Blue gradient (was purple→red)
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kAuthPrimary.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.admin_panel_settings_rounded,  // ✅ Admin shield (was rocket)
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
  //  ✅ BRAND TITLE - "Excelerate" + "PATHFINDER" + Admin badge
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBrandTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Regular "Excelerate" text
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
        const SizedBox(height: 8),
        // ✅ Admin badge (distinguishes from learner)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kAuthPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kAuthPrimary, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: kAuthPrimary, size: 12),
              const SizedBox(width: 4),
              Text(
                'ADMIN PORTAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kAuthPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
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
}

// ============================================================
//  GRADIENT BACKGROUND (Blue theme for admin)
// ============================================================
class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        // ✅ Blue blob (was pink)
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
                  kAuthBlobBlue.withOpacity(0.7),
                  kAuthBlobBlue.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // ✅ Sky blue blob (was pink)
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
                  kAuthBlobSky.withOpacity(0.5),
                  kAuthBlobSky.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // ✅ Light blue overlay (was lavender)
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
                  kAuthBlobBlue.withOpacity(0.3),
                  kAuthBlobBlue.withOpacity(0.0),
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