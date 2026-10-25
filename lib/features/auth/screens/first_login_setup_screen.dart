import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class FirstLoginSetupScreen extends ConsumerStatefulWidget {
  const FirstLoginSetupScreen({super.key});

  @override
  ConsumerState<FirstLoginSetupScreen> createState() =>
      _FirstLoginSetupScreenState();
}

class _FirstLoginSetupScreenState extends ConsumerState<FirstLoginSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountryCode = '+970';
  String _preferredLanguage = 'ar';
  DateTime? _selectedDateOfBirth;
  bool _acceptedTerms = true;
  bool _initializedFromProfile = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasDigit => RegExp(r'\d').hasMatch(_newPasswordController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);
  bool get _hasLetters =>
      RegExp(r'[a-zA-Z\u0621-\u064A\u0590-\u05FF]')
          .hasMatch(_newPasswordController.text);

  int get _passwordScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasDigit) score++;
    if (_hasSpecialChar) score++;
    if (_hasLetters) score++;
    return score;
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

  String _strengthLabel(String langCode) {
    if (_newPasswordController.text.isEmpty) {
      return _tr(langCode, ar: 'مطلوبة', he: 'חובה', en: 'Required');
    }
    switch (_passwordScore) {
      case 0:
      case 1:
        return _tr(langCode, ar: 'ضعيفة جداً', he: 'חלשה מאוד', en: 'Very Weak');
      case 2:
        return _tr(langCode, ar: 'متوسطة', he: 'בינונית', en: 'Fair');
      case 3:
        return _tr(langCode, ar: 'جيدة', he: 'טובה', en: 'Good');
      default:
        return _tr(
          langCode,
          ar: 'قوية وممتازة',
          he: 'חזקה ומצוינת',
          en: 'Strong & Excellent',
        );
    }
  }

  Color _strengthColor(BuildContext context) {
    if (_newPasswordController.text.isEmpty) {
      return const Color(0xFF6D7A77);
    }
    switch (_passwordScore) {
      case 0:
      case 1:
        return Theme.of(context).colorScheme.error;
      case 2:
        return DarAlFajrTheme.accent;
      case 3:
        return DarAlFajrTheme.primary;
      default:
        return DarAlFajrTheme.primaryDark;
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 12, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _handleSubmit(String langCode) async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'يرجى إدخال كلمة مرور لا تقل عن 8 أحرف.',
              he: 'נא להזין סיסמה בת 8 תווים לפחות.',
              en: 'Please enter a password of at least 8 characters.',
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'كلمتا المرور غير متطابقتين.',
              he: 'הסיסמאות אינן תואמות.',
              en: 'Passwords do not match.',
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'يرجى إدخال رقم الهاتف المعتمد.',
              he: 'נא להזין מספר טלפון.',
              en: 'Please enter your phone number.',
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'يرجى الموافقة على سياسة الخصوصية وشروط الاستخدام.',
              he: 'נא לאשר את מדיניות הפרטיות ותנאי השימוש.',
              en: 'Please accept the Privacy Policy and Terms of Use.',
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final fullPhone = '$_selectedCountryCode ${_phoneController.text.trim()}';
    final success = await ref
        .read(authControllerProvider.notifier)
        .completeFirstLoginSetup(
          newPassword: newPass,
          phoneNumber: fullPhone,
          preferredLanguage: _preferredLanguage,
          dateOfBirth: _selectedDateOfBirth,
        );

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authControllerProvider).error;
      String message = _tr(
        langCode,
        ar: 'حدث خطأ أثناء حفظ الإعدادات. يرجى المحاولة مرة أخرى.',
        he: 'אירעה שגיאה בשמירת ההגדרות. אנא נסה שוב.',
        en: 'Failed to save settings. Please try again.',
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              langCode,
              ar: 'تم حفظ الإعدادات بنجاح!',
              he: 'ההגדרות נשמרו בהצלחה!',
              en: 'Settings saved successfully!',
            ),
          ),
          backgroundColor: DarAlFajrTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final appUserAsync = ref.watch(currentAppUserProvider);
    final appUser = appUserAsync.asData?.value;
    final textTheme = Theme.of(context).textTheme;

    if (!_initializedFromProfile && appUser != null) {
      _initializedFromProfile = true;
      _preferredLanguage = appUser.preferredLanguage;
      if (appUser.phoneNumber != null && appUser.phoneNumber!.isNotEmpty) {
        _phoneController.text = appUser.phoneNumber!;
      }
    }

    final confirmText = _confirmPasswordController.text;
    final newPassText = _newPasswordController.text;
    final hasConfirm = confirmText.isNotEmpty;
    final passwordsMatch = hasConfirm && newPassText == confirmText;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            decoration: BoxDecoration(
              color: DarAlFajrTheme.surface.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 64,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => ref
                                    .read(authControllerProvider.notifier)
                                    .signOut(),
                                tooltip: _tr(
                                  langCode,
                                  ar: 'رجوع',
                                  he: 'חזרה',
                                  en: 'Back',
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF191C1E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: DarAlFajrTheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 20,
                                  color: DarAlFajrTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'إعداد الحساب',
                                  he: 'הגדרת חשבון',
                                  en: 'Register Student',
                                ),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF191C1E),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: DarAlFajrTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // Top Onboarding Stepper Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 18,
                            color: DarAlFajrTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _tr(
                              langCode,
                              ar: 'إكمال إعداد الحساب',
                              he: 'השלמת הגדרת החשבון',
                              en: 'Complete Account Setup',
                            ),
                            style: textTheme.labelLarge?.copyWith(
                              color: DarAlFajrTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: DarAlFajrTheme.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _tr(
                            langCode,
                            ar: 'الخطوة 1 من 1 • إلزامي',
                            he: 'שלב 1 מתוך 1 • חובה',
                            en: 'Step 1 of 1 • Mandatory',
                          ),
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF2F1500),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Linear Stepper Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 6,
                      backgroundColor: Color(0xFFECEEF0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DarAlFajrTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security Welcoming Alert Banner
                  Container(
                    decoration: BoxDecoration(
                      color: DarAlFajrTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 6,
                            color: DarAlFajrTheme.accent,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: DarAlFajrTheme.accent
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      size: 20,
                                      color: Color(0xFF663500),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              _tr(
                                                langCode,
                                                ar: 'تحديث أمني إلزامي',
                                                he: 'עדכון אבטחה חובה',
                                                en: 'Mandatory Security Update',
                                              ),
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF191C1E),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: DarAlFajrTheme.primary
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _tr(
                                                  langCode,
                                                  ar: 'خطوة أولى',
                                                  he: 'שלב ראשון',
                                                  en: 'First Step',
                                                ),
                                                style: textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: DarAlFajrTheme
                                                      .primaryDark,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _tr(
                                            langCode,
                                            ar: 'مرحباً بك! يرجى تعيين كلمة مرور جديدة وإكمال بيانات ملفك الشخصي للمتابعة إلى بوابة دار الفجر التعليمية.',
                                            he: 'ברוכים הבאים! נא להגדיר סיסמה חדשה ולהשלים את פרטי הפרופיל כדי להמשיך לפורטל דאר אל-פג׳ר.',
                                            en: 'Welcome! Please set a new password and complete your profile details to proceed to the Dar al-Fajr Portal.',
                                          ),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF3D4947),
                                            height: 1.45,
                                          ),
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
                  const SizedBox(height: 16),

                  // Main Interactive Form Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DarAlFajrTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Field 1: New Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _tr(
                                    langCode,
                                    ar: 'كلمة المرور الجديدة',
                                    he: 'סיסמה חדשה',
                                    en: 'New Password',
                                  ),
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF191C1E),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '*',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _strengthLabel(langCode),
                              style: textTheme.labelSmall?.copyWith(
                                color: _strengthColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              fillColor: const Color(0xFFF2F4F6),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: const Color(0xFF6D7A77),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password Strength Meter Bar (4 segments)
                        Row(
                          children: List.generate(4, (index) {
                            final isActive = newPassText.isNotEmpty &&
                                index < _passwordScore;
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsetsDirectional.only(
                                  end: index < 3 ? 6 : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _strengthColor(context)
                                      : const Color(0xFFECEEF0),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),

                        // Password Micro-requirements checklist (2x2 grid)
                        Row(
                          children: [
                            Expanded(
                              child: _RequirementItem(
                                label: _tr(
                                  langCode,
                                  ar: '8 أحرف كحد أدنى',
                                  he: 'לפחות 8 תווים',
                                  en: 'At least 8 characters',
                                ),
                                isMet: _hasMinLength,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RequirementItem(
                                label: _tr(
                                  langCode,
                                  ar: 'رقم واحد على الأقل',
                                  he: 'ספרה אחת לפחות',
                                  en: 'At least one number',
                                ),
                                isMet: _hasDigit,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _RequirementItem(
                                label: _tr(
                                  langCode,
                                  ar: 'رمز خاص (!@#\$)',
                                  he: 'תו מיוחד (!@#\$)',
                                  en: 'Special char (!@#\$)',
                                ),
                                isMet: _hasSpecialChar,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RequirementItem(
                                label: _tr(
                                  langCode,
                                  ar: 'حروف متنوعة',
                                  he: 'אותיות מגוונות',
                                  en: 'Mixed letters',
                                ),
                                isMet: _hasLetters,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Confirm Password
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tr(
                                langCode,
                                ar: 'تأكيد كلمة المرور',
                                he: 'אימות סיסמה',
                                en: 'Confirm Password',
                              ),
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF191C1E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              fillColor: const Color(0xFFF2F4F6),
                              prefixIcon: Icon(
                                !hasConfirm
                                    ? Icons.pending_outlined
                                    : (passwordsMatch
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded),
                                size: 20,
                                color: !hasConfirm
                                    ? const Color(0xFF6D7A77)
                                    : (passwordsMatch
                                        ? DarAlFajrTheme.primary
                                        : Theme.of(context).colorScheme.error),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: const Color(0xFF6D7A77),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (hasConfirm && !passwordsMatch) ...[
                          const SizedBox(height: 4),
                          Text(
                            _tr(
                              langCode,
                              ar: 'كلمتا المرور غير متطابقتين بعد',
                              he: 'הסיסמאות עדיין אינן תואמות',
                              en: 'Passwords do not match yet',
                            ),
                            style: textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Field 3: Phone Number with Country Selector
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tr(
                                langCode,
                                ar: 'رقم الهاتف المعتمد',
                                he: 'מספר טלפון מאומת',
                                en: 'Verified Phone Number',
                              ),
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF191C1E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 132,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedCountryCode,
                                  decoration: const InputDecoration(
                                    fillColor: Color(0xFFF2F4F6),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 13,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: '+972',
                                      child: Text('🇵🇸 +972'),
                                    ),
                                    DropdownMenuItem(
                                      value: '+970',
                                      child: Text('🇵🇸 +970'),
                                    ),
                                    DropdownMenuItem(
                                      value: '+962',
                                      child: Text('🇯🇴 +962'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCountryCode = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textAlign: isRtl
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  decoration: const InputDecoration(
                                    hintText: '59 123 4567',
                                    fillColor: Color(0xFFF2F4F6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tr(
                            langCode,
                            ar: 'يُستخدم لتأكيد جلسات التسميع وتنبيهات الحلقات.',
                            he: 'משמש לאישור מפגשי דקלום והתראות שיעורים.',
                            en: 'Used to confirm recitation sessions and class notifications.',
                          ),
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF3D4947),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 4: Preferred Language
                        Text(
                          _tr(
                            langCode,
                            ar: 'اللغة المفضلة للواجهة والتنبيهات',
                            he: 'שפה מועדפת לממשק ולהתראות',
                            en: 'Preferred Language for UI & Alerts',
                          ),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF191C1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _preferredLanguage,
                          decoration: const InputDecoration(
                            fillColor: Color(0xFFF2F4F6),
                            prefixIcon: Icon(
                              Icons.translate_rounded,
                              size: 20,
                              color: DarAlFajrTheme.primary,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(
                                'العربية (Arabic) - اللغة الافتراضية',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'he',
                              child: Text('עברית (Hebrew)'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English (الإنجليزية)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _preferredLanguage = value;
                              });
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(Locale(value));
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Field 5: Date of Birth
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tr(
                                langCode,
                                ar: 'تاريخ الميلاد',
                                he: 'תאריך לידה',
                                en: 'Date of Birth',
                              ),
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF191C1E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _pickDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              fillColor: Color(0xFFF2F4F6),
                              prefixIcon: Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                                color: Color(0xFF6D7A77),
                              ),
                            ),
                            child: Text(
                              _selectedDateOfBirth != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(_selectedDateOfBirth!)
                                  : 'YYYY-MM-DD',
                              style: textTheme.bodyMedium?.copyWith(
                                color: _selectedDateOfBirth != null
                                    ? const Color(0xFF191C1E)
                                    : const Color(0xFF6D7A77),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tr(
                            langCode,
                            ar: 'تحديد العمر لتخصيص خطة المنهاج القرآني المناسبة.',
                            he: 'ציון הגיל להתאמת תוכנית הלימודים הקוראנית המתאימה.',
                            en: 'Used to tailor the appropriate Quranic curriculum plan.',
                          ),
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF6D7A77),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Consent & Terms Notice
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: DarAlFajrTheme.primary,
                                onChanged: (val) {
                                  setState(() {
                                    _acceptedTerms = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptedTerms = !_acceptedTerms;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF3D4947),
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _tr(
                                          langCode,
                                          ar: 'بالمتابعة، فإنك توافق على ',
                                          he: 'בהמשך, הינך מסכים ל',
                                          en: 'By continuing, you agree to the ',
                                        ),
                                      ),
                                      TextSpan(
                                        text: _tr(
                                          langCode,
                                          ar: 'سياسة الخصوصية',
                                          he: 'מדיניות הפרטיות',
                                          en: 'Privacy Policy',
                                        ),
                                        style: const TextStyle(
                                          color: DarAlFajrTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _tr(
                                          langCode,
                                          ar: ' و',
                                          he: ' ו',
                                          en: ' and ',
                                        ),
                                      ),
                                      TextSpan(
                                        text: _tr(
                                          langCode,
                                          ar: 'شروط الاستخدام',
                                          he: 'תנאי השימוש',
                                          en: 'Terms of Use',
                                        ),
                                        style: const TextStyle(
                                          color: DarAlFajrTheme.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _tr(
                                          langCode,
                                          ar: ' لبوابة دار الفجر التعليمية.',
                                          he: ' של פורטל דאר אל-פג׳ר.',
                                          en: ' of the Dar al-Fajr Portal.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Motivational Islamic Quote Card / Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DarAlFajrTheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                DarAlFajrTheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 20,
                            color: DarAlFajrTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(
                                  langCode,
                                  ar: '«خَيرُكُم مَن تعَلَّمَ القُرآنَ وعَلَّمَه»',
                                  he: '«הטובים שבכם הם אלה שלומדים את הקוראן ומלמדים אותו»',
                                  en: '“The best among you are those who learn the Quran and teach it”',
                                ),
                                style: textTheme.labelLarge?.copyWith(
                                  color: DarAlFajrTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'نتطلع لرحلتك المباركة معنا في رحاب القرآن الكريم.',
                                  he: 'אנו מצפים למסע המבורך שלך איתנו.',
                                  en: 'We look forward to your blessed journey with the Noble Quran.',
                                ),
                                style: textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF3D4947),
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
          ),
        ),

        // Sticky Bottom Action Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: DarAlFajrTheme.surface.withValues(alpha: 0.96),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : () => _handleSubmit(langCode),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DarAlFajrTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'جارٍ حفظ الإعدادات...',
                                        he: 'שומר הגדרות...',
                                        en: 'Saving settings...',
                                      ),
                                      style: textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'حفظ ومتابعة',
                                        he: 'שמור והמשך',
                                        en: 'Save & Continue',
                                      ),
                                      style: textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _tr(
                          langCode,
                          ar: 'جميع بياناتك مشفرة ومحمية وفق معايير الأمان المعتمدة',
                          he: 'כל הנתונים שלך מוצפנים ומוגנים בהתאם לתקני האבטחה',
                          en: 'All your data is encrypted and protected under security standards',
                        ),
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF6D7A77),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementItem({
    required this.label,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMet ? DarAlFajrTheme.primary : const Color(0xFF6D7A77);
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 15,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isMet ? DarAlFajrTheme.primary : const Color(0xFF3D4947),
                  fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
