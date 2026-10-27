import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';

/// My Account / Profile Screen with centralized Trilingual Locale Selection Modal,
/// smooth transition loader, and Personal Profile Information Management (Name, Phone Number, Security).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _isChangingLocale = false;

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

  String _currentLanguageDisplayName(String langCode) {
    switch (langCode) {
      case 'he':
        return 'עברית (Hebrew)';
      case 'en':
        return 'English (English)';
      case 'ar':
      default:
        return 'العربية (Arabic)';
    }
  }

  String _languageBadge(String langCode) {
    switch (langCode) {
      case 'he':
        return 'עב';
      case 'en':
        return 'EN';
      case 'ar':
      default:
        return 'ع';
    }
  }

  Future<void> _handleSelectLanguage(String code, String currentLang, AppUser? appUser) async {
    if (code == currentLang) return;

    setState(() {
      _isChangingLocale = true;
    });

    try {
      // 1. Update active app-wide locale in Riverpod
      ref.read(localeProvider.notifier).setLocale(Locale(code));

      // 2. Persist to Firestore if user profile exists
      if (appUser != null && appUser.uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(appUser.uid).update({
          'preferredLanguage': code,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Smooth visual transition delay
      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (mounted) {
        context.go(AppRoutes.account);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              code,
              ar: 'تم تغيير لغة التطبيق إلى العربية بنجاح',
              he: 'שפת המערכת עודכנה לעברית בהצלחה',
              en: 'Application language updated to English',
            ),
          ),
          backgroundColor: DarAlFajrTheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      // If Firestore update fails silently (e.g. offline/mock), local state is still updated
    } finally {
      if (mounted) {
        setState(() {
          _isChangingLocale = false;
        });
      }
    }
  }

  void _showLanguageSelectionModal(BuildContext context, String currentLang, AppUser? appUser) {
    final isRtl = currentLang == 'ar' || currentLang == 'he';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFD8DADC), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Modal Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language_rounded, color: DarAlFajrTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tr(currentLang, ar: 'اختر لغة التطبيق', he: 'בחר שפת ממשק', en: 'Select App Language'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              _tr(
                                currentLang,
                                ar: 'تتغير لغة الواجهة والاتجاهات فوراً',
                                he: 'שפת הממשק וכיוון הטקסט יתעדכנו מיד',
                                en: 'Interface language and layout change instantly',
                              ),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF6D7A77)),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Option 1: Arabic
                  _buildModalLanguageItem(
                    code: 'ar',
                    title: 'العربية (Arabic)',
                    subtitle: 'اللغة العربية • من اليمين لليسار (RTL)',
                    badge: 'ع',
                    isSelected: currentLang == 'ar',
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      _handleSelectLanguage('ar', currentLang, appUser);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Hebrew
                  _buildModalLanguageItem(
                    code: 'he',
                    title: 'עברית (Hebrew)',
                    subtitle: 'עברית • מימין לשמאל (RTL)',
                    badge: 'עב',
                    isSelected: currentLang == 'he',
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      _handleSelectLanguage('he', currentLang, appUser);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Option 3: English
                  _buildModalLanguageItem(
                    code: 'en',
                    title: 'English (English)',
                    subtitle: 'English • Left-to-Right layout (LTR)',
                    badge: 'EN',
                    isSelected: currentLang == 'en',
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      _handleSelectLanguage('en', currentLang, appUser);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalLanguageItem({
    required String code,
    required String title,
    required String subtitle,
    required String badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? DarAlFajrTheme.primary.withValues(alpha: 0.06) : const Color(0xFFF7F9FB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFE6E8EA),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? DarAlFajrTheme.primary : const Color(0xFFE6E8EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : const Color(0xFF3D4947),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected ? DarAlFajrTheme.primary : DarAlFajrTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6D7A77))),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: DarAlFajrTheme.primary, size: 22)
              else
                const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFFD8DADC), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String langCode, AppUser? appUser) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: appUser?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: appUser?.phoneNumber ?? '');
    bool isSaving = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: DarAlFajrTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _tr(langCode, ar: 'تعديل الملف الشخصي', he: 'עריכת פרופיל', en: 'Edit Profile'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        langCode,
                        ar: 'قم بتحديث اسمك ورقم الهاتف للتواصل وإدارة الحساب بسهولة.',
                        he: 'עדכן את שמך ומספר הטלפון שלך ליצירת קשר נוחה.',
                        en: 'Update your name and phone number for seamless communication.',
                      ),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF6D7A77)),
                    ),
                    const SizedBox(height: 18),
                    // Full Name Field
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: _tr(langCode, ar: 'الاسم الكامل', he: 'שם מלא', en: 'Full Name'),
                        hintText: _tr(langCode, ar: 'أدخل الاسم الكامل', he: 'הזן שם מלא', en: 'Enter full name'),
                        prefixIcon: const Icon(Icons.badge_outlined, color: DarAlFajrTheme.primary, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return _tr(
                            langCode,
                            ar: 'يرجى إدخال الاسم الكامل',
                            he: 'נא להזין שם מלא',
                            en: 'Please enter your full name',
                          );
                        }
                        if (val.trim().length < 2) {
                          return _tr(langCode, ar: 'الاسم قصير جداً', he: 'השם קצר מדי', en: 'Name is too short');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Phone Number Field
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: _tr(langCode, ar: 'رقم الهاتف', he: 'מספר טלפון', en: 'Phone Number'),
                        hintText: '05xxxxxxxx',
                        prefixIcon: const Icon(Icons.phone_outlined, color: DarAlFajrTheme.primary, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(dlgCtx).pop(),
                child: Text(
                  _tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel'),
                  style: const TextStyle(color: Color(0xFF6D7A77)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DarAlFajrTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSaving = true);

                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final uid = appUser?.uid ?? ref.read(firebaseAuthProvider).currentUser?.uid;
                          if (uid != null && uid.isNotEmpty) {
                            await ref
                                .read(authRepositoryProvider)
                                .updateProfile(
                                  uid: uid,
                                  fullName: nameCtrl.text.trim(),
                                  phoneNumber: phoneCtrl.text.trim(),
                                );
                          }

                          if (dlgCtx.mounted) {
                            Navigator.of(dlgCtx).pop();
                          }
                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(
                                  langCode,
                                  ar: 'تم تحديث الملف الشخصي بنجاح!',
                                  he: 'הפרופיל עודכן בהצלחה!',
                                  en: 'Profile updated successfully!',
                                ),
                              ),
                              backgroundColor: DarAlFajrTheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: DarAlFajrTheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _tr(langCode, ar: 'حفظ التعديلات', he: 'שמור שינויים', en: 'Save Changes'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String langCode) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(_tr(langCode, ar: 'تغيير كلمة المرور', he: 'שינוי סיסמה', en: 'Change Password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _tr(langCode, ar: 'كلمة المرور الجديدة', he: 'סיסמה חדשה', en: 'New Password'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: _tr(langCode, ar: 'تأكيد كلمة المرور', he: 'אימות סיסמה', en: 'Confirm Password'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPass = newPassCtrl.text.trim();
              if (newPass.length < 6 || newPass != confirmPassCtrl.text.trim()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _tr(
                        langCode,
                        ar: 'كلمات المرور غير متطابقة أو أقل من ٦ خانات',
                        he: 'הסיסמאות אינן תואמות או קצרות מדי',
                        en: 'Passwords do not match or are too short',
                      ),
                    ),
                    backgroundColor: DarAlFajrTheme.error,
                  ),
                );
                return;
              }

              Navigator.of(dlgCtx).pop();
              final messenger = ScaffoldMessenger.of(context);
              try {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.updatePassword(newPass);
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      _tr(
                        langCode,
                        ar: 'تم تحديث كلمة المرور بنجاح!',
                        he: 'הסיסמה עודכנה בהצלחה!',
                        en: 'Password updated successfully!',
                      ),
                    ),
                    backgroundColor: DarAlFajrTheme.primary,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DarAlFajrTheme.error));
              }
            },
            child: Text(_tr(langCode, ar: 'تحديث', he: 'עדכן', en: 'Update')),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, String langCode) {
    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(_tr(langCode, ar: 'تسجيل الخروج', he: 'התנתקות', en: 'Sign Out')),
        content: Text(
          _tr(
            langCode,
            ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج من دار الفجر؟',
            he: 'האם אתה בטוח שברצונך להתנתק?',
            en: 'Are you sure you want to sign out from Dar al-Fajr Portal?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: Text(_tr(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DarAlFajrTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(dlgCtx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: Text(_tr(langCode, ar: 'تسجيل الخروج', he: 'התנתק', en: 'Sign Out')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final langCode = currentLocale.languageCode;
    final isRtl = isRtlLocale(currentLocale);
    final appUser = ref.watch(currentAppUserProvider).asData?.value;

    final displayName = appUser?.fullName.isNotEmpty == true
        ? appUser!.fullName
        : _tr(langCode, ar: 'مستخدم دار الفجر', he: 'משتמש דאר אל-פג׳ר', en: 'Dar al-Fajr User');

    final displayEmail = appUser?.email.isNotEmpty == true ? appUser!.email : 'user@daralfajr.org';
    final displayPhone = appUser?.phoneNumber;
    final initial = displayName.trim().isNotEmpty ? displayName.trim().characters.first : 'م';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: DarAlFajrTheme.onSurface,
            ),
            onPressed: () {
              if (appUser?.role == UserRole.admin) {
                context.go(AppRoutes.admin);
              } else if (appUser?.role == UserRole.teacher) {
                context.go(AppRoutes.teacher);
              } else {
                context.go(AppRoutes.parentStudent);
              }
            },
          ),
          title: Text(
            _tr(langCode, ar: 'حسابي الشخصي', he: 'החשבון שלי', en: 'My Account'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: DarAlFajrTheme.onSurface),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    // 1. User Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Large User Avatar
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: DarAlFajrTheme.primary,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info & Role Pill
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: DarAlFajrTheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: DarAlFajrTheme.primary,
                                            size: 20,
                                          ),
                                          tooltip: _tr(
                                            langCode,
                                            ar: 'تعديل الملف الشخصي',
                                            he: 'עריכת פרופיל',
                                            en: 'Edit Profile',
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => _showEditProfileDialog(context, langCode, appUser),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 14, color: Color(0xFF6D7A77)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            displayEmail,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF6D7A77)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Phone number row or add phone prompt
                                    if (displayPhone != null && displayPhone.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF6D7A77)),
                                          const SizedBox(width: 6),
                                          Text(
                                            displayPhone,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF6D7A77)),
                                          ),
                                        ],
                                      )
                                    else
                                      InkWell(
                                        onTap: () => _showEditProfileDialog(context, langCode, appUser),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.add_call, size: 13, color: DarAlFajrTheme.accent),
                                              const SizedBox(width: 4),
                                              Text(
                                                _tr(
                                                  langCode,
                                                  ar: '+ إضافة رقم هاتف',
                                                  he: '+ הוסף מספר טלפון',
                                                  en: '+ Add phone number',
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: DarAlFajrTheme.accent,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    // Role Badge (localized)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        appUser != null
                                            ? appUser.role.localizedName(langCode)
                                            : _tr(langCode, ar: 'مدير النظام', he: 'מנהל מערכת', en: 'Administrator'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: DarAlFajrTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Settings & Preferences Section (Language, Profile Details, Password)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: DarAlFajrTheme.primary, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'إعدادات الحساب والتطبيق',
                                  he: 'הגדרות חשבון ואפליקציה',
                                  en: 'Account & App Settings',
                                ),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DarAlFajrTheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Language Selector Tile (Modal trigger)
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.language_rounded, color: DarAlFajrTheme.primary, size: 20),
                              ),
                              title: Text(
                                _tr(langCode, ar: 'لغة التطبيق', he: 'שפת האפליקציה', en: 'App Language'),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                _currentLanguageDisplayName(langCode),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: DarAlFajrTheme.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _languageBadge(langCode),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: DarAlFajrTheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                    color: const Color(0xFF6D7A77),
                                  ),
                                ],
                              ),
                              onTap: () => _showLanguageSelectionModal(context, langCode, appUser),
                            ),
                          ),
                          const Divider(height: 16),

                          // Edit Profile Tile
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_outline_rounded, color: Color(0xFF3D4947), size: 20),
                              ),
                              title: Text(
                                _tr(
                                  langCode,
                                  ar: 'تعديل البيانات الشخصية',
                                  he: 'עריכת פרטים אישיים',
                                  en: 'Edit Personal Details',
                                ),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                _tr(
                                  langCode,
                                  ar: 'الاسم ورقم الهاتف للتواصل',
                                  he: 'שם ומספר טלפון',
                                  en: 'Name and phone number',
                                ),
                              ),
                              trailing: Icon(
                                isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                color: const Color(0xFF6D7A77),
                              ),
                              onTap: () => _showEditProfileDialog(context, langCode, appUser),
                            ),
                          ),
                          const Divider(height: 16),

                          // Change Password Tile
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF3D4947), size: 20),
                              ),
                              title: Text(
                                _tr(langCode, ar: 'تغيير كلمة المرور', he: 'שינוי סיסמה', en: 'Change Password'),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                _tr(
                                  langCode,
                                  ar: 'تحديث كلمة المرور الخاصة بحسابك',
                                  he: 'עדכון סיסמת החשבון',
                                  en: 'Update your account password',
                                ),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                              ),
                              trailing: Icon(
                                isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                color: const Color(0xFF6D7A77),
                              ),
                              onTap: () => _showChangePasswordDialog(context, langCode),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showSignOutDialog(context, langCode),
                        icon: const Icon(Icons.logout_rounded, color: DarAlFajrTheme.error, size: 20),
                        label: Text(
                          _tr(langCode, ar: 'تسجيل الخروج', he: 'התנתקות', en: 'Sign Out'),
                          style: const TextStyle(
                            color: DarAlFajrTheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFDAD6), width: 1.5),
                          backgroundColor: const Color(0xFFFFF5F5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tr(
                              langCode,
                              ar: 'بوابة دار الفجر لتعليم القرآن الكريم',
                              he: 'פורטל דאר אל-פג׳ר ללימוד הקוראן',
                              en: 'Dar al-Fajr Quran Center Portal',
                            ),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tr(langCode, ar: 'الإصدار 1.0.0', he: 'גרסה 1.0.0', en: 'Version 1.0.0'),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E9B97), fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Transition Loader Overlay
            if (_isChangingLocale)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 3, color: DarAlFajrTheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tr(
                            langCode,
                            ar: 'جاري تحديث لغة التطبيق...',
                            he: 'מעדכן את שפת המערכת...',
                            en: 'Updating app language...',
                          ),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: DarAlFajrTheme.onSurface,
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
