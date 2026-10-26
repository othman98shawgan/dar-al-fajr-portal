import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

class FirstLoginSetupScreen extends ConsumerStatefulWidget {
  const FirstLoginSetupScreen({super.key});

  @override
  ConsumerState<FirstLoginSetupScreen> createState() => _FirstLoginSetupScreenState();
}

class _FirstLoginSetupScreenState extends ConsumerState<FirstLoginSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
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
  bool get _hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);
  bool get _hasLetters => RegExp(r'[a-zA-Z\u0621-\u064A\u0590-\u05FF]').hasMatch(_newPasswordController.text);

  int get _passwordScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasDigit) score++;
    if (_hasSpecialChar) score++;
    if (_hasLetters) score++;
    return score;
  }

  String _tr(String langCode, {required String ar, required String he, required String en}) {
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
        return _tr(langCode, ar: 'قوية وممتازة', he: 'חזקה ומצוינת', en: 'Strong & Excellent');
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

    final phone = _phoneController.text.trim();
    final success = await ref
        .read(authControllerProvider.notifier)
        .completeFirstLoginSetup(
          newPassword: newPass,
          phoneNumber: phone,
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
        body: SafeArea(
          child: Column(
            children: [
              // Clean Minimal Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          ref.read(authControllerProvider.notifier).signOut();
                        }
                      },
                      tooltip: _tr(langCode, ar: 'رجوع', he: 'חזרה', en: 'Back'),
                      icon: const Icon(Icons.arrow_back_rounded, color: DarAlFajrTheme.primaryDark),
                      style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(8)),
                    ),

                    // Language Selector Pills
                    Container(
                      padding: const EdgeInsets.all(4),
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
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                              setState(() {
                                _preferredLanguage = 'ar';
                              });
                            },
                          ),
                          _LanguagePillButton(
                            label: 'עברית',
                            isSelected: langCode == 'he',
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('he'));
                              setState(() {
                                _preferredLanguage = 'he';
                              });
                            },
                          ),
                          _LanguagePillButton(
                            label: 'English',
                            isSelected: langCode == 'en',
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                              setState(() {
                                _preferredLanguage = 'en';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Centered Main Form Card (Scrollable)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Micro-Ribbon
                            Container(
                              height: 5,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [DarAlFajrTheme.accent, DarAlFajrTheme.primary, Color(0xFF89F5E7)],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Header Icon & Title
                                    Center(
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: DarAlFajrTheme.primary.withValues(alpha: 0.15),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(7),
                                        child: Image.asset(
                                          'assets/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'إعداد الحساب وكلمة المرور',
                                        he: 'הגדרת חשבון וסיסמה',
                                        en: 'Account & Security Setup',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: DarAlFajrTheme.primaryDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _tr(
                                        langCode,
                                        ar: 'يرجى تعيين كلمة مرور جديدة وإكمال بيانات ملفك للمتابعة',
                                        he: 'נא להגדיר סיסמה חדשה ולהשלים את פרטי הפרופיל כדי להמשיך',
                                        en: 'Set a new password and complete your profile to continue',
                                      ),
                                      style: const TextStyle(fontSize: 13, color: DarAlFajrTheme.outline),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),

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
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF191C1E),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '*',
                                              style: TextStyle(
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
                                          fillColor: const Color(0xFFF8FAFC),
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
                                        final isActive = newPassText.isNotEmpty && index < _passwordScore;
                                        return Expanded(
                                          child: Container(
                                            height: 4,
                                            margin: EdgeInsetsDirectional.only(end: index < 3 ? 6 : 0),
                                            decoration: BoxDecoration(
                                              color: isActive ? _strengthColor(context) : const Color(0xFFECEEF0),
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
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF191C1E),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '*',
                                          style: TextStyle(
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
                                          fillColor: const Color(0xFFF8FAFC),
                                          prefixIcon: Icon(
                                            !hasConfirm
                                                ? Icons.pending_outlined
                                                : (passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded),
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
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                      ),
                                    ],
                                    const SizedBox(height: 16),

                                    // Field 3: Verified Phone Number
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
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF191C1E),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '*',
                                          style: TextStyle(
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
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        textAlign: TextAlign.left,
                                        decoration: const InputDecoration(
                                          hintText: '059 123 4567',
                                          fillColor: Color(0xFFF8FAFC),
                                          prefixIcon: Icon(Icons.phone_outlined, size: 20, color: Color(0xFF6D7A77)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Field 4: Preferred Language
                                    Text(
                                      _tr(langCode, ar: 'اللغة المفضلة', he: 'שפה מועדפת', en: 'Preferred Language'),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF191C1E),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: _preferredLanguage,
                                      decoration: const InputDecoration(
                                        fillColor: Color(0xFFF8FAFC),
                                        prefixIcon: Icon(
                                          Icons.translate_rounded,
                                          size: 20,
                                          color: DarAlFajrTheme.primary,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'ar', child: Text('العربية (Arabic)')),
                                        DropdownMenuItem(value: 'he', child: Text('עברית (Hebrew)')),
                                        DropdownMenuItem(value: 'en', child: Text('English (الإنجليزية)')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _preferredLanguage = value;
                                          });
                                          ref.read(localeProvider.notifier).setLocale(Locale(value));
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Field 5: Date of Birth
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _tr(langCode, ar: 'تاريخ الميلاد', he: 'תאריך לידה', en: 'Date of Birth'),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF191C1E),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '*',
                                          style: TextStyle(
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
                                          fillColor: Color(0xFFF8FAFC),
                                          prefixIcon: Icon(
                                            Icons.calendar_today_rounded,
                                            size: 20,
                                            color: Color(0xFF6D7A77),
                                          ),
                                        ),
                                        child: Text(
                                          _selectedDateOfBirth != null
                                              ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
                                              : 'YYYY-MM-DD',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _selectedDateOfBirth != null
                                                ? const Color(0xFF191C1E)
                                                : const Color(0xFF6D7A77),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Terms & Conditions Checkbox
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _acceptedTerms,
                                            activeColor: DarAlFajrTheme.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                            child: Text(
                                              _tr(
                                                langCode,
                                                ar: 'أوافق على سياسة الخصوصية وشروط استخدام بوابة دار الفجر.',
                                                he: 'אני מסכים למדיניות הפרטיות ותנאי השימוש של פורטל דאר אל-פג׳ר.',
                                                en: 'I agree to the Dar al-Fajr Portal Privacy Policy and Terms of Use.',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: Color(0xFF3D4947),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Submit Button
                                    SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : () => _handleSubmit(langCode),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: DarAlFajrTheme.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : Text(
                                                _tr(
                                                  langCode,
                                                  ar: 'حفظ ومتابعة',
                                                  he: 'שמור והמשך',
                                                  en: 'Save & Continue',
                                                ),
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                              ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguagePillButton({required this.label, required this.isSelected, required this.onTap});

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

class _RequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementItem({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final color = isMet ? DarAlFajrTheme.primary : const Color(0xFF6D7A77);
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle_rounded : Icons.circle_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: isMet ? DarAlFajrTheme.primary : const Color(0xFF3D4947),
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
