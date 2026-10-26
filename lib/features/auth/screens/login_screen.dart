import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';

import '../../../core/services/dev_seed_service.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSeeding = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authControllerProvider).error;
      String message = _tr(
        ref.read(localeProvider).languageCode,
        ar: 'تعذّر تسجيل الدخول. يرجى التحقق من البريد الإلكتروني وكلمة المرور.',
        he: 'ההתחברות נכשלה. אנא בדוק את האימייל והסיסמה.',
        en: 'Sign in failed. Please check your email and password.',
      );

      if (error is FirebaseAuthException && error.message != null) {
        message = error.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDevSeed(String langCode) async {
    setState(() => _isSeeding = true);
    try {
      await DevSeedService.seedAllDemoData(
        firestore: FirebaseFirestore.instance,
      );
      if (!mounted) return;
      _emailController.text = 'admin@daralfajr.org';
      _passwordController.text = 'Admin@2026!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'تمت تهيئة البيانات بنجاح! تم تعبئة حساب المدير.',
              he: 'נתוני הדמו נוצרו בהצלחה! מולאו פרטי מנהל.',
              en: 'Demo data seeded! Admin credentials auto-filled.',
            ),
          ),
          backgroundColor: DarAlFajrTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seed Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showSupportDialog(String langCode) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr(
            langCode,
            ar: 'المساعدة والدعم',
            he: 'תמיכה ועזרה',
            en: 'Help & Support',
          ),
        ),
        content: Text(
          _tr(
            langCode,
            ar: 'للحصول على بيانات حسابك أو إعادة تعيين كلمة المرور، يرجى التواصل مع إدارة مركز دار الفجر.',
            he: 'לקבלת פרטי חשבון או איפוס סיסמה, אנא פנו להנהלת מרכז דאר אל-פג׳ר.',
            en: 'To obtain your account credentials or reset your password, please contact Dar al-Fajr administration.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr(langCode, ar: 'حسناً', he: 'אישור', en: 'OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDevOptionsSheet(String langCode) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.code_rounded, color: DarAlFajrTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        _tr(
                          langCode,
                          ar: 'خيارات المطور (Dev Options)',
                          he: 'אפשרויות מפתח',
                          en: 'Developer Options',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isSeeding
                        ? null
                        : () async {
                            Navigator.of(ctx).pop();
                            await _handleDevSeed(langCode);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DarAlFajrTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isSeeding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 20),
                    label: Text(
                      _tr(
                        langCode,
                        ar: 'تهيئة الحسابات التجريبية (1-Click Seed)',
                        he: 'אתחול נתוני דמו (1-Click Seed)',
                        en: 'Seed Demo Accounts (1-Click)',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _tr(
                      langCode,
                      ar: 'تعبئة سريعة للحسابات:',
                      he: 'מילוי מהיר של חשבונות:',
                      en: 'Quick fill accounts:',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                        label: const Text('Admin'),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'admin@daralfajr.org';
                            _passwordController.text = 'Admin@2026!';
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.school_rounded, size: 16),
                        label: const Text('Teacher'),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'teacher@daralfajr.org';
                            _passwordController.text = 'Teacher@2026!';
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.family_restroom_rounded, size: 16),
                        label: const Text('Parent'),
                        onPressed: () {
                          setState(() {
                            _emailController.text = 'parent@daralfajr.org';
                            _passwordController.text = 'Parent@2026!';
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<bool>(
                    future: WakelockPlus.enabled,
                    builder: (context, snapshot) {
                      final isWakelockActive = snapshot.data ?? true;
                      return SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.screen_lock_portrait_rounded, size: 22, color: DarAlFajrTheme.accent),
                        title: Text(
                          _tr(
                            langCode,
                            ar: 'إبقاء الشاشة مضاءة (Wakelock)',
                            he: 'השאר מסך דולק (Wakelock)',
                            en: 'Keep Screen Awake (Wakelock)',
                          ),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _tr(
                            langCode,
                            ar: 'منع قفل الشاشة أثناء الاختبار',
                            he: 'מניעת נעילת המסך במהלך בדיקות',
                            en: 'Prevents screen sleep during testing',
                          ),
                          style: const TextStyle(fontSize: 11.5, color: DarAlFajrTheme.outline),
                        ),
                        value: isWakelockActive,
                        activeThumbColor: DarAlFajrTheme.primary,
                        onChanged: (val) async {
                          if (val) {
                            await WakelockPlus.enable();
                          } else {
                            await WakelockPlus.disable();
                          }
                          setSheetState(() {});
                        },
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    _tr(
                      langCode,
                      ar: 'معاينة الشاشات (Dev Flows):',
                      he: 'תצוגה מקדימה של מסכים:',
                      en: 'Screen Previews (Dev Flows):',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.firstLoginSetup);
                    },
                    icon: const Icon(Icons.password_rounded, size: 18),
                    label: Text(
                      _tr(
                        langCode,
                        ar: 'شاشة إعداد الدخول الأول (First Login Setup)',
                        he: 'מסך הגדרת כניסה ראשונה',
                        en: 'First-Login Setup Screen',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DarAlFajrTheme.primary,
                      side: BorderSide(
                        color: DarAlFajrTheme.primary.withValues(alpha: 0.4),
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _tr(
    String langCode, {
    required String ar,
    required String he,
    required String en,
  }) {
    switch (langCode) {
      case 'he':
        return he;
      case 'en':
        return en;
      case 'ar':
      default:
        return ar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        body: Stack(
          children: [
            // Top Dawn Gradient Backdrop
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 320,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        DarAlFajrTheme.accent.withValues(alpha: 0.14),
                        DarAlFajrTheme.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Subtle Radial Dot Pattern Overlay
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DotGridPainter(
                    color: DarAlFajrTheme.primary,
                    opacity: 0.035,
                    spacing: 20,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Screen Header: Language Switcher & Developer Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clean Language Switcher Pill
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LanguagePillButton(
                                label: 'العربية',
                                isSelected: langCode == 'ar',
                                onTap: () => ref
                                    .read(localeProvider.notifier)
                                    .setLocale(const Locale('ar')),
                              ),
                              _LanguagePillButton(
                                label: 'עברית',
                                isSelected: langCode == 'he',
                                onTap: () => ref
                                    .read(localeProvider.notifier)
                                    .setLocale(const Locale('he')),
                              ),
                              _LanguagePillButton(
                                label: 'EN',
                                isSelected: langCode == 'en',
                                onTap: () => ref
                                    .read(localeProvider.notifier)
                                    .setLocale(const Locale('en')),
                              ),
                            ],
                          ),
                        ),

                        // Developer Options Button
                        if (kDebugMode)
                          Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 1,
                            shadowColor: Colors.black.withValues(alpha: 0.06),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showDevOptionsSheet(langCode),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.terminal_rounded,
                                  size: 20,
                                  color: DarAlFajrTheme.outline,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),

                  // Scrollable Body containing the Login Card
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Main Card Container
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Multi-color Gradient Ribbon on Top of Card
                                    Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            DarAlFajrTheme.accent,
                                            DarAlFajrTheme.primary,
                                            Color(0xFF89F5E7),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Multi-layered Circular Brand Emblem Frame
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: 84,
                                                height: 84,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: DarAlFajrTheme.primary
                                                      .withValues(alpha: 0.14),
                                                ),
                                              ),
                                              Container(
                                                width: 72,
                                                height: 72,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F4F6),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.asset(
                                                    'assets/logo.png',
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(
                                                        Icons.menu_book_rounded,
                                                        size: 36,
                                                        color: DarAlFajrTheme.primaryDark,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // Clean Title & Subtitle
                                          Text(
                                            l10n?.appTitle ?? 'بوابة دار الفجر',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: DarAlFajrTheme.primaryDark,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _tr(
                                              langCode,
                                              ar: 'تسجيل الدخول للمتابعة',
                                              he: 'התחבר כדי להמשיך',
                                              en: 'Sign in to continue',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              color: DarAlFajrTheme.outline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          const SizedBox(height: 24),

                                          // Form
                                          Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // Email Field
                                                Text(
                                                  _tr(
                                                    langCode,
                                                    ar: 'البريد الإلكتروني',
                                                    he: 'אימייל',
                                                    en: 'Email',
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF191C1E),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller: _emailController,
                                                  keyboardType: TextInputType.emailAddress,
                                                  textInputAction: TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    hintText: 'name@daralfajr.org',
                                                    prefixIcon: const Icon(
                                                      Icons.alternate_email_rounded,
                                                      size: 18,
                                                      color: DarAlFajrTheme.outline,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: const BorderSide(
                                                        color: DarAlFajrTheme.primary,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.trim().isEmpty) {
                                                      return _tr(
                                                        langCode,
                                                        ar: 'يرجى إدخال البريد الإلكتروني',
                                                        he: 'נא להזין אימייל',
                                                        en: 'Please enter your email',
                                                      );
                                                    }
                                                    return null;
                                                  },
                                                ),

                                                const SizedBox(height: 16),

                                                // Password Field
                                                Text(
                                                  l10n?.password ??
                                                      _tr(
                                                        langCode,
                                                        ar: 'كلمة المرور',
                                                        he: 'סיסמה',
                                                        en: 'Password',
                                                      ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF191C1E),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller: _passwordController,
                                                  obscureText: _obscurePassword,
                                                  textInputAction: TextInputAction.done,
                                                  onFieldSubmitted: (_) => _handleSignIn(),
                                                  decoration: InputDecoration(
                                                    hintText: '••••••••',
                                                    prefixIcon: const Icon(
                                                      Icons.lock_outline_rounded,
                                                      size: 18,
                                                      color: DarAlFajrTheme.outline,
                                                    ),
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscurePassword = !_obscurePassword;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons.visibility_outlined
                                                            : Icons.visibility_off_outlined,
                                                        size: 18,
                                                        color: DarAlFajrTheme.outline,
                                                      ),
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                      borderSide: const BorderSide(
                                                        color: DarAlFajrTheme.primary,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return _tr(
                                                        langCode,
                                                        ar: 'يرجى إدخال كلمة المرور',
                                                        he: 'נא להזין סיסמה',
                                                        en: 'Please enter your password',
                                                      );
                                                    }
                                                    return null;
                                                  },
                                                ),

                                                const SizedBox(height: 10),

                                                // Remember Me & Forgot Password Row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      borderRadius: BorderRadius.circular(6),
                                                      onTap: () {
                                                        setState(() {
                                                          _rememberMe = !_rememberMe;
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Checkbox(
                                                              value: _rememberMe,
                                                              activeColor: DarAlFajrTheme.primary,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  _rememberMe = val ?? false;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            _tr(
                                                              langCode,
                                                              ar: 'تذكرني',
                                                              he: 'זכור אותי',
                                                              en: 'Remember me',
                                                            ),
                                                            style: const TextStyle(
                                                              fontSize: 12.5,
                                                              color: Color(0xFF3D4947),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => _showSupportDialog(langCode),
                                                      style: TextButton.styleFrom(
                                                        padding: EdgeInsets.zero,
                                                        minimumSize: Size.zero,
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      child: Text(
                                                        _tr(
                                                          langCode,
                                                          ar: 'نسيت كلمة المرور؟',
                                                          he: 'שכחת סיסמה?',
                                                          en: 'Forgot password?',
                                                        ),
                                                        style: const TextStyle(
                                                          fontSize: 12.5,
                                                          color: DarAlFajrTheme.primary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 22),

                                                // Login Button
                                                SizedBox(
                                                  height: 48,
                                                  child: ElevatedButton(
                                                    onPressed: isLoading ? null : _handleSignIn,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: DarAlFajrTheme.primary,
                                                      foregroundColor: Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: isLoading
                                                        ? const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.white,
                                                            ),
                                                          )
                                                        : Text(
                                                            l10n?.login ??
                                                                _tr(
                                                                  langCode,
                                                                  ar: 'تسجيل الدخول',
                                                                  he: 'התחברות',
                                                                  en: 'Sign In',
                                                                ),
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Simple Clean Support Footer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _tr(
                                      langCode,
                                      ar: 'تواجه صعوبة في الدخول؟',
                                      he: 'מתקשה להתחבר?',
                                      en: 'Having trouble signing in?',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6D7A77),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _showSupportDialog(langCode),
                                    child: Text(
                                      _tr(
                                        langCode,
                                        ar: 'تواصل مع الإدارة',
                                        he: 'פנה להנהלה',
                                        en: 'Contact admin',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: DarAlFajrTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

class _LanguagePillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguagePillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF3D4947),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;

  const _DotGridPainter({
    required this.color,
    required this.opacity,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.spacing != spacing;
  }
}
