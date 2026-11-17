import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/parent_student_models.dart';
import 'parent_student_tokens.dart';

/// Opens the quick dialog to send a note to the child's teacher.
void showParentMessageTeacherSheet({
  required BuildContext context,
  required String langCode,
  required ChildPortalProfile child,
}) {
  final msgCtrl = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (dlgCtx) => AlertDialog(
      title: Text(
        trByLang(
          langCode,
          ar: 'مراسلة المعلم (${child.teacherNoteAuthor})',
          he: 'שליחת הודעה למורה',
          en: 'Message Teacher (${child.teacherNoteAuthor})',
        ),
      ),
      content: TextField(
        controller: msgCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: trByLang(
            langCode,
            ar: 'اكتب ملاحظتك أو استفسارك حول متابعة ${child.shortName}...',
            he: 'כתוב הודעה למורה...',
            en: 'Write your note regarding ${child.shortName}...',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dlgCtx).pop(),
          child: Text(trByLang(langCode, ar: 'إلغاء', he: 'ביטול', en: 'Cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DarAlFajrTheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(dlgCtx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  trByLang(
                    langCode,
                    ar: 'تم إرسال رسالتك إلى ${child.teacherNoteAuthor} بنجاح',
                    he: 'ההודעה נשלחה בהצלחה',
                    en: 'Message sent to ${child.teacherNoteAuthor}',
                  ),
                ),
                backgroundColor: ParentStudentTokens.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(trByLang(langCode, ar: 'إرسال', he: 'שלח', en: 'Send')),
        ),
      ],
    ),
  );
}
