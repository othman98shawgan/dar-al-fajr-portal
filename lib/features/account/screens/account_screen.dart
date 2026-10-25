import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';

/// My Account / Profile Screen with centralized Trilingual Locale Selection
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
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

  Future<void> _handleSelectLanguage(String code, String currentLang, AppUser? appUser) async {
    if (code == currentLang) return;

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
    }
  }

  void _showChangePasswordDialog(BuildContext context, String langCode) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(
          _tr(langCode, ar: 'تغيير كلمة المرور', he: 'שינוי סיסמה', en: 'Change Password'),
        ),
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
                      _tr(langCode, ar: 'تم تحديث كلمة المرور بنجاح!', he: 'הסיסמה עודכנה בהצלחה!', en: 'Password updated successfully!'),
                    ),
                    backgroundColor: DarAlFajrTheme.primary,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: DarAlFajrTheme.error,
                  ),
                );
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
        title: Text(
          _tr(langCode, ar: 'تسجيل الخروج', he: 'התנתקות', en: 'Sign Out'),
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: DarAlFajrTheme.error,
              foregroundColor: Colors.white,
            ),
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
        : _tr(langCode, ar: 'مستخدم دار الفجر', he: 'משתמש דאר אל-פג׳ר', en: 'Dar al-Fajr User');

    final displayEmail = appUser?.email.isNotEmpty == true ? appUser!.email : 'admin@daralfajr.org';
    final initial = displayName.trim().isNotEmpty ? displayName.trim().characters.first : 'م';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: DarAlFajrTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: DarAlFajrTheme.onSurface,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Navigate back according to user's role
                if (appUser?.role == UserRole.admin) {
                  context.go(AppRoutes.admin);
                } else if (appUser?.role == UserRole.teacher) {
                  context.go(AppRoutes.teacher);
                } else {
                  context.go(AppRoutes.home);
                }
              }
            },
          ),
          title: Text(
            _tr(langCode, ar: 'حسابي الشخصي', he: 'החשבון שלי', en: 'My Account'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DarAlFajrTheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: DarAlFajrTheme.error),
              tooltip: _tr(langCode, ar: 'تسجيل الخروج', he: 'התנתקות', en: 'Sign Out'),
              onPressed: () => _showSignOutDialog(context, langCode),
            ),
          ],
        ),
        body: Center(
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
                  child: Row(
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
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: DarAlFajrTheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6D7A77),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: DarAlFajrTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appUser != null
                                    ? appUser.role.displayName
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
                ),
                const SizedBox(height: 24),

                // 2. Centralized Trilingual Language Picker Section
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
                            child: const Icon(Icons.language_rounded, color: DarAlFajrTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(langCode, ar: 'لغة التطبيق', he: 'שפת האפליקציה', en: 'App Language'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DarAlFajrTheme.onSurface,
                                ),
                              ),
                              Text(
                                _tr(
                                  langCode,
                                  ar: 'اختر لغة الواجهة المفضلة لك',
                                  he: 'בחר את שפת הממשק המועדפת',
                                  en: 'Choose your preferred interface language',
                                ),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Language 1: Arabic
                      _buildLanguageTile(
                        code: 'ar',
                        title: 'العربية (Arabic)',
                        subtitle: 'اللغة العربية • من اليمين لليسار (RTL)',
                        badge: 'ض',
                        isSelected: langCode == 'ar',
                        onTap: () => _handleSelectLanguage('ar', langCode, appUser),
                      ),
                      const SizedBox(height: 10),

                      // Language 2: Hebrew
                      _buildLanguageTile(
                        code: 'he',
                        title: 'עברית (Hebrew)',
                        subtitle: 'עברית • מימין לשמאל (RTL)',
                        badge: 'עב',
                        isSelected: langCode == 'he',
                        onTap: () => _handleSelectLanguage('he', langCode, appUser),
                      ),
                      const SizedBox(height: 10),

                      // Language 3: English
                      _buildLanguageTile(
                        code: 'en',
                        title: 'English (English)',
                        subtitle: 'English • Left-to-Right layout (LTR)',
                        badge: 'EN',
                        isSelected: langCode == 'en',
                        onTap: () => _handleSelectLanguage('en', langCode, appUser),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Security & Settings Section
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
                              color: const Color(0xFFFE932C).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Color(0xFF904D00), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _tr(langCode, ar: 'أمان الحساب', he: 'אבטחת חשבון', en: 'Account Security'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: DarAlFajrTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Change Password Tile
                      ListTile(
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
                          _tr(langCode, ar: 'تحديث كلمة المرور الخاصة بحسابك', he: 'עדכון סיסמת החשבון', en: 'Update your account password'),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77)),
                        ),
                        trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFF6D7A77)),
                        onTap: () => _showChangePasswordDialog(context, langCode),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Sign Out Button
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
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
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6D7A77)),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: DarAlFajrTheme.primary,
                  size: 22,
                )
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: Color(0xFFD8DADC),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
