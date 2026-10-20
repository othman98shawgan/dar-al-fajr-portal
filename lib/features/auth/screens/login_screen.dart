import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _showSupportDialog(String langCode) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr(
            langCode,
            ar: 'مركز الدعم والمساعدة',
            he: 'מרכז תמיכה ועזרה',
            en: 'Help & Support Center',
          ),
        ),
        content: Text(
          _tr(
            langCode,
            ar: 'للحصول على بيانات الدخول أو إعادة تعيين كلمة المرور، يرجى التواصل مع إدارة مركز دار الفجر.',
            he: 'לקבלת פרטי התחברות או איפוס סיסמה, אנא פנו להנהלת מרכז דאר אל-פג׳ר.',
            en: 'To obtain login credentials or reset your password, please contact Dar al-Fajr administration.',
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
    final textTheme = Theme.of(context).textTheme;

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

            // Full-Height Locked Scrollable Container
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Utility Bar: Language Switcher & Support
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Language Switcher Pill
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F4F6),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
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
                                                .setLocale(
                                                    const Locale('ar')),
                                          ),
                                          _LanguagePillButton(
                                            label: 'עברית',
                                            isSelected: langCode == 'he',
                                            onTap: () => ref
                                                .read(localeProvider.notifier)
                                                .setLocale(
                                                    const Locale('he')),
                                          ),
                                          _LanguagePillButton(
                                            label: 'EN',
                                            isSelected: langCode == 'en',
                                            onTap: () => ref
                                                .read(localeProvider.notifier)
                                                .setLocale(
                                                    const Locale('en')),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quick Help & Inquiries Modal Trigger
                                    Material(
                                      color: DarAlFajrTheme.surface,
                                      shape: const CircleBorder(),
                                      elevation: 1,
                                      shadowColor:
                                          Colors.black.withValues(alpha: 0.08),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () =>
                                            _showSupportDialog(langCode),
                                        child: const SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Icon(
                                            Icons.help_outline_rounded,
                                            size: 20,
                                            color: DarAlFajrTheme.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Main Card Container
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: DarAlFajrTheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Dawn Aesthetic Micro Ribbon
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
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Brand Emblem Frame
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFF2F4F6),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.05),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    'https://lh3.googleusercontent.com/aida/AEtjO1V9Oam7G6sX1YIzr7pz3XpfKfuE8Kfnar5tU7rF7dwmfjdthiNMd1b3Nav3jVdo_ogtlQnVTXJ5vf1wjqqVmw0cAXKFJREXRfZ6_yV_hovhVKddHvMpGrG8A0cPSR50HlPLEwJlHyxFFkwolU2b3NeUU0diAyDacM72OO9qhEcWzzlanJTTHhv88PhTxT4Jk4xdhEg7rM6PzI4tsCzGN2f7TbfXOQXcbEn0I_1175UoSQvMPYQmdCSn-1Q',
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                        Icons.menu_book_rounded,
                                                        size: 36,
                                                        color: DarAlFajrTheme
                                                            .primaryDark,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Typography Headings
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: DarAlFajrTheme.accent
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.wb_twilight_rounded,
                                                  size: 14,
                                                  color: DarAlFajrTheme.accent,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _tr(
                                                    langCode,
                                                    ar: 'بوابة الطالب والمعلم',
                                                    he: 'פורטל תלמיד ומורה',
                                                    en: 'Student & Teacher Portal',
                                                  ),
                                                  style: textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: const Color(
                                                        0xFF663500),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            l10n?.login ??
                                                _tr(
                                                  langCode,
                                                  ar: 'تسجيل الدخول',
                                                  he: 'התחברות',
                                                  en: 'Login',
                                                ),
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                              color:
                                                  DarAlFajrTheme.primaryDark,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 270,
                                            ),
                                            child: Text(
                                              _tr(
                                                langCode,
                                                ar: 'أهلاً بك في المنصة التعليمية والقرآنية المتكاملة لمجتمع دار الفجر',
                                                he: 'ברוכים הבאים לפלטפורמה החינוכית והקוראנית המשולבת של קהילת דאר אל-פג׳ר',
                                                en: 'Welcome to the integrated Quranic learning platform for the Dar al-Fajr community',
                                              ),
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color:
                                                    const Color(0xFF3D4947),
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 18),

                                          // Authentication Form
                                          Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Input 1: Identity
                                                Text(
                                                  _tr(
                                                    langCode,
                                                    ar: 'البريد الإلكتروني أو اسم المستخدم',
                                                    he: 'דוא״ל או שם משתמש',
                                                    en: 'Email or Username',
                                                  ),
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF191C1E),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller: _emailController,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'example@daralfajr.edu',
                                                    prefixIcon: const Icon(
                                                      Icons
                                                          .alternate_email_rounded,
                                                      size: 20,
                                                      color: Color(0xFF6D7A77),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.trim().isEmpty) {
                                                      return _tr(
                                                        langCode,
                                                        ar: 'يرجى إدخال البريد الإلكتروني',
                                                        he: 'נא להזין כתובת אימייל',
                                                        en: 'Please enter your email',
                                                      );
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 14),

                                                // Input 2: Password
                                                Text(
                                                  l10n?.password ??
                                                      _tr(
                                                        langCode,
                                                        ar: 'كلمة المرور',
                                                        he: 'סיסמה',
                                                        en: 'Password',
                                                      ),
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF191C1E),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                TextFormField(
                                                  controller:
                                                      _passwordController,
                                                  obscureText: _obscurePassword,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  onFieldSubmitted: (_) =>
                                                      _handleSignIn(),
                                                  decoration: InputDecoration(
                                                    hintText: '••••••••',
                                                    prefixIcon: const Icon(
                                                      Icons
                                                          .lock_outline_rounded,
                                                      size: 20,
                                                      color: Color(0xFF6D7A77),
                                                    ),
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscurePassword =
                                                              !_obscurePassword;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons
                                                                .visibility_outlined
                                                            : Icons
                                                                .visibility_off_outlined,
                                                        size: 20,
                                                        color: const Color(
                                                            0xFF6D7A77),
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
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
                                                const SizedBox(height: 8),

                                                // Auxiliary Options (Remember Me & Forgot Password)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      onTap: () {
                                                        setState(() {
                                                          _rememberMe =
                                                              !_rememberMe;
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: Checkbox(
                                                              value:
                                                                  _rememberMe,
                                                              activeColor:
                                                                  DarAlFajrTheme
                                                                      .primary,
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  _rememberMe =
                                                                      val ??
                                                                          false;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            _tr(
                                                              langCode,
                                                              ar: 'تذكّر تسجيل الدخول',
                                                              he: 'זכור אותי',
                                                              en: 'Remember me',
                                                            ),
                                                            style: textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              color: const Color(
                                                                  0xFF3D4947),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          _showSupportDialog(
                                                              langCode),
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      child: Text(
                                                        _tr(
                                                          langCode,
                                                          ar: 'نسيت كلمة المرور؟',
                                                          he: 'שכחת סיסמה?',
                                                          en: 'Forgot password?',
                                                        ),
                                                        style: textTheme
                                                            .labelMedium
                                                            ?.copyWith(
                                                          color: DarAlFajrTheme
                                                              .accent,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),

                                                // Primary Action CTA
                                                SizedBox(
                                                  height: 48,
                                                  child: ElevatedButton(
                                                    onPressed: isLoading
                                                        ? null
                                                        : _handleSignIn,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          DarAlFajrTheme
                                                              .primary,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      elevation: 2,
                                                    ),
                                                    child: isLoading
                                                        ? const SizedBox(
                                                            width: 22,
                                                            height: 22,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                l10n?.login ??
                                                                    _tr(
                                                                      langCode,
                                                                      ar: 'تسجيل الدخول',
                                                                      he: 'התחברות',
                                                                      en: 'Login',
                                                                    ),
                                                                style: textTheme
                                                                    .labelLarge
                                                                    ?.copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              const Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                size: 18,
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Spiritual/Daily Motivation Micro Banner
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 2),
                                                  child: Icon(
                                                    Icons.auto_stories_rounded,
                                                    size: 18,
                                                    color:
                                                        DarAlFajrTheme.accent,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: const Color(
                                                            0xFF3D4947),
                                                        height: 1.4,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: _tr(
                                                            langCode,
                                                            ar: 'إشراقة الفجر: ',
                                                            he: 'הארת השחר: ',
                                                            en: 'Dawn Reflection: ',
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Color(
                                                                0xFF191C1E),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: _tr(
                                                            langCode,
                                                            ar: '"خيركم من تعلّم القرآن وعلّمه" — بداية موفقة لحلقات اليوم.',
                                                            he: '"הטובים שבכם הם אלה שלומדים את הקוראן ומלמדים אותו" — התחלה מבורכת לשיעורי היום.',
                                                            en: '"The best among you are those who learn the Quran and teach it" — Have a blessed session today.',
                                                          ),
                                                        ),
                                                      ],
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

                              // Bottom Secondary Services / Activation
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Activation Badge Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: DarAlFajrTheme.surface,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: DarAlFajrTheme
                                                        .primary
                                                        .withValues(
                                                            alpha: 0.14),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.how_to_reg_rounded,
                                                    size: 18,
                                                    color:
                                                        DarAlFajrTheme.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _tr(
                                                          langCode,
                                                          ar: 'طالب أو معلم جديد؟',
                                                          he: 'תלמיד או מורה חדש?',
                                                          en: 'New Student or Teacher?',
                                                        ),
                                                        style: textTheme
                                                            .labelMedium
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                              0xFF191C1E),
                                                        ),
                                                      ),
                                                      Text(
                                                        _tr(
                                                          langCode,
                                                          ar: 'تفعيل الحساب لأول مرة عبر الإدارة',
                                                          he: 'הפעלת חשבון ראשונית דרך ההנהלה',
                                                          en: 'First-time account activation via Admin',
                                                        ),
                                                        style: textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                          color: const Color(
                                                              0xFF3D4947),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () =>
                                                _showSupportDialog(langCode),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFECEEF0),
                                              foregroundColor:
                                                  DarAlFajrTheme.primaryDark,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              _tr(
                                                langCode,
                                                ar: 'تفعيل الآن',
                                                he: 'הפעל עכשיו',
                                                en: 'Activate Now',
                                              ),
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                color:
                                                    DarAlFajrTheme.primaryDark,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Technical Support Help Link
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      children: [
                                        Text(
                                          _tr(
                                            langCode,
                                            ar: 'تواجه صعوبة في الدخول؟',
                                            he: 'מתקשים בהתחברות?',
                                            en: 'Having trouble signing in?',
                                          ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF3D4947),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              _showSupportDialog(langCode),
                                          child: Text(
                                            _tr(
                                              langCode,
                                              ar: 'تواصل مع الدعم الفني',
                                              he: 'פנה לתמיכה טכנית',
                                              en: 'Contact Technical Support',
                                            ),
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              color: DarAlFajrTheme.primary,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? DarAlFajrTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
