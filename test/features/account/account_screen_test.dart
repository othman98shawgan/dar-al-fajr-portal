import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dar_al_fajr_portal/features/account/screens/account_screen.dart';
import 'package:dar_al_fajr_portal/features/auth/models/app_user.dart';
import 'package:dar_al_fajr_portal/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('AccountScreen renders profile, opens language modal, and edits profile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const mockUser = AppUser(
      uid: 'user-123',
      email: 'teacher@daralfajr.org',
      fullName: 'أستاذ أحمد فجر',
      phoneNumber: '0501234567',
      role: UserRole.teacher,
      isFirstLogin: false,
      preferredLanguage: 'ar',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAppUserProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
        ],
        child: const MaterialApp(
          home: AccountScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify user details and version are visible
    expect(find.text('أستاذ أحمد فجر'), findsWidgets);
    expect(find.text('teacher@daralfajr.org'), findsOneWidget);
    expect(find.text('0501234567'), findsOneWidget);
    expect(find.text('معلم'), findsOneWidget);
    expect(find.text('الإصدار 1.0.0'), findsOneWidget);

    // Verify standard back button is present and only 1 Sign Out button (at bottom)
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget); // Only 1 at bottom

    // 2. Verify Language Tile exists and tapping opens the selection modal
    expect(find.text('لغة التطبيق'), findsOneWidget);
    expect(find.text('العربية (Arabic)'), findsOneWidget);

    await tester.tap(find.text('لغة التطبيق'));
    await tester.pumpAndSettle();

    // Verify Modal Header & Options
    expect(find.text('اختر لغة التطبيق'), findsOneWidget);
    expect(find.text('עברית (Hebrew)'), findsOneWidget);
    expect(find.text('English (English)'), findsOneWidget);

    // Close modal via close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('اختر لغة التطبيق'), findsNothing);

    // 3. Verify Edit button exists and opens edit profile dialog
    final editIconFinder = find.byIcon(Icons.edit_outlined);
    expect(editIconFinder, findsOneWidget);
    await tester.tap(editIconFinder);
    await tester.pumpAndSettle();

    // Verify Edit Dialog opened
    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
    expect(find.text('الاسم الكامل'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.text('حفظ التعديلات'), findsOneWidget);

    // Test form validation: clear name field and tap save
    final nameField = find.widgetWithText(TextFormField, 'الاسم الكامل');
    await tester.enterText(nameField, '');
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();

    expect(find.text('يرجى إدخال الاسم الكامل'), findsOneWidget);

    // Cancel and dismiss dialog
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(find.text('تعديل الملف الشخصي'), findsNothing);
  });
}
